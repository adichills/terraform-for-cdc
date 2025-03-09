# Create a secret for the database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-db-credentials"
  
  tags = {
    Name = "${var.project_name}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password
  })
}

# Create IAM policy for accessing the secret
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-secrets-access-policy"
  description = "Policy for accessing database credentials secret"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}

# Create MSK Connect connector for Debezium
resource "aws_mskconnect_connector" "debezium" {
  name = "${var.project_name}-debezium-connector"
  
  kafkaconnect_version = "2.7.1"
  
  capacity {
    provisioned_capacity {
      mcu_count    = 1
      worker_count = 1
    }
  }
  
  connector_configuration = {
    "connector.class" = "io.debezium.connector.mysql.MySqlConnector"
    "tasks.max" = "1"
    "database.hostname" = var.rds_endpoint
    "database.port" = tostring(var.rds_port)
    "database.user" = var.rds_username
    "database.password" = var.rds_password
    "database.server.id" = "1"
    "database.server.name" = var.project_name
    "database.include.list" = var.rds_database_name
    "database.history.kafka.bootstrap.servers" = var.msk_bootstrap_brokers
    "database.history.kafka.topic" = "${var.project_name}-dbhistory"
    "include.schema.changes" = "true"
    "transforms" = "unwrap"
    "transforms.unwrap.type" = "io.debezium.transforms.ExtractNewRecordState"
    "transforms.unwrap.drop.tombstones" = "false"
    "transforms.unwrap.delete.handling.mode" = "rewrite"
    "transforms.unwrap.add.fields" = "op,table,lsn,source.ts_ms"
    "key.converter" = "org.apache.kafka.connect.json.JsonConverter"
    "value.converter" = "org.apache.kafka.connect.json.JsonConverter"
    "key.converter.schemas.enable" = "false"
    "value.converter.schemas.enable" = "false"
  }
  
  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = var.msk_bootstrap_brokers
    }
  }
  
  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }
  
  kafka_cluster_encryption_in_transit {
    encryption_type = "PLAINTEXT"
  }
  
  plugin {
    custom_plugin {
      arn      = data.aws_mskconnect_custom_plugin.debezium.arn
      revision = data.aws_mskconnect_custom_plugin.debezium.latest_revision
    }
  }
  
  service_execution_role_arn = data.aws_iam_role.msk_connect.arn
  
  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.connector_logs.name
      }
    }
  }
}

# Create CloudWatch log group for connector logs
resource "aws_cloudwatch_log_group" "connector_logs" {
  name = "/aws/msk/connect/${var.project_name}-debezium-connector"
  retention_in_days = 7
  
  tags = {
    Name = "${var.project_name}-debezium-connector-logs"
  }
}

# Data sources to get existing resources from MSK module
data "aws_mskconnect_custom_plugin" "debezium" {
  name = "${var.project_name}-debezium-plugin"
}

data "aws_iam_role" "msk_connect" {
  name = "${var.project_name}-msk-connect-role"
} 