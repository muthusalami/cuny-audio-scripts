#!/bin/bash

# color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# usage message
if [ "$#" -lt 1 ]; then
    echo -e "${GREEN}Usage: $0 <base_directory1> [<base_directory2> ... <base_directoryN>]${RESET}"
    exit 1
fi

# array to store dirs
invalid_dirs=()

# loop to go through directories
for base_dir in "$@"; do
    echo "Validating directory: $base_dir"
    
    # required sub-directories
    objects_dir="$base_dir/objects"
    metadata_dir="$base_dir/metadata"
    
    # checks for sub-directories
    if [ ! -d "$objects_dir" ] || [ ! -d "$metadata_dir" ]; then
        # Add to the list of invalid directories
        invalid_dirs+=("$base_dir")
    fi
done

# checks for invalid directories
if [ ${#invalid_dirs[@]} -eq 0 ]; then
    echo -e "${GREEN}All directories passed the validation check.${RESET}"
else
    echo -e "${RED}The following directories failed the validation check:${RESET}"
    for invalid_dir in "${invalid_dirs[@]}"; do
        echo -e "${RED}$invalid_dir${RESET}"
    done
fi
