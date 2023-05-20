#!/bin/bash

# Set the log file path
log_file="/path/to/log/file.log"

# Set the email recipient
email_recipient="your-email@example.com"

# Set the email subject
email_subject="HTTP 500 Alert"

# Set the email body
email_body="An HTTP 500 response occurred in the log file: $log_file"

# Counter for successful HTTP 200 responses for /index
index_success_count=0

# Get the size of the log file
file_size=$(stat -c%s "$log_file")

# Start tailing the log file
tail -n0 -F "$log_file" | while read -r line; do
    # Get the current size of the log file
    current_size=$(stat -c%s "$log_file")

    # Check if the log file has been truncated or rotated
    if [ "$current_size" -lt "$file_size" ]; then
        # Log file has been truncated or rotated, reset the file size
        file_size="$current_size"
        continue
    fi

    # Check if the log line contains HTTP 500 response for /file/one
    if echo "$line" | grep -q "HTTP 500" && echo "$line" | grep -q "/file/one"; then
        # Send an email alert
        echo "$email_body" | mail -s "$email_subject" "$email_recipient"
    fi

    # Check if the log line contains HTTP 200 response for /index
    if echo "$line" | grep -q "HTTP 200" && echo "$line" | grep -q "/index"; then
        # Increment the success count
        ((index_success_count++))

        # Ignore the first two successful responses for /index
        if [ "$index_success_count" -le 2 ]; then
            continue
        fi
    fi
done
