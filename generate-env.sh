#!/bin/bash

source=""
dest=""
prefix=""

if [ $# -eq 3 ]; then
    source=$1
    dest=$2
    prefix=$3

    # Check if the source file exists
    if [ ! -f "$source" ]; then 
        echo "source not found"
        exit 1
    fi

    # Warn if the destination file already exists
    if [ -f "$dest" ]; then 
        echo "dest already exists, overwriting"
    fi

    source_str=$(<"$source")

    # Loop through environment variables
    while IFS= read -r line; do
        key=${line%%=*}
        value=${line#*=}
        
        # Check if the variable starts with the specified prefix
        if [[ $key == $prefix* ]]; then
            echo "found ${key}, replacing..."
            # Escape characters for use in sed
            key_escaped=$(printf "%s" "$key" | sed 's/[&/\]/\\&/g')
            value_escaped=$(printf "%s" "$value" | sed 's/[&/\]/\\&/g')
            value_escaped=$(printf "%s" "$value_escaped" | sed 's/[?]/\\&/g')
            # Replace the key with the value in the source string
            source_str=$(printf "%s" "$source_str" | sed "s/$key_escaped/$value_escaped/g")
        fi
    done < <(env)

    # Write the modified string to the destination file
    printf '%s' "$source_str" > "$dest"
else
    echo "not enough args"
    exit 1
fi
