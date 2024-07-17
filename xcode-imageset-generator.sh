#!/bin/bash

# Directory containing the PNG images
SOURCE_DIR=$1

if [ -z "$SOURCE_DIR" ]; then
    echo "Please provide the source directory as the first argument."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "The specified directory does not exist."
    exit 1
fi

# Install ImageMagick if not already installed
if ! command -v magick &> /dev/null; then
    echo "ImageMagick is being installed..."
    brew install imagemagick
fi

# Iterate through all PNG images in the directory
for IMAGE in "$SOURCE_DIR"/*.png; do
    if [ -f "$IMAGE" ]; then
        # Filename without extension
        FILENAME=$(basename "$IMAGE" .png)
        
        # Create the .imageset directory
        IMAGESET_DIR="$SOURCE_DIR/$FILENAME.imageset"
        mkdir -p "$IMAGESET_DIR"
        
        # Generate the different sizes
        magick convert "$IMAGE" -resize 100% "$IMAGESET_DIR/${FILENAME}@3x.png"
        magick convert "$IMAGE" -resize 66.67% "$IMAGESET_DIR/${FILENAME}@2x.png"
        magick convert "$IMAGE" -resize 33.33% "$IMAGESET_DIR/${FILENAME}@1x.png"
        
        # Create the Contents.json file
        cat > "$IMAGESET_DIR/Contents.json" <<EOL
{
  "images": [
    {
      "idiom": "universal",
      "filename": "${FILENAME}@1x.png",
      "scale": "1x"
    },
    {
      "idiom": "universal",
      "filename": "${FILENAME}@2x.png",
      "scale": "2x"
    },
    {
      "idiom": "universal",
      "filename": "${FILENAME}@3x.png",
      "scale": "3x"
    }
  ],
  "info": {
    "version": 1,
    "author": "xcode"
  }
}
EOL
    fi
done

echo "Done!"
