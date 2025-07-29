#!/bin/bash
rm -rf upscaled frames
mkdir -p frames upscaled

npmstat=$(npm -v | grep "command not found")
upscalerstat=$(npm list -g --depth=0 | grep "upscaler-cli")

if [["$npmstat" == "command not found"]]; then
  echo "NPM not found!"
  exit 0
fi
if [[ "$upscalerstat" != "upscaler-cli" ]]; then
  npm install upscaler-cli
fi

echo "What video to enchance?"
read file
fps=$(ffmpeg -i "$file" 2>&1 | grep -oP '(\d+(\.\d+)?) fps' | grep -oP '\d+(\.\d+)?')
ffmpeg -i "$file" frames/%04d.png
amountofframes=$(ls frames | wc -l)
for i in $(seq 1 $amountofframes);
do 
  sudo upscaler "frames/$(printf "%04d" $i).png" -m @upscalerjs/esrgan-medium -o upscaled -s 2x
done
output="${file%.*} but better.mp4"

ffmpeg -i "$file" -vn -acodec copy temp_audio.aac
ffmpeg -framerate "$fps" -i upscaled/%04d.png -i temp_audio.aac -c:v libx264 -pix_fmt yuv420p -c:a copy "$output"

echo "Check «$file but better.mp4» out!"
rm -rf upscaled frames

