#!/bin/bash

# Slack webhook URL
slack_webhook_url="https://hooks.slack.com/services/your-slack-webhook-url"

# MySQL database credentials
mysql_user="your-mysql-username"
mysql_password="your-mysql-password"
mysql_database="your-database-name"

# Backup directory
backup_dir="/path/to/backup/directory"

# Format current date and time
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%H-%M-%S")

# Filename for the backup
backup_filename="${backup_dir}/${current_date}_${current_time}_backup.sql.gz"

# MySQL dump command
mysqldump_cmd="mysqldump --user=${mysql_user} --password=${mysql_password} ${mysql_database} | gzip > ${backup_filename}"

# Perform the backup
eval "$mysqldump_cmd"

# Check if backup was successful
if [ $? -eq 0 ]; then
    # Backup succeeded, send Slack notification
    slack_message="MySQL backup completed successfully: ${backup_filename}"
else
    # Backup failed, send Slack notification
    slack_message="MySQL backup failed"
fi

# Send Slack notification
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${slack_message}\"}" "${slack_webhook_url}"
