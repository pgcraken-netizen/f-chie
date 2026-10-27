document.querySelector('.burger')?.addEventListener('click', function (e) {
  var open = document.body.classList.toggle('menu-open');
  e.currentTarget.setAttribute('aria-expanded', open);
});
var io = new IntersectionObserver(function (es) {
  es.forEach(function (x) { if (x.isIntersecting) { x.target.classList.add('on'); io.unobserve(x.target); } });
}, { threshold: .08 });
document.querySelectorAll('.rv').forEach(function (el) { io.observe(el); });
var toTop = document.querySelector('.totop');
addEventListener('scroll', function () { toTop && toTop.classList.toggle('on', scrollY > 600); }, { passive: true });

// ===== 文字サイズ（標準／大）。選択はこの端末に記憶 =====
(function () {
  var KEY = 'chie-fs';
  function get() { try { return localStorage.getItem(KEY) || 'm'; } catch (e) { return 'm'; } }
  function set(v) { try { localStorage.setItem(KEY, v); } catch (e) {} }
  function apply(v) {
    document.documentElement.classList.toggle('fs-l', v === 'l');
    document.querySelectorAll('.fs button').forEach(function (b) { b.setAttribute('aria-pressed', b.dataset.fs === v); });
  }
  apply(get());
  document.addEventListener('click', function (e) {
    var b = e.target.closest('.fs button'); if (!b) return;
    set(b.dataset.fs); apply(b.dataset.fs);
  });
})();

// ===== 「私の思うこと」の続きを読む =====
document.querySelectorAll('.fold-btn button').forEach(function (b) {
  b.addEventListener('click', function () {
    var t = document.getElementById(b.getAttribute('aria-controls'));
    var open = t.classList.toggle('open');
    b.setAttribute('aria-expanded', open);
    b.textContent = open ? '閉じる' : '続きを読む';
    if (!open) t.scrollIntoView({ block: 'start' });
  });
});

// ===== お問い合わせフォーム =====
(function () {
  var f = document.getElementById('cform'); if (!f) return;
  var kind = new URLSearchParams(location.search).get('kind');
  if (kind) { Array.prototype.forEach.call(f.kind.options, function (o) { if (o.text === kind) o.selected = true; }); }
  var err = f.querySelector('.form__err'), btn = f.querySelector('.form__send');
  function show(id) { f.hidden = true; var el = document.getElementById(id); el.hidden = false; el.focus(); el.scrollIntoView({ block: 'center' }); }
  function mailto(d) {
    var body = '種別：' + d.kind + '\nお名前：' + d.name + (d.kana ? '（' + d.kana + '）' : '') +
      (d.email ? '\nメール：' + d.email : '') + (d.tel ? '\n電話：' + d.tel : '') + (d.address ? '\nご住所：' + d.address : '') +
      '\n\n' + d.message;
    return 'mailto:info@f-chie.jp?subject=' + encodeURIComponent('【HPお問い合わせ】' + d.kind + '／' + d.name + ' 様') + '&body=' + encodeURIComponent(body);
  }
  f.addEventListener('submit', function (e) {
    e.preventDefault();
    var d = {}; new FormData(f).forEach(function (v, k) { d[k] = typeof v === 'string' ? v.trim() : v; });
    d.agree = f.agree.checked;
    var msg = [];
    if (!d.name) msg.push('お名前');
    if (!d.email && !d.tel) msg.push('メールアドレスか電話番号');
    if (d.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(d.email)) msg.push('正しいメールアドレス');
    if (!d.message) msg.push('内容');
    if (!d.agree) msg.push('プライバシーポリシーへの同意');
    if (msg.length) { err.textContent = msg.join('、') + 'をご確認ください。'; err.hidden = false; err.scrollIntoView({ block: 'center' }); return; }
    err.hidden = true; btn.disabled = true; btn.firstChild.textContent = '送信中…';
    fetch('/api/contact', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(d) })
      .then(function (r) { return r.json().catch(function () { return {}; }).then(function (j) { return { s: r.status, j: j }; }); })
      .then(function (x) {
        if (x.s === 200 && x.j.ok) return show('cdone');
        document.getElementById('cmail').href = mailto(d); show('cfb');
      })
      .catch(function () { document.getElementById('cmail').href = mailto(d); show('cfb'); })
      .finally(function () { btn.disabled = false; btn.firstChild.textContent = '送信する'; });
  });
})();
