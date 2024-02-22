#!/bin/bash

check_header() {
    local file="$1"
    
    # Read the first 44 bytes of the file
    header=$(xxd -l 44 -g 1 "$file")

    # Extract the relevant parts of the header
    riff_value="${header:9:12}"
    wavefmt_value="${header:33:12}"

    # Check if the first 4 bytes are "RIFF" and the next 8 bytes are "WAVEfmt "
    if [[ "$riff_value" == " 52 49 46 46" && "$wavefmt_value" == " 57 41 56 45" ]]; then
        echo "WAV header is valid for file: $file"
        echo "RIFF Value: $riff_value"
        echo "WAVEfmt Value: $wavefmt_value"
    else
        echo "Error: Invalid WAV header for file: $file"
        echo "RIFF Value: $riff_value"
        echo "WAVEfmt Value: $wavefmt_value"
    fi
}

# Provide script usage instruction if no input provided
if [[ $# -eq 0 ]]; then
    script_name=$(basename "$0")
    echo "Usage: $script_name <file>"
    exit 1
fi

# Check header values for the provided file
check_header "$1"
