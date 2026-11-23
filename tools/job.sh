#!/bin/bash
# f-chie.jp 切り替え状況の確認（読み取りのみ） run2
for t in NS A TXT; do echo "== f-chie.jp $t"; dig +short @8.8.8.8 f-chie.jp $t; done
echo "== www"; dig +short @8.8.8.8 www.f-chie.jp
echo "== https www"; curl -sS -o /dev/null -w "%{http_code} %{ssl_verify_result}\n" https://www.f-chie.jp/ 2>&1 | head -3
echo "== cert www"; echo | openssl s_client -connect www.f-chie.jp:443 -servername www.f-chie.jp 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>&1 | head -5
echo "== cert apex"; echo | openssl s_client -connect f-chie.jp:443 -servername f-chie.jp 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>&1 | head -5
