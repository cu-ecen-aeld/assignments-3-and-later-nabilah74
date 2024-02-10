#!/bin/bash
# Check if all arguments are provided
if [ $# -ne 2 ]; then
   echo "Usage: $0 <writefile> <writestr>"
   exit 1
fi
# Create the file with writefile as filename and writestr as content
dir_path=$(dirname $1)
mkdir -p $dir_path
echo "$2" > "$1"
# Verify if the file was successfully created
if [ $? -ne 0 ]; then
   echo "Error: Failed to create file $1"
   exit 1
fi
echo "File created at path $1 with content $2"