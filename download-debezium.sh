#!/bin/bash

# Script to download and prepare the Debezium MySQL connector

echo "Downloading Debezium MySQL connector..."
curl -L https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/1.9.6.Final/debezium-connector-mysql-1.9.6.Final-plugin.tar.gz -o debezium-connector-mysql.tar.gz

echo "Extracting connector files..."
mkdir -p temp
tar -xzf debezium-connector-mysql.tar.gz -C temp

echo "Creating zip file for MSK Connect..."
mkdir -p modules/msk/files
cd temp
zip -r ../modules/msk/files/debezium-connector-mysql.zip .
cd ..

echo "Cleaning up temporary files..."
rm -rf temp debezium-connector-mysql.tar.gz

echo "Debezium connector prepared successfully!" 