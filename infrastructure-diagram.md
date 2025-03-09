# AWS MSK with Debezium Connector Infrastructure Diagram

```mermaid
graph TD
    %% Main Components
    User((User))
    VPC[AWS VPC]
    MSK[AWS MSK Cluster]
    Debezium[Debezium Connector]
    RDS[Existing RDS Aurora]
    S3[S3 Bucket]
    IAM[IAM Roles & Policies]
    Secrets[AWS Secrets Manager]
    
    %% VPC Components
    PublicSubnets[Public Subnets]
    PrivateSubnets[Private Subnets]
    IGW[Internet Gateway]
    NAT[NAT Gateway]
    SG[Security Groups]
    
    %% MSK Components
    Brokers[Kafka Brokers]
    ZK[ZooKeeper]
    KMS[KMS Encryption]
    CWLogs[CloudWatch Logs]
    
    %% Relationships
    User -->|Deploys| VPC
    User -->|Deploys| MSK
    User -->|Configures| Debezium
    User -->|References| RDS
    
    %% VPC Structure
    VPC --> PublicSubnets
    VPC --> PrivateSubnets
    VPC --> IGW
    VPC --> NAT
    VPC --> SG
    PublicSubnets -->|Hosts| NAT
    IGW -->|Connects to| PublicSubnets
    NAT -->|Provides Internet to| PrivateSubnets
    
    %% MSK Structure
    MSK -->|Runs in| PrivateSubnets
    MSK -->|Uses| SG
    MSK -->|Contains| Brokers
    MSK -->|Contains| ZK
    MSK -->|Uses| KMS
    MSK -->|Logs to| CWLogs
    
    %% Debezium Structure
    Debezium -->|Connects to| MSK
    Debezium -->|Captures changes from| RDS
    Debezium -->|Uses plugin from| S3
    Debezium -->|Uses| IAM
    Debezium -->|Logs to| CWLogs
    
    %% Security
    IAM -->|Grants access to| S3
    IAM -->|Grants access to| MSK
    IAM -->|Grants access to| Secrets
    Secrets -->|Stores| RDS
    
    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,color:white
    classDef network fill:#3F8624,stroke:#294D16,color:white
    classDef security fill:#C7131F,stroke:#7A0C12,color:white
    classDef database fill:#2E73B8,stroke:#1A4572,color:white
    
    class VPC,MSK,S3,CWLogs,KMS,Secrets aws
    class PublicSubnets,PrivateSubnets,IGW,NAT,SG network
    class IAM security
    class RDS,Brokers,ZK,Debezium database
```

## Infrastructure Components Explanation

### VPC and Networking
- **VPC**: Contains all the infrastructure components
- **Public Subnets**: Host the NAT Gateway and provide external access
- **Private Subnets**: Host the MSK cluster and other private resources
- **Internet Gateway**: Provides internet access to public subnets
- **NAT Gateway**: Allows private subnet resources to access the internet
- **Security Groups**: Control traffic between resources

### MSK Cluster
- **Kafka Brokers**: The core of the MSK cluster, running Apache Kafka
- **ZooKeeper**: Manages the Kafka cluster state
- **KMS Encryption**: Provides encryption at rest for the MSK cluster
- **CloudWatch Logs**: Stores logs from the MSK cluster

### Debezium Connector
- **Connector**: Captures change data from the RDS Aurora database
- **S3 Bucket**: Stores the Debezium connector plugin
- **IAM Roles & Policies**: Provide necessary permissions
- **Secrets Manager**: Securely stores database credentials

### External Resources
- **RDS Aurora**: The existing database from which changes are captured

This architecture enables Change Data Capture (CDC) from your RDS Aurora database to Kafka topics in the MSK cluster, allowing real-time data streaming and event-driven architectures. 