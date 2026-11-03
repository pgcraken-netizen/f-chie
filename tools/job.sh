#!/bin/bash
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
mkdir -p full cand
fp() { curl -sSL -A "$UA" -o "full/$1.jpg" "https://commons.wikimedia.org/wiki/Special:FilePath/$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$2")?width=1600"; echo "$1 $(stat -c%s full/$1.jpg)"; }
fp v-work "Utsunomiya-LRT Series-HU314 Tochigi-route69.jpg"
fp v-safety "Utsunomiya Chuo Elementary School.jpg"
fp v-school "Kindergarten, elementary and junior high school, Cooperative Faculty of Education, Utsunomiya Univ.jpg"
fp v-life "Utsunomiya Tobu Bashamichi street ac.JPG"
fp v-life2 "Utsunomiya Orion street ac (8).jpg"
fp v-local "Shimotsuke Fudo Daiko 2022-10-01.jpg"
fp a-gikai "Utsunomiya city hall ac (1).JPG"
fp a-support "Sakura elementary school, Utsunomiya 2.jpg"
fp v-money "Utsunomiya Central Elementary School.jpg"
fp alt-gyoza "Utsunomiya Gyoza Festival 2022.jpg"
fp alt-chuo "Utsunomiya Chuo street ac.JPG"
fp alt-akebono "Utsunomiya Akebono Park ac (1).JPG"
for id in HqHo_6NL2Rk FoDKKLX2hpk OAz-6JgJTcs iOjbCnBLLGQ; do curl -sSL -o "cand/us-$id.jpg" "https://unsplash.com/photos/$id/download?w=800"; echo "us $id $(stat -c%s cand/us-$id.jpg)"; done
# more commons searches
q() {
  curl -sS -A "$UA" -G "https://commons.wikimedia.org/w/api.php" \
    --data-urlencode "action=query" --data-urlencode "format=json" \
    --data-urlencode "generator=search" --data-urlencode "gsrnamespace=6" \
    --data-urlencode "gsrlimit=18" --data-urlencode "gsrsearch=$2 filetype:bitmap" \
    --data-urlencode "prop=imageinfo" --data-urlencode "iiprop=url|extmetadata|size" \
    --data-urlencode "iiurlwidth=360" > "$1.json"
  python3 - "$1" <<'PY'
import json,sys,subprocess
tag=sys.argv[1]; d=json.load(open(tag+'.json'))
pages=sorted(d.get('query',{}).get('pages',{}).values(),key=lambda p:p.get('index',0))
with open('list2.tsv','a') as f:
  for i,p in enumerate(pages):
    ii=p.get('imageinfo',[{}])[0]; m=ii.get('extmetadata',{})
    name=f"{tag}-{i:02d}.jpg"
    subprocess.run(['curl','-sS','-A','f-chie-site-builder/1.0','-o','cand/'+name,ii.get('thumburl','')])
    f.write('\t'.join([name,p['title'],m.get('LicenseShortName',{}).get('value',''),m.get('Artist',{}).get('value','').replace('\n',' ')[:200]])+'\n')
PY
}
q nishi "Nishihara Utsunomiya"
q comm "Utsunomiya community center"
q kama "Kamagawa Utsunomiya"
q miya "Utsunomiya Miya Matsuri"
