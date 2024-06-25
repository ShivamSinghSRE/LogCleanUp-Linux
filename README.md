# Cleanup Script

## Overview

`cleanup_script.sh` is a bash script designed to automate the cleanup of old log files and Elasticsearch indices. This script helps maintain a healthy disk space usage by deleting files and indices that are no longer needed.

## Features

- Deletes log files older than 150 days from specified directories.
- Excludes certain important log files from deletion.
- Cleans up error and info subdirectories.
- Deletes CSV files older than 45 days from a specified directory.
- Deletes Elasticsearch indices older than 4 months.
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

    # Check disk space
    echo "Checking disk space..."
    df -h
    ```

### Setting Up a Cron Job

To automate the script execution, set up a cron job to run the script every Sunday.

1. Open the crontab editor:
    ```sh
    sudo crontab -e
    ```

2. Add the following line to run the script every Sunday at midnight:
    ```sh
    0 0 * * 0 /home/fp_admin/cleanup_script.sh
    ```

3. Save and exit the editor.

Verify the cron job:
    ```sh
    sudo crontab -l
    ```

You should see:
    ```sh
    0 0 * * 0 /home/fp_admin/cleanup_script.sh
    ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Contact

If you have any questions or suggestions, please feel free to contact the project maintainer.

---

