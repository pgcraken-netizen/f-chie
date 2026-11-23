#!/bin/bash
# f-chie.jp の現在のDNSレコード確認（読み取りのみ・公開DNSに問い合わせ）
for s in 8.8.8.8 ns1.jimdo.com; do
  echo "##### server $s"
  for t in NS SOA A AAAA MX TXT CAA; do echo "== f-chie.jp $t"; dig +short @$s f-chie.jp $t; done
  for h in www mail smtp imap pop autodiscover _dmarc default._domainkey; do echo "== $h.f-chie.jp"; dig +short @$s $h.f-chie.jp ANY; dig +short @$s $h.f-chie.jp A; dig +short @$s $h.f-chie.jp CNAME; dig +short @$s $h.f-chie.jp TXT; done
done
