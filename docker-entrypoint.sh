#!/bin/bash
# Railway-specific Neo4j entrypoint to handle volume permissions

set -e

# Fix permissions for Railway mounted volume
if [ -d "/data" ]; then
    echo "🔧 Setting up /data directory permissions..."
    
    # Ensure neo4j user owns the data directory
    chown -R neo4j:neo4j /data 2>/dev/null || echo "⚠️ Could not change ownership (expected on Railway)"
    
    # Ensure the directory is writable
    chmod -R 755 /data 2>/dev/null || echo "⚠️ Could not change permissions (expected on Railway)"
    
    # Create necessary subdirectories
    mkdir -p /data/databases /data/transactions /data/logs 2>/dev/null || true
fi

echo "🚀 Starting Neo4j as neo4j user..."

# Switch to neo4j user and run Neo4j
exec gosu neo4j neo4j console