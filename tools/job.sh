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
links=[('/gikai/kaigi/tsukoku/1008629.html', 'H26-03'), ('/gikai/kaigi/tsukoku/1008622.html', 'H26-06'), ('/gikai/kaigi/tsukoku/1008615.html', 'H26-09'), ('/gikai/kaigi/tsukoku/1008608.html', 'H26-12'), ('/gikai/kaigi/tsukoku/1008601.html', 'H27-03'), ('/gikai/kaigi/tsukoku/1008594.html', 'H27-06'), ('/gikai/kaigi/tsukoku/1008587.html', 'H27-09'), ('/gikai/kaigi/tsukoku/1008580.html', 'H27-12'), ('/gikai/kaigi/tsukoku/1008573.html', 'H28-03'), ('/gikai/kaigi/tsukoku/1008566.html', 'H28-06'), ('/gikai/kaigi/tsukoku/1011723.html', 'H28-09'), ('/gikai/kaigi/tsukoku/1012974.html', 'H28-12'), ('/gikai/kaigi/tsukoku/1013394.html', 'H29-03'), ('/gikai/kaigi/tsukoku/1014311.html', 'H29-06'), ('/gikai/kaigi/tsukoku/1014717.html', 'H29-09'), ('/gikai/kaigi/tsukoku/1015133.html', 'H29-12'), ('/gikai/kaigi/tsukoku/1015678.html', 'H30-03'), ('/gikai/kaigi/tsukoku/1016263.html', 'H30-06'), ('/gikai/kaigi/tsukoku/1016819.html', 'H30-09'), ('/gikai/kaigi/tsukoku/1017476.html', 'H30-12'), ('/gikai/kaigi/tsukoku/1018661.html', 'H31-03'), ('/gikai/kaigi/tsukoku/1020850.html', 'R01-06'), ('/gikai/kaigi/tsukoku/1021336.html', 'R01-09'), ('/gikai/kaigi/tsukoku/1022072.html', 'R01-12'), ('/gikai/kaigi/tsukoku/1022641.html', 'R02-03'), ('/gikai/kaigi/tsukoku/1024602.html', 'R02-06'), ('/gikai/kaigi/tsukoku/1025188.html', 'R02-09'), ('/gikai/kaigi/tsukoku/1025665.html', 'R02-12'), ('/gikai/kaigi/tsukoku/1026423.html', 'R03-03'), ('/gikai/kaigi/tsukoku/1026719.html', 'R03-03質疑'), ('/gikai/kaigi/tsukoku/1027205.html', 'R03-06'), ('/gikai/kaigi/tsukoku/1027236.html', 'R03-06質疑'), ('/gikai/kaigi/tsukoku/1027647.html', 'R03-09'), ('/gikai/kaigi/tsukoku/1028132.html', 'R03-12'), ('/gikai/kaigi/tsukoku/1028768.html', 'R04-03'), ('/gikai/kaigi/tsukoku/1029468.html', 'R04-06'), ('/gikai/kaigi/tsukoku/1029883.html', 'R04-09'), ('/gikai/kaigi/tsukoku/1030319.html', 'R04-12'), ('/gikai/kaigi/tsukoku/1030932.html', 'R05-03'), ('/gikai/kaigi/tsukoku/1032424.html', 'R05-06'), ('/gikai/kaigi/tsukoku/1032995.html', 'R05-09'), ('/gikai/kaigi/tsukoku/1033442.html', 'R05-12'), ('/gikai/kaigi/tsukoku/1034136.html', 'R06-03'), ('/gikai/kaigi/tsukoku/1036078.html', 'R06-06'), ('/gikai/kaigi/tsukoku/1036748.html', 'R06-09'), ('/gikai/kaigi/tsukoku/1039540.html', 'R06-12'), ('/gikai/kaigi/tsukoku/1040280.html', 'R07-03'), ('/gikai/kaigi/tsukoku/1041102.html', 'R07-06'), ('/gikai/kaigi/tsukoku/1041515.html', 'R07-09'), ('/gikai/kaigi/tsukoku/1043752.html', 'R07-12'), ('/gikai/kaigi/tsukoku/1044478.html', 'R08-03'), ('/gikai/kaigi/tsukoku/1047887.html', 'R08-06'), ('/gikai/kaigi/tsukoku/1048793.html', 'R08-09'), ('/gikai/kaigi/tsukoku/1050139.html', 'R08-12')]
out=[]
for u,n in links:
    pages=[u]; h=get(BASE+u)
    if len(h)<2000: u2=u.replace('.html','/index.html'); h=get(BASE+u2); u=u2 if h else u
    sub=sorted(set(re.findall(r'href="(?:https://www\.city\.utsunomiya\.lg\.jp)?(/gikai/kaigi/tsukoku/\d+/\d+\.html)"',h)))
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
