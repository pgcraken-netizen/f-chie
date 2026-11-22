#!/bin/bash
# 実行したい処理をここに書いてpushすると、GitHub Actionsで実行し結果を tools/job-out に保存します
# f-chie.jp（Jimdo）の「地域支え合い研究会」関連6ページから本文画像を取得
set -u
mkdir -p tools/job-out/kenkyu
cd tools/job-out/kenkyu
python3 - <<'PY'
import re, urllib.request, urllib.parse, json, os
pages = ['ちえの輪-地域支え合い研究会/', 'ちえの輪-社会活動/',
         'ちえの輪-地域支え合い研究会/過去の活動2/', 'ちえの輪-地域支え合い研究会/過去の活動3/',
         'ちえの輪-地域支え合い研究会/過去の活動4/', 'ちえの輪-地域支え合い研究会/過去の活動5/']
UA = {'User-Agent': 'Mozilla/5.0'}
man = {}
for p in pages:
    url = 'https://www.f-chie.jp/' + urllib.parse.quote(p)
    try:
        html = urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30).read().decode('utf-8', 'ignore')
    except Exception as e:
        print('page fail', p, e); continue
    for tag in re.findall(r'<img[^>]+>', html):
        iid = re.search(r'data-image-id="(\d+)"', tag)
        if not iid: continue
        iid = iid.group(1)
        if iid in man: continue
        cands = re.findall(r'(https://image\.jimcdn\.com/[^\s",]+)\s+(\d+)w', tag)
        src = max(cands, key=lambda c: int(c[1]))[0] if cands else (re.search(r'data-src="([^"]+)"', tag) or re.search(r'src="([^"]+)"', tag)).group(1)
        src = src.replace('&amp;', '&')
        # できるだけ大きい版を取得（dimension=を拡大）
        big = re.sub(r'dimension=\d+x\d+', 'dimension=1200x10000', src)
        ext = 'png' if 'format=png' in src or src.endswith('.png') else 'jpg'
        fn = f'{iid}.{ext}'
        for u in (big, src):
            try:
                data = urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=30).read()
                open(fn, 'wb').write(data); man[iid] = {'file': fn, 'src': u, 'page': p}; break
            except Exception as e:
                print('img fail', iid, u, e)
json.dump(man, open('manifest.json', 'w'), ensure_ascii=False, indent=1)
print('images', len(man))
PY
