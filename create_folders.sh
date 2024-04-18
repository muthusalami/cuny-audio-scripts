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
            echo -e "${YELLOW}Input directory $input_dir does not exist. Skipping.${NC}"
            continue
        fi

        # create metadata folder
        metadata_dir="$input_dir/metadata"
        if [ ! -d "$metadata_dir" ]; then
            mkdir "$metadata_dir"
            echo -e "${GREEN}Created 'metadata' folder in $input_dir.${NC}"
        else
            echo -e "${YELLOW}'metadata' folder already exists in $input_dir.${NC}"
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
                echo -e "${YELLOW}'object_photos' folder already exists in $depictions_dir.${NC}"
            fi
        else
            echo -e "${YELLOW}'depictions' folder already exists in $metadata_dir.${NC}"
        fi

        # create objects folder
        objects_dir="$input_dir/objects"
        if [ ! -d "$objects_dir" ]; then
            mkdir "$objects_dir"
            echo -e "${GREEN}Created 'objects' folder in $input_dir.${NC}"
        else
            echo -e "${YELLOW}'objects' folder already exists in $input_dir.${NC}"
        fi

        # Ask user if they want to move files
        read -p "Do you want to move files? (yes/no): " move_files
        case $move_files in
            [Yy]|[Yy][Ee][Ss])
                # Move .TIF and .tif files to depictions/object_photos folder
                find "$input_dir" -type f \( -iname "*.tif" -o -iname "*.TIF" -o -iname "*.TIFF" -o -iname "*.tiff" \) -exec mv "{}" "$input_dir/metadata/depictions/object_photos/" \;
                echo -e "${GREEN}Moved TIFF files to $object_photos_dir.${NC}"

                # Move .md5 files to metadata folder
                find "$input_dir" -type f -iname "*.md5" -exec mv {} "$metadata_dir" \;
                echo -e "${GREEN}Moved MD5 files to $metadata_dir.${NC}"

                # Move .wav files to objects folder
                find "$input_dir" -type f -iname "*.wav" -exec mv {} "$objects_dir" \;
                echo -e "${GREEN}Moved WAV files to $objects_dir.${NC}"

                # Remove empty directories
                if [ -d "$input_dir/Image" ] && [ ! "$(ls -A "$input_dir/Image")" ]; then
                    rm -r "$input_dir/Image"
                    echo -e "${GREEN}Removed empty directory: $input_dir/Image.${NC}"
                fi
                
                if [ -d "$input_dir/Preservation Master" ] && [ ! "$(ls -A "$input_dir/Preservation Master")" ]; then
                    rm -r "$input_dir/Preservation Master"
                    echo -e "${GREEN}Removed empty directory: $input_dir/Preservation Master.${NC}"
                fi
                ;;
            *)
                echo -e "${YELLOW}Skipping moving files.${NC}"
                ;;
        esac
    done
}

# call function to create folders with command line arguments
create_folders "$@"
