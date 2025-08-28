#!/bin/bash
# Initialize Neo4j with backups enabled

echo "🚀 Initializing Neo4j with automated backups..."

# Set up cron for automated backups
/usr/local/bin/setup-cron.sh

echo "✅ Neo4j initialization complete"