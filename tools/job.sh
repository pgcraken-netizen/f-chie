#!/bin/bash
set -u
cd tools/job-out
UA="f-chie-site-builder/1.0 (https://f-chie.vercel.app)"
mkdir -p cand
q() {
  curl -sS -A "$UA" -G "https://commons.wikimedia.org/w/api.php" \
    --data-urlencode "action=query" --data-urlencode "format=json" \
    --data-urlencode "generator=search" --data-urlencode "gsrnamespace=6" \
    --data-urlencode "gsrlimit=18" --data-urlencode "gsrsearch=$2 filetype:bitmap" \
    --data-urlencode "prop=imageinfo" --data-urlencode "iiprop=url|extmetadata|size" \
    --data-urlencode "iiurlwidth=360" > "$1.json"
  python3 - "$1" <<'PY'
import json,sys,subprocess,re
tag=sys.argv[1]; d=json.load(open(tag+'.json'))
pages=sorted(d.get('query',{}).get('pages',{}).values(),key=lambda p:p.get('index',0))
with open('list.tsv','a') as f:
  for i,p in enumerate(pages):
    ii=p.get('imageinfo',[{}])[0]; m=ii.get('extmetadata',{})
    name=f"{tag}-{i:02d}.jpg"
    subprocess.run(['curl','-sS','-A','f-chie-site-builder/1.0','-o','cand/'+name,ii.get('thumburl','')])
    f.write('\t'.join([name,p['title'],m.get('LicenseShortName',{}).get('value',''),re.sub('<[^>]+>','',m.get('Artist',{}).get('value','')).strip()[:80],str(ii.get('width')),str(ii.get('height'))])+'\n')
PY
}
q tower "Utsunomiya Tower"
q hachi "Hachimanyama Park Utsunomiya"
q sakura "Utsunomiya cherry blossom"
q view "Utsunomiya cityscape"
