// お問い合わせフォームの送信先（Vercel Serverless Function）
// 必要な環境変数（Vercel のプロジェクト設定 → Environment Variables）
//   RESEND_API_KEY : Resend（https://resend.com）の API キー
//   CONTACT_TO     : 受信するメールアドレス（例：info@f-chie.jp）
//   CONTACT_FROM   : 送信元（Resend で認証したドメインのアドレス。例：form@f-chie.jp）
// 未設定のあいだは 503 を返し、フォーム側がメールソフト・電話での送信に切り替える。

const KINDS = ['ご意見・ご要望', 'ご相談', '後援会への入会', '地域支え合い研究会への参加', '取材・講演のご依頼', 'その他'];
const clip = (v, n) => String(v ?? '').replace(/\r\n?/g, '\n').trim().slice(0, n);
const esc = (s) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

module.exports = async (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'method' });
  }

  let body = req.body;
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch { body = {}; } }
  body = body || {};

  // スパム対策：人間には見えない入力欄に値が入っていたら破棄
  if (clip(body.website, 200)) return res.status(200).json({ ok: true });

  const data = {
    kind: KINDS.includes(body.kind) ? body.kind : 'その他',
    name: clip(body.name, 60),
    kana: clip(body.kana, 60),
    email: clip(body.email, 120),
    tel: clip(body.tel, 30),
    address: clip(body.address, 200),
    message: clip(body.message, 4000),
    agree: body.agree === true || body.agree === 'on' || body.agree === 'true',
  };

  const errors = [];
  if (!data.name) errors.push('name');
  if (!data.email && !data.tel) errors.push('contact');
  if (data.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) errors.push('email');
  if (!data.message) errors.push('message');
  if (!data.agree) errors.push('agree');
  if (errors.length) return res.status(400).json({ ok: false, error: 'invalid', fields: errors });

  const { RESEND_API_KEY, CONTACT_TO, CONTACT_FROM } = process.env;
  if (!RESEND_API_KEY || !CONTACT_TO || !CONTACT_FROM) {
    return res.status(503).json({ ok: false, error: 'not_configured' });
  }

  const rows = [
    ['種別', data.kind], ['お名前', data.name], ['ふりがな', data.kana],
    ['メール', data.email], ['電話', data.tel], ['ご住所', data.address],
  ].filter(([, v]) => v);
  const text = rows.map(([k, v]) => `${k}：${v}`).join('\n') + `\n\n${data.message}\n\n— 福田ちえ 公式サイトのお問い合わせフォームより`;
  const htmlBody = `<table>${rows.map(([k, v]) => `<tr><th align="left">${esc(k)}</th><td>${esc(v)}</td></tr>`).join('')}</table><p style="white-space:pre-wrap">${esc(data.message)}</p><p>— 福田ちえ 公式サイトのお問い合わせフォームより</p>`;

  try {
    const r = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: CONTACT_FROM,
        to: CONTACT_TO.split(',').map((s) => s.trim()),
        reply_to: data.email || undefined,
        subject: `【HPお問い合わせ】${data.kind}／${data.name} 様`,
        text,
        html: htmlBody,
      }),
    });
    if (!r.ok) return res.status(502).json({ ok: false, error: 'send_failed' });
    return res.status(200).json({ ok: true });
  } catch (e) {
    return res.status(502).json({ ok: false, error: 'send_failed' });
  }
};
