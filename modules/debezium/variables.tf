variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  type        = string
}

variable "msk_bootstrap_brokers" {
  description = "Bootstrap brokers for the MSK cluster"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the existing RDS Aurora database"
  type        = string
}

variable "rds_port" {
  description = "Port of the existing RDS Aurora database"
  type        = number
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