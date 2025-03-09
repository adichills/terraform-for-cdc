output "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.msk.arn
}

output "bootstrap_brokers" {
  description = "Bootstrap brokers for the MSK cluster (plaintext)"
  value       = aws_msk_cluster.msk.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "Bootstrap brokers for the MSK cluster (TLS)"
  value       = aws_msk_cluster.msk.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  description = "Zookeeper connection string for the MSK cluster"
  value       = aws_msk_cluster.msk.zookeeper_connect_string
}

output "debezium_plugin_arn" {
  description = "ARN of the Debezium custom plugin"
  value       = aws_mskconnect_custom_plugin.debezium.arn
}

output "msk_connect_role_arn" {
  description = "ARN of the MSK Connect IAM role"
  value       = aws_iam_role.msk_connect.arn
} 