variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs of the security groups"
  type        = list(string)
}

variable "kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
}

variable "broker_instance_type" {
  description = "Instance type for MSK broker nodes"
  type        = string
}

variable "number_of_broker_nodes" {
  description = "Number of broker nodes in the MSK cluster"
  type        = number
} 