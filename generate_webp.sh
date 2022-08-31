#!/bin/bash
#==============================================================================
#title           :generate_webp.sh
#description     :Converts still and gif images to webp. Resizes if they are large
#usage           :Run this script with WSL on Windows or Bash shell on Unix/Linux
#                :This is intended to be run from the root website directory
#                :Adjust target location for conversion as needed
#prerequisite    :webp,imagemagick and exiv2 installed
#==============================================================================

TARGET_PATH="$(cd "$(dirname "$0")" && pwd)/static/photographs/*"

for file in $TARGET_PATH; do

    DUP_CHECK=$(readlink -f "$file" | sed 's/\.[^.]*$//')
    IMAGE_SIZE=$(identify -format '%w' "$file")

    # Strip EXIF data from still images first
    if [[ $file != *.gif ]] || [[ $file != *.webp ]]; then
        echo "Stripping EXIF from $(basename "$file")..."
        exiv2 rm "$file"
    fi

    # Skip webps
    if [[ $file == *.webp ]]; then
        continue
    # Check to see if a WEBP of the same name already exists
    elif [[ -f "$DUP_CHECK.webp" ]]; then
        echo "WEBP for $(basename "$file") already exists. Skipping..."
        continue
    # Convert GIFs
    elif [[ $file == *.gif ]]; then
        echo "Converting .//static/photographs/$(basename "${file}") --> webp"
        gif2webp -q 90 "$(echo "$file" | sed -e 's/\*/ /g' -e 's/^"//' -e 's/"$//')" \
            -o "$(echo "$file" | sed -e 's/\*/ /g' -e 's/^"//' | sed 's/.[^.]*$//').webp" \
            -mt -quiet
    # Convert still images
    elif [[ $file == *.jpg ]] || [[ $file == *.jpeg ]] || [[ $file == *.png ]] || [[ $file == *.tiff ]]; then
        # Resize large images (Width greater than 800 pixels)
        if [ "${IMAGE_SIZE}" -gt 800 ]; then
            echo "Image width greater than 800, resizing..."
            RESIZE='-resize 800 0'
        fi
        echo "Converting .//static/photographs/$(basename "${file}") --> webp"
        cwebp -q 100 "$(echo "$file" | sed -e 's/\*/ /g' -e 's/^"//' -e 's/"$//')" \
            -o "$(echo "$file" | sed -e 's/\*/ /g' -e 's/^"//' | sed 's/.[^.]*$//').webp" \
            $RESIZE -mt -quiet
    fi
done
