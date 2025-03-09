provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  project_name         = var.project_name
}

module "msk" {
  source = "./modules/msk"
  
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.default_security_group_id]
  
  kafka_version      = var.kafka_version
  broker_instance_type = var.broker_instance_type
  number_of_broker_nodes = var.number_of_broker_nodes
  
  depends_on = [module.vpc]
}

module "debezium_connector" {
  source = "./modules/debezium"
  
  project_name       = var.project_name
  msk_cluster_arn    = module.msk.msk_cluster_arn
  msk_bootstrap_brokers = module.msk.bootstrap_brokers
  
  rds_endpoint       = var.rds_endpoint
  rds_port           = var.rds_port
  rds_database_name  = var.rds_database_name
  rds_username       = var.rds_username
  rds_password       = var.rds_password
  
  depends_on = [module.msk]
} 