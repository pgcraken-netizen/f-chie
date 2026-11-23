#!/bin/bash
# f-chie.jp 切り替え状況の確認（読み取りのみ） run4
for t in NS A TXT CAA; do echo "== f-chie.jp $t"; dig +short @8.8.8.8 f-chie.jp $t; done
echo "== www"; dig +short @8.8.8.8 www.f-chie.jp; dig +short @8.8.8.8 www.f-chie.jp CAA
for h in f-chie.jp www.f-chie.jp; do
  echo "== cert $h"; echo | openssl s_client -connect $h:443 -servername $h 2>/dev/null | openssl x509 -noout -subject -dates 2>&1 | head -3
  echo "== http $h"; curl -sk -o /tmp/b.html -D - https://$h/ | head -8; grep -o '<title>[^<]*' /tmp/b.html | head -1
done
