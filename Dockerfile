FROM neo4j:2025.04-community

# Install required tools and download APOC Extended for production
RUN apt-get update && apt-get install -y curl cron jq gosu wget && \
    mkdir -p /var/lib/neo4j/plugins && \
    wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/2025.04.0/apoc-2025.04.0-extended.jar \
    -O /var/lib/neo4j/plugins/apoc-2025.04.0-extended.jar && \
    chmod 644 /var/lib/neo4j/plugins/apoc-2025.04.0-extended.jar && \
    chown neo4j:neo4j /var/lib/neo4j/plugins/apoc-2025.04.0-extended.jar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy configuration and scripts
COPY neo4j.conf /var/lib/neo4j/conf/neo4j.conf
COPY apoc.conf /var/lib/neo4j/conf/apoc.conf
COPY scripts/ /usr/local/bin/
COPY init.sh /docker-entrypoint-initdb.d/
COPY docker-entrypoint.sh /usr/local/bin/railway-entrypoint.sh

# Set up directories and permissions
RUN mkdir -p /var/lib/neo4j/backups /var/log /data && \
    chown -R neo4j:neo4j /var/lib/neo4j /var/log /data && \
    chmod -R 755 /data && \
    chmod +x /usr/local/bin/*

# Don't switch to neo4j user yet - let entrypoint handle permissions first
EXPOSE 7474 7687

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh

# Use custom entrypoint that handles Railway volume permissions
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["neo4j"]