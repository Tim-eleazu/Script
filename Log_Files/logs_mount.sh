#!/bin/bash

# Author: Tim
# Last Modified: 03/08/2023

# Description:
# Deletes log files on NASs after mounting the specified NFS share.

# Mount the NFS share
mount_point="/mnt/TE10"
nfs_server=":/volume1/tim"
ip_to_ping=""

# Ping the IP to check connectivity
ping -c 1 "$ip_to_ping" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Cannot reach $ip_to_ping. Exiting."
    exit 1
fi

if ! mount | grep -q "on $mount_point type"; then
    sudo mount -t nfs "$nfs_server" "$mount_point"
    if [ $? -ne 0 ]; then
        echo "Mount operation failed."
        exit 1
    fi
else
    echo "Already mounted."
fi

# Directories to process
directories=(
  "$mount_point/log/"
)

# Specify absolute path for the output file
log_filename="/home/teleazu/delete_logs/directories.txt"

# Retry parameters for file deletion
retry_count=10
retry_delay=5

# Function to delete logs older than 180 days with retry
delete_file_with_retry() {
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
            echo "Deletion failed. Retrying in ${retry_delay} seconds"
            sleep "${retry_delay}"
        fi
    done
    echo "Deletion failed after ${retry_count} attempts." >> "$log_filename"
    return 1
}

# Iterate through each directory
for dir in "${directories[@]}"; do
  find "$dir" -type d -mtime +180 -print | while read line; do
    if [[ $line =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}_[0-9]{2}_[0-9]{2}$ ]]; then
            ls -l "$line"
            delete_file_with_retry "$line" "$retry_count" "$retry_delay"
    fi
  done
done

# Unmount the NFS share
if mount | grep -q "on $mount_point type"; then
    sudo umount "$mount_point"
    if [ $? -ne 0 ]; then
        echo "Unmount operation failed."
    fi
else
    echo "Mount point not mounted or already unmounted."
fi