#!/bin/bash
#==============================================================================
#title           :generate_webp.sh
#description     :Converts still and gif images to webp. Resizes if they are large
#usage           :Run this script with WSL on Windows or Bash shell on Unix/Linux
#                :This is intended to be run from the root website directory
#                :Adjust target location for conversion as needed
#prerequisite    :webp,imagemagick and exiv2 installed
#==============================================================================

# Exit on errors
set -e

TARGET_PATH="$(cd "$(dirname "$0")" && pwd)/static/*/*"

for file in $TARGET_PATH; do

    FILE_PATH=$(readlink -f "$file" | sed 's/\.[^.]*$//')
    echo  $FILE_PATH

    # Strip EXIF data from still images first, read image size
    if [[ $file == *.jpg ]] || [[ $file == *.jpeg ]] || [[ $file == *.png ]] || [[ $file == *.tiff ]] || [[ $file == *.gif ]]; then
        IMAGE_SIZE=$(identify -format '%w' "$file")
        echo "Stripping EXIF from ${file}..."
        exiv2 rm "$file"
    fi

    # Skip webps, fonts, etc
    if [[ $file == *.webp ]] || [[ $file == *.woff ]] || [[ $file == *.woff2 ]]; then
        continue
    # Check to see if a WEBP of the same name already exists
    elif [[ -f "$FILE_PATH.webp" ]]; then
        echo "WEBP for $(basename "$file") already exists. Skipping..."
        continue
    # Convert GIFs
    elif [[ $file == *.gif ]]; then
        echo "Converting ${file} --> webp"
        gif2webp -q 90 "${file}" -o "${FILE_PATH}.webp" -mt -quiet
    # Convert still images
    elif [[ $file == *.jpg ]] || [[ $file == *.jpeg ]] || [[ $file == *.png ]] || [[ $file == *.tiff ]]; then
        # Resize large images (Width greater than 800 pixels)
        if [ "${IMAGE_SIZE}" -gt 800 ]; then
            echo "Image width greater than 800, resizing..."
            RESIZE='-resize 800 0'
        fi
        echo "Converting ${file} --> webp"

        echo "++++++"
        echo "${file}"
        echo "${RESIZE}"
        echo "${FILE_PATH}.webp"
        echo "++++++"
        cwebp -q 100 "${file} -o ${FILE_PATH}.webp ${RESIZE} -mt -quiet"
        echo "Cleaning up original file: ${file}"
        rm "${file}"
    fi
done
