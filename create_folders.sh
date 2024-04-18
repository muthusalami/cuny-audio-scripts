#!/bin/bash

# color codes for messages
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# function to create folders
create_folders() {
    input_dirs=("$@")
    for input_dir in "${input_dirs[@]}"; do
        # check if the input directory exists
        if [ ! -d "$input_dir" ]; then
            echo -e "${RED}Input directory $input_dir does not exist. Skipping.${NC}"
            continue
        fi

        # create metadata folder
        metadata_dir="$input_dir/metadata"
        if [ ! -d "$metadata_dir" ]; then
            mkdir "$metadata_dir"
            echo -e "${GREEN}Created 'metadata' folder in $input_dir.${NC}"
        else
            echo -e "${RED}'metadata' folder already exists in $input_dir.${NC}"
        fi

        # create depictions folder inside metadata
        depictions_dir="$metadata_dir/depictions"
        if [ ! -d "$depictions_dir" ]; then
            mkdir "$depictions_dir"
            echo -e "${GREEN}Created 'depictions' folder in $metadata_dir.${NC}"

            # create object_photos folder inside depictions
            object_photos_dir="$depictions_dir/object_photos"
            if [ ! -d "$object_photos_dir" ]; then
                mkdir "$object_photos_dir"
                echo -e "${GREEN}Created 'object_photos' folder in $depictions_dir.${NC}"
            else
                echo -e "${RED}'object_photos' folder already exists in $depictions_dir.${NC}"
            fi
        else
            echo -e "${RED}'depictions' folder already exists in $metadata_dir.${NC}"
        fi

        # create objects folder
        objects_dir="$input_dir/objects"
        if [ ! -d "$objects_dir" ]; then
            mkdir "$objects_dir"
            echo -e "${GREEN}Created 'objects' folder in $input_dir.${NC}"
        else
            echo -e "${RED}'objects' folder already exists in $input_dir.${NC}"
        fi
    done
}

# call function to create folders with command line arguments
create_folders "$@"