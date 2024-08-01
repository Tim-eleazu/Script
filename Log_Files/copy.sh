#!/bin/bash

# Author: Timothy
# Date Created: 02/08/2023
# Last Modified: 08/08/2023

# Description:
# Moves Performance.json files to its destination for processing

source_directories=(
    "/mnt/corescan_performance/source/node-01"

)

destination_directories=(
    "/mnt/corescan_performance/destination/node-01"

)
retry_count=10
retry_delay=60

# Get the current date and time
current_date=$(date '+%Y-%m-%d %H:%M:%S')

# Start measuring script execution time
start_time=$(date +%s)

# Format the date for the filename (year.month.day)
formatted_date=$(date '+%Y.%m.%d')

# Function to copy a file with retry
copy_file_with_retry(){
    local source_file=$1
    local destination=$2
    local retry_count=$3
    local retry_delay=$4

    for ((i=1; i<=retry_count; i++)); do
        echo "Attempting to copy (Attempt ${i}): ${source_file} to ${destination}"
        cp "${source_file}" "${destination}"
        if [ $? -eq 0 ]; then
            echo "Copied ${source_file} to ${destination} successfully" >> "$log_filename"
            return 0
        else
            echo "Copy failed. Retrying in ${retry_delay} seconds"
            sleep "${retry_delay}"
        fi
    done
    echo "File copy failed after ${retry_count} attempts." >> "$log_filename"
    return 1
}

# Iterate through each source and destination pair
for ((i=0; i<${#source_directories[@]}; i++)); do
    source_dir="${source_directories[i]}"
    dest_dir="${destination_directories[i]}"

    # Extract the common name from the source directory path
    common_name=`echo $source_dir | cut -d/ -f4`

    # Create the log filename using the common name and formatted date
    log_filename="${common_name}.txt"

    # Append source directory info to the log file
    echo "Source Directory: $source_dir" >> "$log_filename"

    # Find files and append their paths to the log file
    find "$source_dir" -type f -name "CoreScan_performance.json" >> "$log_filename"

    # Copy files to the destination directory with retry
    for file in $(cat "$log_filename" | grep "CoreScan_performance.json$"); do
        new_dir=$(head -n 1 "$file" | cut -d'"' -f4 | sed 's/T/\//;s/\./\//;s/:/./' | cut -d'/' -f1-2)
        mkdir -p "$dest_dir/$new_dir"
        dest="$dest_dir/$new_dir"
        echo "Calling the function"
        copy_file_with_retry "$file" "$dest" "$retry_count" "$retry_delay"
    done
done

# End measuring script execution time
end_time=$(date +%s)
# Calculate and display script execution time
execution_time=$((end_time - start_time))
echo "Script execution time: ${execution_time} seconds"

# Append script execution details to the log files
for dest_dir in "${destination_directories[@]}"; do
    echo "Script run on: ${current_date}" >> "${dest_dir}/${common_name}.txt"
    echo "Script execution time: ${execution_time} seconds" >> "${dest_dir}/${common_name}.txt"
done
