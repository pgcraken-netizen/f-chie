#!/bin/bash
# f-chie.jp なりすまし防止レコードの確認（読み取りのみ）
echo "== TXT"; dig +short @hera.ns.cloudflare.com f-chie.jp TXT
echo "== _dmarc"; dig +short @hera.ns.cloudflare.com _dmarc.f-chie.jp TXT
