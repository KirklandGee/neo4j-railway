#!/bin/bash
# Set up automated backups

echo "⚙️  Setting up automated backups..."

# Create cron job for daily backups at 2 AM
CRON_JOB="0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1"

# Add to crontab
echo "$CRON_JOB" | crontab -

# Start cron daemon
service cron start

echo "✅ Automated backups configured (daily at 2 AM)"
echo "📋 Logs: /var/log/backup.log"