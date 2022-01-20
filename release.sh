#!/bin/sh
#input the release number as the first argument
cd /c/code/norepair

git checkout retail
mkdir norepair
cp norepair.toc ./norepair/norepair.toc
cp LICENSE ./norepair/LICENSE 
cp main.lua ./norepair/main.lua
cp README.md ./norepair/README.md
7z a ../upload_norepair/norepair-$1-retail.zip ./norepair
rm -rf ./norepair

git checkout classic
mkdir norepair
cp norepair.toc ./norepair/norepair.toc
cp LICENSE ./norepair/LICENSE 
cp main.lua ./norepair/main.lua
cp README.md ./norepair/README.md
7z a ../upload_norepair/norepair-$1-classic.zip ./norepair
rm -rf ./norepair

git checkout bcc
mkdir norepair
cp norepair.toc ./norepair/norepair.toc
cp LICENSE ./norepair/LICENSE 
cp main.lua ./norepair/main.lua
cp README.md ./norepair/README.md
7z a ../upload_norepair/norepair-$1-bcc.zip ./norepair
rm -rf ./norepair

git checkout main
echo "done!"