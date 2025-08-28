#!/bin/bash
# Simple Neo4j backup script

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/lib/neo4j/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup-${DATE}.cypher"

NEO4J_HOST="${NEO4J_HOST:-localhost}"
NEO4J_USERNAME="${NEO4J_USERNAME:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD}"
NEO4J_URI="bolt://${NEO4J_HOST}:7687"

echo "🔄 Starting backup at $(date)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check connectivity
if ! cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" "RETURN 1;" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Neo4j"
    exit 1
fi

# Create backup using APOC
echo "📤 Exporting data..."
cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" \
    "CALL apoc.export.cypher.all('${BACKUP_FILE}', {
        format: 'cypher-shell',
        useOptimizations: {type: 'UNWIND_BATCH', unwindBatchSize: 20}
    })
    YIELD file, nodes, relationships, time
    RETURN file, nodes, relationships, time;"

# Verify backup was created
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(stat -c%s "$BACKUP_FILE" 2>/dev/null || stat -f%z "$BACKUP_FILE" 2>/dev/null)
    echo "✅ Backup created: $(basename "$BACKUP_FILE") ($(($SIZE / 1024)) KB)"
else
    echo "❌ Backup failed"
    exit 1
fi

# Compress backup
if command -v gzip > /dev/null; then
    gzip "$BACKUP_FILE"
    echo "🗜️  Backup compressed"
fi

# Clean up old backups
if [ "$RETENTION_DAYS" -gt 0 ]; then
    DELETED=$(find "$BACKUP_DIR" -name "backup-*" -type f -mtime +${RETENTION_DAYS} -delete -print | wc -l)
    if [ "$DELETED" -gt 0 ]; then
        echo "🧹 Cleaned up $DELETED old backups"
    fi
fi

echo "🎉 Backup completed successfully"