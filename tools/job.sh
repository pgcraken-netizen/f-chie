#!/bin/bash
# 宇都宮市議会「質問者名と質問項目」から福田智恵議員の質問を抽出（公開ページの読み取りのみ）
mkdir -p tools/job-out
python3 - <<'PY'
import re, json, urllib.request, html, time
UA={'User-Agent':'Mozilla/5.0'}
BASE='https://www.city.utsunomiya.lg.jp'
def get(u):
    for _ in range(3):
        try: return urllib.request.urlopen(urllib.request.Request(u,headers=UA),timeout=30).read().decode('utf-8','ignore')
        except Exception as e: err=e; time.sleep(2)
    print('fail',u,err); return ''
def text(h):
    h=re.sub(r'<script.*?</script>|<style.*?</style>','',h,flags=re.S)
    h=re.sub(r'<br\s*/?>|</(p|li|h\d|div|tr|td|th)>','\n',h)
    t=html.unescape(re.sub(r'<[^>]+>','',h))
    return '\n'.join(l.strip() for l in t.split('\n') if l.strip())
idx=get(BASE+'/gikai/kaigi/tsukoku/index.html')
links=[]
for m in re.finditer(r'href="(/gikai/kaigi/tsukoku/[0-9/]+(?:index)?\.html)"[^>]*>([^<]+)<',idx):
    u,n=m.group(1),m.group(2).strip()
    if ('定例会' in n or '臨時会' in n) and (u,n) not in links: links.append((u,n))
out=[]
for u,n in links:
    pages=[u]; h=get(BASE+u)
    sub=sorted(set(re.findall(r'href="(/gikai/kaigi/tsukoku/\d+/\d+\.html)"',h)))
    pages+= [s for s in sub if s!=u]
    for pg in pages:
        hh=h if pg==u else get(BASE+pg)
        t=text(hh)
        for m in re.finditer(r'福田\s*智恵', t):
            st=max(0,t.rfind('\n',0,m.start()))
            nxt=re.search(r'\n[^\n]{0,12}(議員|委員)\s*\n?[（(]', t[m.end():])
            seg=t[st:m.end()+ (nxt.start() if nxt else 1500)]
            seg=seg[:2500]
            out.append({'session':n,'url':BASE+pg,'text':seg})
    time.sleep(0.5)
# 重複除去
seen=set(); res=[]
for o in out:
    k=(o['session'],o['text'][:200])
    if k in seen: continue
    seen.add(k); res.append(o)
json.dump(res,open('tools/job-out/fukuda_questions.json','w'),ensure_ascii=False,indent=1)
print('sessions',len(links),'hits',len(res))
PY
