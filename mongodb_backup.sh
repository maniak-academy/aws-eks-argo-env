#!/bin/bash

# Set environment variables
export PATH=$PATH:/usr/local/bin
export HOME=/home/ubuntu  # Assuming Ubuntu user

# Directory paths
MONGO_LOGS_DIR="$HOME/mongologs"
BACKUP_DIR="/home/ubuntu/mongo"
S3_BUCKET="s3://eks-wiz-mongodb-bucket/backups"
S3_BUCKET_LOGS="s3://eks-wiz-mongodb-bucket/logs/"

# Check if username and password are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <MongoDB Username> <MongoDB Password>"
    exit 1
fi

MONGODB_USER="$1"
MONGODB_PASSWORD="$2"

# Create mongologs directory if it doesn't exist
mkdir -p "$MONGO_LOGS_DIR"

# Set logfile path
LOGFILE="$MONGO_LOGS_DIR/$(date +'%Y%m%d_%H%M').log"

# Redirect stdout and stderr to the logfile
exec &>> "$LOGFILE"

# Run mongodump command with provided credentials
mongodump --uri "mongodb://${MONGODB_USER}:${MONGODB_PASSWORD}@localhost:27017/toDoApp?authSource=admin" --out "$BACKUP_DIR/$(date +'%Y%m%d_%H%M%S')"

# Check if mongodump was successful
if [ $? -ne 0 ]; then
    echo "Error: mongodump command failed. Backup process aborted."
    exit 1
fi

# Create a tar archive of the backup directory
tar -czf "$BACKUP_DIR/backup_$(date +'%Y%m%d_%H%M%S').tar.gz" -C "$BACKUP_DIR/$(date +'%Y%m%d_%H%M%S')" .

# Check if tar command was successful
if [ $? -ne 0 ]; then
    echo "Error: Tar command failed. Backup process aborted."
    exit 1
fi

# Upload the entire backup directory to the AWS S3 bucket
aws s3 cp "$BACKUP_DIR" "$S3_BUCKET" --recursive

# Check if AWS S3 copy was successful
if [ $? -ne 0 ]; then
    echo "Error: AWS S3 copy failed. Backup process aborted."
    exit 1
fi

# Upload the logfile to the logs folder in the S3 bucket
aws s3 cp "$LOGFILE" "$S3_BUCKET_LOGS"

# Check if logfile upload was successful
if [ $? -ne 0 ]; then
    echo "Error: Logfile S3 upload failed. Backup process aborted."
    exit 1
fi

# Clean up temporary files
rm -rf "$BACKUP_DIR/*"
