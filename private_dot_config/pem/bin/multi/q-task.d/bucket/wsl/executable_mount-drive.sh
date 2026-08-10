#!/usr/bin/env bash

# Check that exactly one argument is given
if [ $# -ne 1 ]; then
    echo "Usage: $0 <drive_letter>" >&2
    exit 1
fi

drive_letter="${1:0:1}"
if [[ ! "$drive_letter" =~ [A-Za-z] ]]; then
    echo "Error: Argument must be a drive letter (e.g., c or C)." >&2
    exit 1
fi

# Convert to uppercase for Windows path, lowercase for mount point (optional)
upper_letter="${drive_letter^^}"   # Bash 4+ uppercase
lower_letter="${drive_letter,,}"   # Bash 4+ lowercase

mount_point="/mnt/$lower_letter"

# Create mount point (sudo needed because /mnt is owned by root)
echo sudo mkdir -p "$mount_point"
echo sudo mount -t drvfs "${upper_letter}:" "$mount_point"

sudo mkdir -p "$mount_point"
sudo mount -t drvfs "${upper_letter}:" "$mount_point"

echo "Mounted ${upper_letter}: at $mount_point"
