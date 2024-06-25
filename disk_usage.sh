#!/bin/bash

# Define the output directory and file
OUTPUT_DIR="/home/fp_admin/disk_logs"
OUTPUT_FILE="$OUTPUT_DIR/disk_usage_$(date '+%Y-%m-%d').log"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Get the current date and time
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Get the disk usage information
DISK_USAGE=$(df -h)

# Write the date and disk usage to the output file
echo "Date: $DATE" > $OUTPUT_FILE
echo "$DISK_USAGE" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE

# Print a message indicating where the log has been saved
echo "Disk usage log for $(date '+%Y-%m-%d') has been saved to $OUTPUT_FILE"
