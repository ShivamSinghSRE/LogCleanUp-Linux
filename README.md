# System Maintenance Script

## Overview

`maintenance_script.sh` is a comprehensive bash script designed to automate the maintenance of your system. It includes functionalities to clean up old log files, delete old Elasticsearch indices, log memory usage, and log disk usage.

## Features

- Deletes log files older than 150 days from specified directories.
- Excludes certain important log files from deletion.
- Cleans up error and info subdirectories.
- Deletes CSV files older than 45 days from a specified directory.
- Deletes Elasticsearch indices older than 4 months.
- Logs the top 10 processes by memory usage.
- Logs the current disk usage.
- Outputs the current disk space usage after the cleanup.

## Usage

### Prerequisites

- Ensure you have the necessary permissions to delete files and indices.
- Ensure `curl` is installed on your system for interacting with Elasticsearch.
- Elasticsearch should be running and accessible on `localhost:9200`.

### Script Details

1. **Function to delete files older than X days**:
    ```bash
    delete_old_files() {
        find "$1" -type f -mtime +$2 -delete
    }
    ```

2. **Function to delete Elasticsearch indices older than X months**:
    ```bash
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
    ```

3. **Main log cleanup**:
    ```bash
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
    ```

4. **Memory usage logging**:
    ```bash
    # Memory usage logging
    memory_output_file="/home/fp_admin/memory_usage.log"

    # Get the current date and time
    current_date=$(date '+%Y-%m-%d %H:%M:%S')

    # Get the top 10 processes by memory usage
    memory_usage=$(ps aux --sort=-%mem | awk 'NR<=10{print $0}')

    # Append the date and memory usage to the output file
    echo "Date: $current_date" >> $memory_output_file
    echo "$memory_usage" >> $memory_output_file
    echo "----------------------------------------" >> $memory_output_file

    echo "Memory usage log updated."
    ```

5. **Disk usage logging**:
    ```bash
    # Disk usage logging
    disk_output_dir="/home/fp_admin/disk_logs"
    disk_output_file="$disk_output_dir/disk_usage_$(date '+%Y-%m-%d').log"

    # Create the output directory if it doesn't exist
    mkdir -p $disk_output_dir

    # Get the disk usage information
    disk_usage=$(df -h)

    # Write the date and disk usage to the output file
    echo "Date: $current_date" > $disk_output_file
    echo "$disk_usage" >> $disk_output_file
    echo "----------------------------------------" >> $disk_output_file

    # Print a message indicating where the log has been saved
    echo "Disk usage log for $(date '+%Y-%m-%d') has been saved to $disk_output_file"
    ```

6. **Check disk space**:
    ```bash
    # Check disk space
    echo "Checking disk space..."
    df -h
    ```

### Setting Up a Cron Job

To automate the execution of this script, set up a cron job to run it at specified times.

1. **Open the crontab editor**:
    ```sh
    sudo crontab -e
    ```

2. **Add the following line to run the script**:

    To run `maintenance_script.sh` every Sunday at midnight:
    ```sh
    0 0 * * 0 /home/fp_admin/maintenance_script.sh
    ```

3. **Save and exit the editor**:
    - If you’re using `vi` as the default editor, press `Esc`, then type `:wq` and hit `Enter`.
    - If you’re using `nano`, press `Ctrl + X`, then `Y` to confirm changes, and `Enter` to save.

Verify the cron job:
    ```sh
    sudo crontab -l
    ```

## Contributing

We welcome contributions to improve this script. Please follow these guidelines:

1. **Fork the repository**.
2. **Create a new branch** for your feature or bugfix.
3. **Make your changes** with clear commit messages.
4. **Submit a pull request** to the main branch with a detailed explanation of your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

If you have any questions, feel free to open an issue or contact the project maintainer.

---

**Note:** Ensure that your environment has the necessary permissions to perform file deletions and interact with Elasticsearch. Running these scripts as a user with insufficient permissions may result in errors.
