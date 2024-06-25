#!/bin/bash

# Function to delete files older than X days
delete_old_files() {
    find "$1" -type f -mtime +$2 -delete
}

# Function to delete Elasticsearch indices older than X months
delete_old_indices() {
    current_date=$(date +%Y.%m.%d)
    four_months_ago=$(date -d "4 months ago" +%Y.%m.%d)

    indices=$(curl -s -X GET "localhost:9200/_cat/indices?v" | awk '{print $3}' | grep '^betterstack-')

    for index in $indices; do
        index_date=$(echo $index | sed 's/betterstack-//')
        if [[ "$index_date" < "$four_months_ago" ]]; then
            curl -X DELETE "localhost:9200/$index"
        fi
    done
}

# Main log cleanup
log_dirs=(
    "/app/appsh/admin/logs"
    "/app/appsh/app/logs"
    "/app/appsh/cashier/logs"
    "/app/appsh/staff/logs"
    "/app/appsh/stl-invoice/logs"
    "/app/appsh/task/logs"
    "/app/appsz/cashierpos/logs"
)

for dir in "${log_dirs[@]}"; do
    # Don't delete main log files
    find "$dir" -type f -mtime +150 ! -name "*-SNAPSHOT.log" ! -name "web_info.log" -delete

    # Clean up error and info subdirectories
    delete_old_files "$dir/error" 150
    delete_old_files "$dir/info" 150
done

# Special case for /app/appsh/app/logs
find "/app/appsh/app/logs" -type f -mtime +150 ! -name "app-0.0.1-SNAPSHOT.log*" -delete

# Delete old CSV files
delete_old_files "/home/compress_old_csv_files/old_files" 45

# Delete old Elasticsearch indices
delete_old_indices

echo "Log cleanup completed."

# Check disk space
echo "Checking disk space..."
df -h
