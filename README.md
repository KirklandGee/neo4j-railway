# Neo4j for Railway

Clean, production-ready Neo4j setup with automated backups and monitoring.

## 🚀 Quick Setup

### 1. Create New Railway Service
- Create new service in Railway
- Connect this repository
- Railway will automatically use `railway.json` config

### 2. Environment Variables (Railway)
Set these in your Railway service:
```bash
NEO4J_AUTH=neo4j/your-secure-password
```

### 3. Add Persistent Volume
**Important**: Add a volume mounted to `/data` in Railway to persist your database.

### 4. Deploy
Railway will build and deploy automatically.

## 🔧 Configuration

### Memory Settings
Edit `neo4j.conf` to match your Railway plan:

**Starter Plan:**
```
server.memory.heap.max_size=128m
server.memory.pagecache.size=64m
```

**Developer Plan (default):**
```
server.memory.heap.max_size=256m
server.memory.pagecache.size=128m
```

**Pro Plan:**
```
server.memory.heap.max_size=512m
server.memory.pagecache.size=256m
```

## 🛠️ Available Scripts

All scripts are available inside the container:

### Backup & Restore
```bash
# Manual backup
railway run /usr/local/bin/backup.sh

# List backups
railway run ls -la /var/lib/neo4j/backups/

# Restore from backup
railway run /usr/local/bin/restore.sh /var/lib/neo4j/backups/backup-YYYYMMDD_HHMMSS.cypher.gz
```

### Monitoring
```bash
# Health check
railway run /usr/local/bin/monitor.sh

# Check logs
railway logs
```

## 📊 Features

### ✅ Included
- **Neo4j 5.15** with APOC procedures
- **Automated daily backups** (2 AM)
- **Health monitoring**
- **Compressed backups** with 7-day retention
- **Simple restore** process
- **Railway optimized** configuration

### 🔗 Connect from Your App
In your main application, use:
```bash
NEO4J_URI=bolt://neo4j-service-name:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your-secure-password
```

## 🚨 Important Notes

1. **Always set up persistent volume** for `/data` in Railway
2. **Change the default password** in `NEO4J_AUTH`
3. **Backups are stored in the container** - consider external backup strategy for production
4. **Monitor memory usage** and adjust config as needed

## 🔄 Migration from Aura

### Export from Aura
```bash
# In Neo4j Browser on Aura:
CALL apoc.export.cypher.all("aura-export.cypher", {format: "cypher-shell"})
```

### Import to Railway
1. Copy your export file to the Railway container
2. Run: `railway run /usr/local/bin/restore.sh /path/to/aura-export.cypher`

## 📈 Scaling

As your database grows:
1. **Upgrade Railway plan** for more memory/CPU
2. **Adjust memory settings** in `neo4j.conf`
3. **Consider read replicas** for high-traffic apps
4. **Set up external backup storage** (S3, etc.)

---

**Simple, reliable, and production-ready Neo4j hosting on Railway! 🚀**