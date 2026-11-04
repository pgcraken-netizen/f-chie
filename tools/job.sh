#!/bin/bash
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
mkdir -p full
fp() { curl -sSL -A "$UA" -o "full/$1.jpg" "https://commons.wikimedia.org/wiki/Special:FilePath/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$2")?width=2000"; echo "$1 $(stat -c%s full/$1.jpg)"; }
fp hachi-view "Hachimanyama Park from Tochigi prefectural office.jpg"
fp hachi-sakura "Hachimanyama park (7259797162).jpg"
fp tagawa "Tagawa Promenade with Cherry Blossom.jpg"
