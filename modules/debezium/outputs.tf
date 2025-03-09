output "connector_status" {
  description = "Status of the Debezium connector"
  value       = aws_mskconnect_connector.debezium.state
}

output "connector_arn" {
  description = "ARN of the Debezium connector"
  value       = aws_mskconnect_connector.debezium.arn
} 