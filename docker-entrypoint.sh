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

# Ensure APOC plugins are readable by neo4j user
echo "🔧 Setting up APOC plugin permissions..."
chown -R neo4j:neo4j /var/lib/neo4j/plugins 2>/dev/null || echo "⚠️ Could not change plugin ownership (expected on Railway)"
chmod -R 644 /var/lib/neo4j/plugins/*.jar 2>/dev/null || true

echo "🚀 Calling original Neo4j entrypoint..."

# Call the original Neo4j entrypoint at its actual location
exec /startup/docker-entrypoint.sh "$@"
