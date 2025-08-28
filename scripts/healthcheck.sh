#!/bin/bash
# Simple health check for Railway

NEO4J_HOST=${NEO4J_HOST:-localhost}
NEO4J_USERNAME=${NEO4J_USERNAME:-neo4j}
NEO4J_PASSWORD=${NEO4J_PASSWORD:-neo4j}

# Check if Neo4j is responding
if cypher-shell -a "bolt://${NEO4J_HOST}:7687" -u "${NEO4J_USERNAME}" -p "${NEO4J_PASSWORD}" "RETURN 1;" > /dev/null 2>&1; then
    exit 0
else
    exit 1
fi