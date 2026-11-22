#!/bin/bash
# 実行したい処理をここに書いてpushすると、GitHub Actionsで実行し結果を tools/job-out に保存します
# f-chie.jp のドメイン・DNS設定の確認（読み取りのみ）
for t in NS SOA A AAAA CNAME MX TXT; do echo "== f-chie.jp $t"; dig +short f-chie.jp $t; done
for h in www.f-chie.jp mail.f-chie.jp; do echo "== $h"; dig +short $h A; dig +short $h CNAME; done
echo "== whois"; (sudo apt-get -qq install -y whois >/dev/null 2>&1; whois -h whois.jprs.jp "f-chie.jp/e" 2>&1 | grep -v -i -E "email|phone|fax|address|postal" | head -40)
echo "== http"; curl -sI https://www.f-chie.jp | head -15
