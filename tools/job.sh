#!/bin/bash
# Wikimedia Commons から宇都宮の写真候補を検索し、サムネイルとライセンス情報を保存
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
q() { # $1=tag $2=search
  curl -sS -A "$UA" -G "https://commons.wikimedia.org/w/api.php" \
    --data-urlencode "action=query" --data-urlencode "format=json" \
    --data-urlencode "generator=search" --data-urlencode "gsrnamespace=6" \
    --data-urlencode "gsrlimit=24" --data-urlencode "gsrsearch=$2 filetype:bitmap" \
    --data-urlencode "prop=imageinfo" --data-urlencode "iiprop=url|extmetadata|size" \
    --data-urlencode "iiurlwidth=360" > "$1.json"
  python3 - "$1" <<'PY'
import json,sys,subprocess,os
tag=sys.argv[1]; d=json.load(open(tag+'.json'))
pages=sorted(d.get('query',{}).get('pages',{}).values(),key=lambda p:p.get('index',0))
os.makedirs('thumbs',exist_ok=True)
with open('list.tsv','a') as f:
  for i,p in enumerate(pages):
    ii=p.get('imageinfo',[{}])[0]; m=ii.get('extmetadata',{})
    lic=m.get('LicenseShortName',{}).get('value',''); art=m.get('Artist',{}).get('value','')
    name=f"{tag}-{i:02d}.jpg"
    subprocess.run(['curl','-sS','-A','f-chie-site-builder/1.0','-o','thumbs/'+name,ii.get('thumburl','')])
    f.write('\t'.join([name,p['title'],lic,art.replace('\t',' ').replace('\n',' ')[:200],ii.get('url',''),str(ii.get('width')),str(ii.get('height'))])+'\n')
PY
}
q lrt "Utsunomiya Light Rail"
q street "Utsunomiya street"
q hall "Utsunomiya City Hall"
q orion "Orion-dori Utsunomiya"
q matsuri "Utsunomiya festival"
q school "Utsunomiya elementary school"
q station "Utsunomiya Station"
q park "Utsunomiya park"
q futara "Futarasan jinja Utsunomiya"
q tochigi "Tochigi residential street"
ls thumbs | wc -l
