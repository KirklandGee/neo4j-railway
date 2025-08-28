#!/bin/bash
# Simple Neo4j restore script

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -la /var/lib/neo4j/backups/backup-* 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"
NEO4J_HOST="${NEO4J_HOST:-localhost}"
NEO4J_USERNAME="${NEO4J_USERNAME:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD}"
NEO4J_URI="bolt://${NEO4J_HOST}:7687"

echo "🔄 Starting restore from $(basename "$BACKUP_FILE")"

# Verify backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check connectivity
if ! cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" "RETURN 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Neo4j"
    exit 1
fi

# Warning
echo "⚠️  This will DELETE ALL existing data!"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restore cancelled"
    exit 0
fi

# Clear database
echo "🧹 Clearing existing data..."
cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" \
    "MATCH (n) DETACH DELETE n;"

# Prepare file for import
IMPORT_FILE="$BACKUP_FILE"
TEMP_FILE=""

# Handle compressed files
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "🗜️  Decompressing backup..."
    TEMP_FILE="/tmp/restore-$(basename "$BACKUP_FILE" .gz)"
    gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"
    IMPORT_FILE="$TEMP_FILE"
fi

# Import data
echo "📥 Importing data..."
cat "$IMPORT_FILE" | cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD"

# Clean up temp file
if [ -n "$TEMP_FILE" ] && [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"
fi

# Verify restoration
NODES=$(cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" --format plain "MATCH (n) RETURN count(n);" | tail -n 1)
RELS=$(cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" --format plain "MATCH ()-[r]->() RETURN count(r);" | tail -n 1)

echo "✅ Restore completed!"
echo "📊 Restored: $NODES nodes, $RELS relationships"