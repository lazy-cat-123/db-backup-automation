#!/bin/bash

# Database user (environment variables)
if [ -f .env ]; then
	set -a
	source .env
	set +a
else
	echo "Error: .env file not found!"
	exit 1
fi

echo "Connecting as: $DB_USERNAME"

# Database Backup Configuration
CONTAINER_NAME=$CONTAINER_NAME
DB_NAME=$DB_NAME
BACKUP_DIR="/your-project-directory-path/backup"
RETENTION_DAYS=7 # Define the days the backup file store.
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILE_NAME="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql.gz"
LOG_FILE_NAME="$BACKUP_DIR/backup_log.log"

#Python venv path
PYTHON_VENV_ACTIVATE_PATH="/your-venv-path/bin/activate"
PYTHON_EXEC_PATH="/your-venv-path/bin/python3"
PYTHON_NOTIF_SCRIPT_PATH="/your-project-directory-path/send_notif.py"

# Create backup folder is it doesn't exist yet.
if [ -d "$BACKUP_DIR" ]; then
	echo "[$TIMESTAMP] Backup folder is already exists." | tee -a "$LOG_FILE_NAME"
else
	mkdir -p "$BACKUP_DIR"
	echo "[$TIMESTAMP] Backup folder is craeted" | tee -a "$LOG_FILE_NAME"
fi

# Create temp file.
TEMP_FILE="${FILE_NAME}.tmp"

# --- Start Database Backup ---
echo "[$TIMESTAMP] Starting backup for $DB_NAME ..." | tee -a "$LOG_FILE_NAME"

# create mysqldump file and zip the file using gzip
docker exec $CONTAINER_NAME mysqldump -u "$DB_USERNAME" -p"$DB_PASSWD" "$DB_NAME" | gzip > "$TEMP_FILE"

# ensure exit status
if [ $? -eq 0 ]; then
	mv "$TEMP_FILE" "$FILE_NAME"
	MSG="Success: Backup database $DB_NAME completed."
	echo "[$TIMESTAMP] $MSG" | tee -a "$LOG_FILE_NAME"
	# Notification on email
	source "$PYTHON_VENV_ACTIVATE_PATH"
	"$PYTHON_EXEC_PATH" "$PYTHON_NOTIF_SCRIPT_PATH" "Backup Success: $DB_NAME" "The backup was successful at $TIMESTAMP. File: $FILE_NAME" 
else
	rm -f "$TEMP_FILE"
	MSG="Error: Backup database $DB_NAME failed."
	echo "[$TIMESTAMP] $MSG" | tee -a "$LOG_FILE_NAME"
	# Notification on email
	source "$PYTHON_VENV_ACTIVATE_PATH"
	"$PYTHON_EXEC_PATH" "$PYTHON_NOTIF_SCRIPT_PATH" "Backup Failed: $DB_NAME" "Error occurred at $TIMESTAMP. Please check the logs at $LOG_FILE_NAME"
fi

# --- Retention Policy ---
# Remove old mysqldump files.
# Count files before deleting.
COUNT_BEFORE=$(find "$BACKUP_DIR" -type f -name "*.sql.gz" | wc -l)

# Remove old files.
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete 

# Count files after deleting.
COUNT_AFTER=$(find "$BACKUP_DIR" -type f -name "*.sql.gz" | wc -l)

# Compare before and after.
DELETED_COUNT=$((COUNT_BEFORE - COUNT_AFTER))

# Show log if the delete process affected.
if [ $DELETED_COUNT -gt 0 ]; then
	echo "[$TIMESTAMP] Old backups (over $RETENTION_DAYS days) cleaned up." | tee -a "$LOG_FILE_NAME"
fi

echo "----------------------------------------------" >> "$LOG_FILE_NAME"
