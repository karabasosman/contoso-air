#!/bin/bash
# Script to download the actual Munich image from Wikimedia Commons
# Run this script when internet access is available

echo "Downloading Munich image from Wikimedia Commons..."
curl -L -o src/web/public/assets/cities/munich.jpg "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Munich_Aerial_View.jpg/640px-Munich_Aerial_View.jpg"

echo "Creating mobile version (copying desktop version for now)..."
cp src/web/public/assets/cities/munich.jpg src/web/public/assets/cities/munich_m.jpg

echo "Munich images downloaded successfully!"
echo "Desktop image: src/web/public/assets/cities/munich.jpg"
echo "Mobile image: src/web/public/assets/cities/munich_m.jpg"