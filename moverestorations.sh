#!/bin/bash
# microservice to move older transcription disc restorations into the restoration_old directory after a newer restoration is made using the mm/makederiv microservice

_usage(){
    echo -e "\nThis script moves older transcription disc restorations into the restoration_old directory after a newer restoration is made using the mm/makederiv microservice.\n"
}

_usage

# specify restoration directory to check for restoration wav files

echo "Enter the directory path to begin:"
read -p "> " user_directory

if [ ! -d "$user_directory" ]; then
    echo "Directory not found: $user_directory"
    exit 1
fi

echo "Selected directory: $user_directory"

# is it named restoration? If no, exit
if [ "$(basename "$user_directory")" != "restoration" ]; then
    echo "Incorrect directory name. It should be named 'restoration'."
    exit 1
fi

# does it have wav files? If no, exit
wav_files=$(find "$user_directory" -maxdepth 1 -type f -name "*.wav")

if [ -z "$wav_files" ]; then
    echo "No WAV files found in the restoration directory. Aborting..."
    exit 1
fi

# create restoration_old directory
restoration_old_dir="$user_directory/restoration_old"
mkdir -p "$restoration_old_dir"

# append to readme.txt log file
readme_file="$user_directory/readme.txt"
echo "Old restoration file transfer log:" > "$readme_file"
echo "==============================" >> "$readme_file"

# identify old & new wav file
for wav_file in $wav_files; do
    filename=$(basename "$wav_file")
    current_datetime=$(date +"%m-%d-%Y %H:%M:%S")

    if [[ "$filename" != *"_transcriptiondisc.wav" ]]; then
        mv "$wav_file" "$restoration_old_dir/"
        echo "Moved $wav_file to $restoration_old_dir"
        echo "Transfer details:" >> "$readme_file"
        echo "   File: $wav_file" >> "$readme_file"
        echo "   Transfer Date & Time: $current_datetime" >> "$readme_file"
        echo "   From: $user_directory" >> "$readme_file"
        echo "   To:   $restoration_old_dir" >> "$readme_file"
        echo "------------------------------" >> "$readme_file"
    fi
done

echo "Transfer complete. See readme_file for the transfer log."