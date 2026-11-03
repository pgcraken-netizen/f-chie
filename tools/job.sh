#!/bin/bash
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
mkdir -p full
fp() { curl -sSL -A "$UA" -o "full/$1.jpg" "https://commons.wikimedia.org/wiki/Special:FilePath/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$2")?width=1600"; echo "$1 $(stat -c%s full/$1.jpg)"; }
fp v-work "Utsunomiya-LRT Series-HU314 Tochigi-route69.jpg"
fp v-safety "Utsunomiya Chuo Elementary School.jpg"
fp v-school "Kindergarten, elementary and junior high school, Cooperative Faculty of Education, Utsunomiya Univ.jpg"
fp v-life2 "Utsunomiya Orion street ac (8).jpg"
fp v-life "Utsunomiya Tobu Bashamichi street ac.JPG"
fp alt-gyoza "Utsunomiya Gyoza Festival 2022.jpg"
fp a-gikai "Utsunomiya city hall ac (1).JPG"
fp a-support "Sakura elementary school, Utsunomiya 2.jpg"
fp a-kenkyukai "Nishihara elementary school with Cherry Blossom.jpg"
fp alt-kama "Kamagawa Promenade 2026-04-20.jpg"
