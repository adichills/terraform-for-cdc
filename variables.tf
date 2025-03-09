variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "debezium-msk"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# MSK Variables
variable "kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
  default     = "2.8.1"
}

variable "broker_instance_type" {
  description = "Instance type for MSK broker nodes"
  type        = string
  default     = "kafka.m5.large"
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the MSK cluster"
  type        = number
  default     = 3
}

# RDS Aurora Variables (existing database)
variable "rds_endpoint" {
  description = "Endpoint of the existing RDS Aurora database"
  type        = string
}

variable "rds_port" {
  description = "Port of the existing RDS Aurora database"
  type        = number
  default     = 3306
}

variable "rds_database_name" {
  description = "Name of the database in the existing RDS Aurora instance"
  type        = string
}

variable "rds_username" {
  description = "Username for the existing RDS Aurora database"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "Password for the existing RDS Aurora database"
  type        = string
  sensitive   = true
} 