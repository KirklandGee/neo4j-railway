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

echo "🚀 Calling original Neo4j entrypoint..."

# Call the original Neo4j entrypoint at its actual location
exec /startup/docker-entrypoint.sh "$@"
