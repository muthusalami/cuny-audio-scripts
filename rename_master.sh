#!/bin/bash

# argument check
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <base_directory1> [<base_directory2> ... <base_directoryN>]"
    exit 1
fi

# loop through all directories
for base_dir in "$@"; do
    echo "Processing directory: $base_dir"
    
    # source and target directories for renaming
    access_master_dir="$base_dir/objects/access master"
    access_dir="$base_dir/objects/access"
    
    izotope_master_dir="$base_dir/objects/izotope master"
    restoration_dir="$base_dir/objects/restoration"
    
    # renames "access master" to "access" if it exists
    if [ -d "$access_master_dir" ]; then
        mv "$access_master_dir" "$access_dir"
        echo "Renamed \"$access_master_dir\" to \"$access_dir\""
    else
        echo "Directory \"$access_master_dir\" does not exist."
    fi
    
    # renames "izotope master" to "restoration" if it exists
    if [ -d "$izotope_master_dir" ]; then
        mv "$izotope_master_dir" "$restoration_dir"
        echo "Renamed \"$izotope_master_dir\" to \"$restoration_dir\""
    else
        echo "Directory \"$izotope_master_dir\" does not exist."
    fi
    
done
