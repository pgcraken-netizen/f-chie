#!/bin/bash
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
mkdir -p full
fp() { curl -sSL -A "$UA" -o "full/$1.jpg" "https://commons.wikimedia.org/wiki/Special:FilePath/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$2")?width=1600"; echo "$1 $(stat -c%s full/$1.jpg)"; }
fp a-kenkyukai "Nishihara elementary school with Cherry Blossom.jpg"
fp alt-kama "Kamagawa Promenade 2026-04-20.jpg"
python3 - <<'PY'
import json,urllib.request,urllib.parse
files=["Utsunomiya-LRT Series-HU314 Tochigi-route69.jpg","Utsunomiya Chuo Elementary School.jpg","Kindergarten, elementary and junior high school, Cooperative Faculty of Education, Utsunomiya Univ.jpg","Utsunomiya Orion street ac (8).jpg","Utsunomiya Tobu Bashamichi street ac.JPG","Utsunomiya Gyoza Festival 2022.jpg","Utsunomiya city hall ac (1).JPG","Sakura elementary school, Utsunomiya 2.jpg","Nishihara elementary school with Cherry Blossom.jpg","Kamagawa Promenade 2026-04-20.jpg"]
out=[]
for f in files:
    u="https://commons.wikimedia.org/w/api.php?"+urllib.parse.urlencode({"action":"query","format":"json","titles":"File:"+f,"prop":"imageinfo","iiprop":"extmetadata|url"})
    r=urllib.request.Request(u,headers={"User-Agent":"f-chie-site-builder/1.0 (https://f-chie.vercel.app)"})
    d=json.load(urllib.request.urlopen(r)); p=list(d["query"]["pages"].values())[0]; ii=p["imageinfo"][0]; m=ii["extmetadata"]
    import re
    out.append({"file":f,"page":ii["descriptionurl"],"license":m.get("LicenseShortName",{}).get("value",""),"license_url":m.get("LicenseUrl",{}).get("value",""),"artist":re.sub("<[^>]+>","",m.get("Artist",{}).get("value","")).strip(),"desc":re.sub("<[^>]+>","",m.get("ImageDescription",{}).get("value",""))[:200]})
json.dump(out,open("credits.json","w"),ensure_ascii=False,indent=1)
print(len(out))
PY
