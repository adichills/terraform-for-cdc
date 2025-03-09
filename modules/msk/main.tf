resource "aws_security_group" "msk" {
  name        = "${var.project_name}-msk-sg"
  description = "Security group for MSK cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    security_groups = var.security_group_ids
    description = "Allow Kafka plaintext traffic"
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    security_groups = var.security_group_ids
    description = "Allow Kafka TLS traffic"
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    security_groups = var.security_group_ids
    description = "Allow Zookeeper traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-msk-sg"
  }
}

resource "aws_kms_key" "msk" {
  description = "KMS key for MSK cluster encryption"
  
  tags = {
    Name = "${var.project_name}-msk-kms-key"
  }
}

resource "aws_cloudwatch_log_group" "msk" {
  name = "/aws/msk/${var.project_name}"
  retention_in_days = 7
  
  tags = {
    Name = "${var.project_name}-msk-logs"
  }
}

resource "aws_msk_configuration" "msk" {
  name = "${var.project_name}-config"
  kafka_versions = [var.kafka_version]
  
  server_properties = <<PROPERTIES
auto.create.topics.enable=true
delete.topic.enable=true
default.replication.factor=3
min.insync.replicas=2
num.partitions=3
log.retention.hours=24
PROPERTIES
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = "${var.project_name}-cluster"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = concat(var.security_group_ids, [aws_security_group.msk.id])
    
    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn
  }

  configuration_info {
    arn      = aws_msk_configuration.msk.arn
    revision = aws_msk_configuration.msk.latest_revision
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
    }
  }

  tags = {
    Name = "${var.project_name}-msk-cluster"
  }
}

# Create MSK Connect custom plugin for Debezium
resource "aws_s3_bucket" "debezium_plugin" {
  bucket = "${var.project_name}-debezium-plugin-${random_string.suffix.result}"
  
  tags = {
    Name = "${var.project_name}-debezium-plugin-bucket"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_object" "debezium_plugin" {
  bucket = aws_s3_bucket.debezium_plugin.id
  key    = "debezium-connector-mysql.zip"
  source = "${path.module}/files/debezium-connector-mysql.zip"
  
  depends_on = [aws_s3_bucket.debezium_plugin]
}

resource "aws_mskconnect_custom_plugin" "debezium" {
  name         = "${var.project_name}-debezium-plugin"
  content_type = "ZIP"
  
  location {
    s3 {
      bucket_arn = aws_s3_bucket.debezium_plugin.arn
      file_key   = aws_s3_object.debezium_plugin.key
    }
  }
}

# IAM role for MSK Connect
resource "aws_iam_role" "msk_connect" {
  name = "${var.project_name}-msk-connect-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "msk_connect" {
  name        = "${var.project_name}-msk-connect-policy"
  description = "Policy for MSK Connect"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.debezium_plugin.arn,
          "${aws_s3_bucket.debezium_plugin.arn}/*"
        ]
      },
      {
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:*Topic*",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData"
        ]
        Effect = "Allow"
        Resource = [
          aws_msk_cluster.msk.arn,
          "${aws_msk_cluster.msk.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk_connect" {
  role       = aws_iam_role.msk_connect.name
  policy_arn = aws_iam_policy.msk_connect.arn
} 