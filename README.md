# AWS MSK with Debezium Connector for CDC

This Terraform project sets up an AWS MSK (Managed Streaming for Kafka) cluster with Debezium connector enabled for Change Data Capture (CDC) from an existing RDS Aurora database.

## Architecture

The infrastructure includes:

1. **VPC and Networking**: A VPC with public and private subnets across multiple availability zones, NAT gateway, and security groups.
2. **MSK Cluster**: A managed Kafka cluster with configurable broker nodes and Kafka version.
3. **Debezium Connector**: A Kafka Connect connector configured to capture changes from an existing RDS Aurora database.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.0.0 or newer
- An existing RDS Aurora database

## Usage

1. Clone this repository:
   ```
   git clone <repository-url>
   cd terraform-for-cdc
   ```

2. Create a `terraform.tfvars` file with your specific configuration:
   ```
   aws_region = "us-east-1"
   project_name = "your-project-name"
   
   # RDS Aurora database details
   rds_endpoint = "your-aurora-endpoint.rds.amazonaws.com"
   rds_port = 3306
   rds_database_name = "your_database_name"
   rds_username = "your_username"
   rds_password = "your_password"
   ```

3. Download the Debezium MySQL connector:
   ```
   curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.9.6.Final/debezium-connector-mysql-1.9.6.Final-plugin.tar.gz -o debezium-connector-mysql.tar.gz
   mkdir -p temp
   tar -xzf debezium-connector-mysql.tar.gz -C temp
   cd temp
   zip -r ../modules/msk/files/debezium-connector-mysql.zip .
   cd ..
   rm -rf temp debezium-connector-mysql.tar.gz
   ```

4. Initialize Terraform:
   ```
   terraform init
   ```

5. Plan the deployment:
   ```
   terraform plan
   ```

6. Apply the configuration:
   ```
   terraform apply
   ```

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| aws_region | AWS region to deploy resources | us-east-1 |
| project_name | Name of the project | debezium-msk |
| vpc_cidr | CIDR block for the VPC | 10.0.0.0/16 |
| availability_zones | List of availability zones | ["us-east-1a", "us-east-1b", "us-east-1c"] |
| private_subnet_cidrs | CIDR blocks for private subnets | ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] |
| public_subnet_cidrs | CIDR blocks for public subnets | ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"] |
| kafka_version | Kafka version for MSK cluster | 2.8.1 |
| broker_instance_type | Instance type for MSK broker nodes | kafka.m5.large |
| number_of_broker_nodes | Number of broker nodes in the MSK cluster | 3 |
| rds_endpoint | Endpoint of the existing RDS Aurora database | (required) |
| rds_port | Port of the existing RDS Aurora database | 3306 |
| rds_database_name | Name of the database in the existing RDS Aurora instance | (required) |
| rds_username | Username for the existing RDS Aurora database | (required) |
| rds_password | Password for the existing RDS Aurora database | (required) |

## Outputs

| Output | Description |
|--------|-------------|
| vpc_id | ID of the VPC |
| msk_cluster_arn | ARN of the MSK cluster |
| msk_bootstrap_brokers | Bootstrap brokers for the MSK cluster |
| msk_zookeeper_connect_string | Zookeeper connection string for the MSK cluster |
| debezium_connector_status | Status of the Debezium connector |

## Cleanup

To destroy the infrastructure:
```
terraform destroy
```

## Notes

- The Debezium connector is configured to connect to an existing RDS Aurora database.
- The connector uses the MySQL connector as Aurora is MySQL-compatible.
- The connector configuration can be customized in the `modules/debezium/main.tf` file.
- Sensitive information like database credentials are stored in AWS Secrets Manager. 