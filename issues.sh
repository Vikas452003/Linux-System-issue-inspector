#!/bin/bash

while true; do
  echo " Production Issue Solver Menu "
  echo "=============================="
  echo "1. Check Disk Space"
  echo "2. Rotate Logs"
  echo "3. Restart a Service"
  echo "4. Backup a Directory"
  echo "5. Check CPU/Memory Usage"
  echo "6. Exit"
  echo "=============================="
  read -p "Enter your choice [1-6]: " choice

  case $choice in
    1)
      echo "Checking disk space..."
      df -h
      ;;

    2)
      echo "Rotating logs..."
      read -p "Enter the full path of the logfile: " LOGFILE
      if [ -f "$LOGFILE" ]; then
        NEWFILE="$LOGFILE.$(date +%F)"
        mv "$LOGFILE" "$NEWFILE"
        gzip "$NEWFILE"
        echo "Logs rotated and compressed: $NEWFILE.gz"
      else
        echo "Log file not found at $LOGFILE!"
      fi
      ;;

    3)
      read -p "Enter service name to restart: " service
      echo "Restarting $service..."
      if systemctl list-unit-files | grep -q "^$service.service"; then
        systemctl restart "$service"
        systemctl status "$service" --no-pager
       else
        echo "Service '$service' is not installed on this system."
      fi
      ;;

    4)
      read -p "Enter directory to backup: " dir
      BACKUP="/tmp/backup_$(date +%F).tar.gz"
      if [ -d "$dir" ]; then
        if [ -w "/tmp" ]; then
          tar -czf "$BACKUP" "$dir"
          echo "Backup created at $BACKUP"
        else
          echo "Cannot write to /tmp. Check permissions!"
        fi
      else
        echo "Directory '$dir' does not exist!"
      fi
      ;;

    5)
      echo "Checking CPU and memory usage..."
      top -b -n 1 | head -n 15
      ;;

    6)
      echo "Exiting... Goodbye!"
      break
      ;;

    *)
      echo "Invalid choice! Please select between 1-6."
      ;;
  esac

  echo ""   # blank line for readability
done