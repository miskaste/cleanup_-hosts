# cleanup_hosts.sh
# macOS Hosts File Cleanup Script

A comprehensive solution for automatically removing IP address entries starting with "194.*" from the macOS `/etc/hosts` file on a scheduled basis.

## Overview

The `/etc/hosts` file is a system file that maps hostnames to IP addresses, functioning as a local DNS on macOS. This script provides a safe and automated way to remove specific IP address entries while maintaining system integrity through backups, logging, and proper permission handling.

## Features

- **Safe removal** of 194.* IP entries from `/etc/hosts`
- **Automatic backups** before making changes
- **Comprehensive logging** with timestamps
- **DNS cache flushing** for immediate effect
- **Multiple scheduling options** (launchd and crontab)
- **Error handling** and validation
- **Production-ready** with proper permissions and ownership

## Requirements

- macOS system
- Administrative (root) privileges
- Bash shell

## Installation

### 1. Download and Setup Script

```bash
# Make the script executable and place it in the system directory
sudo cp cleanup_hosts.sh /usr/local/bin/
sudo chmod 755 /usr/local/bin/cleanup_hosts.sh
sudo chown root:wheel /usr/local/bin/cleanup_hosts.sh
```

### 2. Verify Installation

Test the script manually:

```bash
sudo /usr/local/bin/cleanup_hosts.sh
```

## Scheduling Options

### Method 1: Using launchd (Recommended)

Launchd is the native macOS scheduling system and offers better reliability and flexibility.

#### Create Launch Daemon

Create the plist file at `/Library/LaunchDaemons/com.local.cleanup_hosts.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.cleanup_hosts</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/cleanup_hosts.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>0</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/var/log/cleanup_hosts_error.log</string>
    <key>StandardOutPath</key>
    <string>/var/log/cleanup_hosts_output.log</string>
</dict>
</plist>
```

#### Load the Launch Daemon

```bash
sudo launchctl load -w /Library/LaunchDaemons/com.local.cleanup_hosts.plist
```

#### Verify Installation

```bash
sudo launchctl list | grep cleanup_hosts
```

### Method 2: Using Crontab

Alternative scheduling method using traditional Unix cron:

```bash
# Edit root crontab
sudo crontab -e

# Add this line to run daily at midnight
0 0 * * * /usr/local/bin/cleanup_hosts.sh
```

## Script Features

### Basic Functionality

- Identifies and removes lines starting with "194." from `/etc/hosts`
- Creates temporary files for safe processing
- Validates changes before applying
- Sets correct file permissions (644)
- Flushes DNS cache for immediate effect

### Enhanced Features

- **Timestamped logging** to `/var/log/hosts_cleaner.log`
- **Automatic backups** with timestamp naming
- **Error detection** and graceful handling
- **Change verification** before modification
- **Cleanup** of temporary files

## Log Files

The script generates several log files:

- `/var/log/hosts_cleaner.log` - Main activity log
- `/var/log/cleanup_hosts_output.log` - Standard output (launchd)
- `/var/log/cleanup_hosts_error.log` - Error output (launchd)

## Backup Files

Automatic backups are created at `/etc/hosts.backup.YYYYMMDDHHMMSS` before each modification.

## Troubleshooting

### Changes Not Taking Effect

If modifications don't apply immediately:

```bash
# Manually flush DNS cache
sudo killall -HUP mDNSResponder

# Check system logs
tail -f /var/log/hosts_cleaner.log
```

### Permission Issues

Ensure proper permissions:

```bash
sudo chmod 755 /usr/local/bin/cleanup_hosts.sh
sudo chown root:wheel /usr/local/bin/cleanup_hosts.sh
```

### Scheduled Task Not Running

**For launchd:**
```bash
# Check if daemon is loaded
sudo launchctl list | grep cleanup_hosts

# Reload if necessary
sudo launchctl unload /Library/LaunchDaemons/com.local.cleanup_hosts.plist
sudo launchctl load -w /Library/LaunchDaemons/com.local.cleanup_hosts.plist
```

**For crontab:**
```bash
# Verify crontab entry
sudo crontab -l
```

### View Recent Activity

```bash
# Check recent logs
tail -20 /var/log/hosts_cleaner.log

# Monitor real-time
tail -f /var/log/hosts_cleaner.log
```

## Uninstallation

### Remove launchd Daemon

```bash
sudo launchctl unload -w /Library/LaunchDaemons/com.local.cleanup_hosts.plist
sudo rm /Library/LaunchDaemons/com.local.cleanup_hosts.plist
```

### Remove Crontab Entry

```bash
sudo crontab -e
# Delete the cleanup_hosts.sh line and save
```

### Remove Files

```bash
sudo rm /usr/local/bin/cleanup_hosts.sh
sudo rm /var/log/hosts_cleaner.log
sudo rm /var/log/cleanup_hosts_*.log
```

## Safety Features

- **Backup creation** before every modification
- **Change validation** to prevent unnecessary writes
- **Temporary file processing** to avoid corruption
- **Permission verification** and restoration
- **Comprehensive logging** for audit trails

## Customization

To target different IP ranges, modify the grep pattern in the script:

```bash
# Current: removes 194.*
grep -v "^194\." "$HOSTS_FILE" > "$TMP_FILE"

# Example: remove 192.168.*
grep -v "^192\.168\." "$HOSTS_FILE" > "$TMP_FILE"
```

## Contributing

Contributions are welcome! Please ensure any modifications maintain the safety features and logging capabilities.

## License

[Add your license information here]

## References

This implementation follows macOS best practices for system file modification and automated task scheduling.
