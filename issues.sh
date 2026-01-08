#!/bin/bash

while true; do
  # Display menu using a here-document
  cat <<EOF
   Production Issue Solver Menu
  ==============================
  1. Check Zombie Processes
  2. Rotate Logs
  3. Restart a Service
  4. Backup a Directory
  5. Check Network Connectivity
  6. Exit
  ==============================
EOF

  read -p "Enter your choice [1-6]: " choice

  case $choice in
    1)
      echo "Checking for zombie processes..."
      ZOMBIES=$(ps -eo stat,ppid,pid,cmd | grep -w Z)

      if [ -n "$ZOMBIES" ]; then
        echo "Zombie processes found:"
        echo "$ZOMBIES"
        echo ""
        read -p "Do you want to kill these zombie processes? (y/n): " ans
        if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
          # Extract PIDs of zombie processes
          PIDS=$(ps -eo stat,pid | awk '$1=="Z"{print $2}')
          if [ -n "$PIDS" ]; then
            echo "Killing zombie processes: $PIDS"
            kill -9 $PIDS
            echo "Zombie processes terminated."
          else
            echo "No valid PIDs found to kill."
          fi
        else
          echo "Zombie processes not killed."
        fi
      else
        echo "No zombie processes detected."
      fi
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
      echo "Checking network connectivity..."
      read -p "Enter host to ping (default: google.com): " host
      host=${host:-google.com}
      if ping -c 3 "$host" > /dev/null 2>&1; then
        echo "Network connectivity to $host is OK."
      else
        echo "Failed to reach $host. Check network settings!"
      fi
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
