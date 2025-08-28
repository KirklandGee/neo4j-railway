FROM neo4j:5.15-community

# Install APOC and required tools
RUN apt-get update && apt-get install -y curl cron jq && \
    curl -L https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/5.15.0/apoc-5.15.0-core.jar \
    -o /var/lib/neo4j/plugins/apoc-5.15.0-core.jar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy configuration and scripts
COPY neo4j.conf /var/lib/neo4j/conf/neo4j.conf
COPY apoc.conf /var/lib/neo4j/conf/apoc.conf
COPY scripts/ /usr/local/bin/
COPY init.sh /docker-entrypoint-initdb.d/

# Set up directories and permissions
RUN mkdir -p /var/lib/neo4j/backups /var/log && \
    chown -R neo4j:neo4j /var/lib/neo4j /var/log && \
    chmod +x /usr/local/bin/* /docker-entrypoint-initdb.d/*

USER neo4j
EXPOSE 7474 7687

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh

CMD ["neo4j", "console"]