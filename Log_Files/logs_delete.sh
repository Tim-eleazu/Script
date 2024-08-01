#!/bin/bash

# Author: Tim
# Date Created: 17/07/2023
# Last Modified: 03/08/2023

#Description:
# Deletes Log files on NASs

directories=(
  "/mnt/TE2/log/"
  "/mnt/TE3/log/"
  "/mnt/TE4/log/"
  "/mnt/TE5/log/"
  "/mnt/TE6/log/"
  "/mnt/TE7/log/"
  "/mnt/TE8/log/"
  "/mnt/TE10/log/"
  "/mnt/TE11/log/"
  "/mnt/TE12/log/"
  "/mnt/TE15/log/"
  "/mnt/TE16/log/"
  "/mnt/TE13/log/"
  "/mnt/TE18/log/"
  "/mnt/TE20/log/"

)



# Specify absolute path for the output file
log_filename="/home/directories.txt"

retry_count=10
retry_delay=5
# Function to delete logs older than 180 days with retry
delete_file_with_retry(){
    local source_file=$1
    local retry_count=$2
    local retry_delay=$3

    for ((i=1; i<=retry_count; i++)); do
        echo "Attempting to delete (Attempt ${i}): ${source_file}"
        rm -rf "$source_file"
        #ls -l "$source_file"
        if [ $? -eq 0 ]; then
            echo "${source_file} deleted successfully" >> "$log_filename"
            return 0
        else
            echo "Deletion Failed. Retrying in ${retry_delay} seconds"
            sleep "${retry_delay}"
        fi
    done
    echo "Deletioned fTEled after ${retry_count} attempts." >> "$log_filename"
    return 1
}

# Iterate through each directory
for dir in "${directories[@]}"; do
  # Find directories matching the naming pattern and older than 180 days, then print them
  find $dir -type d -mtime +180 -print | while read line; do
    if [[ $line =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}_[0-9]{2}_[0-9]{2}$ ]]; then
            #echo $line
            ls -l "$line"
            delete_file_with_retry "$line" "$retry_count" "$retry_delay"
    fi
  done
done