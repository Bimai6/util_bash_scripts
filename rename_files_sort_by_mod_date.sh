#!/bin/bash

# Given a folder and a file extension, rename all files with that extension to a numerical sequence.
# Files are sorted by their last modification date.

folder=$1
ext=$2

if [[ -z "$folder" || -z "$ext" ]]; then
    echo "Use: $0 <folder> <.ext>"
    exit 1
fi

cd "$folder" || { echo "Access to this folder is not allowed"; exit 1;}

mapfile -t files < <(find . -maxdepth 1 -type f -iname "*$ext" -printf "%T@ %p\n" | sort -n | cut -d' ' -f2- | sed 's|^\./||')

echo "Preview of renaming order and files (modification date + name):"
printf "%-20s %s\n" "Modification Date" "File Name"

for file in "${files[@]}"; do
    mod_date=$(stat -c '%y' "$file" 2>/dev/null || stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$file")
    printf "%-20s %s\n" "$mod_date" "$file"
done

echo
read -p "Are you sure you want to continue? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

counter=1

for file in "${files[@]}"; do
    new_name=$(printf "%06d%s" "$counter" "$ext")

    if [[ "$file" != "$new_name" ]]; then
    mv -i -- "$file" "$new_name"
    fi

    ((counter++))
done

echo "Script was succesful"