#!/bin/bash
# Check if all arguments are provided
if [ $# -ne 2 ]; then
   echo "Usage: $0 <filedir> <searchstr>"
   exit 1
fi
# Check if the provided filesdir exists and is a directory
if [ ! -d "$1" ]; then
   echo "Error: $1 is not a directory"
   exit 1
fi
# Count the number of files
num_files=$(find "$1" -type f | wc -l)
# Count the number of matching lines
num_matching=$(grep -Rh $2 $1 | wc -l)
# Print the result
echo "The number of files are $num_files and the number of matching lines are $num_matching"