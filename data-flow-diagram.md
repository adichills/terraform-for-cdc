# AWS MSK with Debezium Data Flow Diagram

```mermaid
flowchart LR
    %% Main Components
    subgraph AWS["AWS Cloud"]
        subgraph VPC["VPC"]
            subgraph PrivateSubnets["Private Subnets"]
                subgraph MSK["MSK Cluster"]
                    Broker1[("Broker 1")]
                    Broker2[("Broker 2")]
                    Broker3[("Broker 3")]
                    ZK1[("ZooKeeper 1")]
                    ZK2[("ZooKeeper 2")]
                    ZK3[("ZooKeeper 3")]
                end
                
                subgraph MSKConnect["MSK Connect"]
                    Debezium["Debezium Connector"]
                end
            end
            
            subgraph PublicSubnets["Public Subnets"]
                NAT["NAT Gateway"]
            end
        end
        
        RDS[("RDS Aurora\nDatabase")]
        S3["S3 Bucket\n(Connector Plugin)"]
        SecretsManager["Secrets Manager\n(DB Credentials)"]
        CloudWatch["CloudWatch Logs"]
    end
    
    %% External Components
    App["Application"]
    
    %% Data Flow
    RDS -->|1. Database Changes| Debezium
    S3 -->|2. Loads Plugin| Debezium
    SecretsManager -->|3. Provides Credentials| Debezium
    Debezium -->|4. Streams CDC Events| Broker1 & Broker2 & Broker3
    Broker1 & Broker2 & Broker3 -->|5. Stores Events in Topics| MSK
    App -->|6. Consumes Events| MSK
    
    %% Logging Flow
    Debezium -->|Logs| CloudWatch
    MSK -->|Logs| CloudWatch
    
    %% Coordination Flow
    Broker1 & Broker2 & Broker3 <-->|Coordination| ZK1 & ZK2 & ZK3
    
    %% Styling
    classDef aws fill:#FF9900,stroke:#232F3E,color:white
    classDef vpc fill:#3F8624,stroke:#294D16,color:white
    classDef subnet fill:#5A9C3B,stroke:#294D16,color:white
    classDef database fill:#2E73B8,stroke:#1A4572,color:white
    classDef broker fill:#CC2264,stroke:#7A1545,color:white
    classDef zk fill:#8C4FFF,stroke:#5A3399,color:white
    classDef app fill:#3B48CC,stroke:#232A7A,color:white
    
    class AWS aws
    class VPC vpc
    class PrivateSubnets,PublicSubnets subnet
    class RDS database
    class Broker1,Broker2,Broker3 broker
    class ZK1,ZK2,ZK3 zk
    class App app
```

## Data Flow Explanation

### 1. Database Changes Capture
- Changes in the RDS Aurora database (inserts, updates, deletes) are captured by the Debezium connector using the database's binary log.

### 2. Connector Plugin Loading
- The Debezium MySQL connector plugin is loaded from an S3 bucket into the MSK Connect service.

### 3. Secure Credential Management
- Database credentials are securely retrieved from AWS Secrets Manager by the connector.

### 4. Change Data Streaming
- Debezium formats the captured changes as events and streams them to the MSK cluster's Kafka brokers.

### 5. Topic Storage
- The Kafka brokers store these events in topics, organized by database tables.
- Each topic contains a sequence of change events for a specific table.

### 6. Application Consumption
- Applications can consume these change events from the Kafka topics in real-time.
- This enables event-driven architectures, data replication, and real-time analytics.

### Additional Flows
- **Logging**: Both MSK and the Debezium connector log to CloudWatch for monitoring and troubleshooting.
- **Coordination**: ZooKeeper nodes manage the Kafka cluster state, leader election, and configuration.

This architecture provides a robust, scalable solution for Change Data Capture (CDC) that can handle high throughput and maintain data consistency between systems. 