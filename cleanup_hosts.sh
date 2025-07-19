#!/bin/bash

# File path to hosts file
HOSTS_FILE="/etc/hosts"
LOG_FILE="/var/log/hosts_cleaner.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" > /dev/null
}

log "Starting 198.* entries removal process"

# Create a temporary file
TMP_FILE=$(mktemp)
log "Created temporary file: $TMP_FILE"

# Filter out lines starting with "198." and write to temporary file
grep -v "^198\." "$HOSTS_FILE" > "$TMP_FILE"

# Check if any changes were made
if diff -q "$HOSTS_FILE" "$TMP_FILE" >/dev/null; then
    log "No 198.* entries found in hosts file."
    rm "$TMP_FILE"
    exit 0
fi

# Backup the original file
BACKUP_FILE="/etc/hosts.backup.$(date '+%Y%m%d%H%M%S')"
sudo cp "$HOSTS_FILE" "$BACKUP_FILE"
log "Created backup at $BACKUP_FILE"

# Copy the modified file back to hosts file
sudo cp "$TMP_FILE" "$HOSTS_FILE"
log "Applied changes to hosts file"

# Set correct permissions
sudo chmod 644 "$HOSTS_FILE"
log "Set permissions on hosts file"

# Flush DNS cache to apply changes
sudo killall -HUP mDNSResponder
log "Flushed DNS cache"

log "Successfully removed 198.* entries from hosts file"

# Clean up
rm "$TMP_FILE"
log "Removed temporary file"
