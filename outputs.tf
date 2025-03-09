output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = module.msk.msk_cluster_arn
}

output "msk_bootstrap_brokers" {
  description = "Bootstrap brokers for the MSK cluster"
  value       = module.msk.bootstrap_brokers
}

output "msk_zookeeper_connect_string" {
  description = "Zookeeper connection string for the MSK cluster"
  value       = module.msk.zookeeper_connect_string
}

output "debezium_connector_status" {
  description = "Status of the Debezium connector"
  value       = module.debezium_connector.connector_status
} 