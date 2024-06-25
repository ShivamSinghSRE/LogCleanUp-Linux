#!/bin/bash

# Define the output file
OUTPUT_FILE="/home/fp_admin/memory_usage.log"

# Get the current date and time
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Get the top 10 processes by memory usage
MEMORY_USAGE=$(ps aux --sort=-%mem | awk 'NR<=10{print $0}')

# Append the date and memory usage to the output file
echo "Date: $DATE" >> $OUTPUT_FILE
echo "$MEMORY_USAGE" >> $OUTPUT_FILE
echo "----------------------------------------" >> $OUTPUT_FILE
