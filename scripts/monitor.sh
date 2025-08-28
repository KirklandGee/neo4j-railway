#!/bin/bash
# Simple Neo4j monitoring script

NEO4J_HOST="${NEO4J_HOST:-localhost}"
NEO4J_USERNAME="${NEO4J_USERNAME:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD}"
NEO4J_URI="bolt://${NEO4J_HOST}:7687"

echo "🔍 Neo4j Health Check - $(date)"
echo "================================"

# Basic connectivity
if cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" "RETURN 1;" > /dev/null 2>&1; then
    echo "✅ Database responding"
else
    echo "❌ Database not responding"
    exit 1
fi

# Database stats
echo ""
echo "📊 Database Statistics:"
NODES=$(cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" --format plain "MATCH (n) RETURN count(n);" | tail -n 1)
RELS=$(cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" --format plain "MATCH ()-[r]->() RETURN count(r);" | tail -n 1)
CONNECTIONS=$(cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" --format plain "CALL dbms.listConnections() YIELD connectionId RETURN count(connectionId);" | tail -n 1 2>/dev/null || echo "N/A")

echo "   Nodes: $NODES"
echo "   Relationships: $RELS" 
echo "   Active Connections: $CONNECTIONS"

# APOC check
echo ""
echo "🔧 APOC Status:"
if cypher-shell -a "$NEO4J_URI" -u "$NEO4J_USERNAME" -p "$NEO4J_PASSWORD" "RETURN apoc.version();" > /dev/null 2>&1; then
    echo "✅ APOC procedures available"
else
    echo "❌ APOC procedures not available"
fi

# Disk usage (if accessible)
echo ""
echo "💾 Storage:"
if [ -d "/var/lib/neo4j/data" ]; then
    du -sh /var/lib/neo4j/data 2>/dev/null || echo "   Data directory size: N/A"
else
    echo "   Data directory: N/A"
fi

# Recent backups
echo ""
echo "💾 Recent Backups:"
if [ -d "/var/lib/neo4j/backups" ]; then
    ls -la /var/lib/neo4j/backups/backup-* 2>/dev/null | tail -3 || echo "   No backups found"
else
    echo "   Backup directory not found"
fi

echo ""
echo "✅ Health check completed"