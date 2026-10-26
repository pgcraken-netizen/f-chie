// ===== 表示切替（自動／PC／スマホ） =====
(function () {
  var KEY = 'chie-view';
  var get = function () { try { return localStorage.getItem(KEY) || 'auto'; } catch (e) { return 'auto'; } };
  var set = function (v) { try { v === 'auto' ? localStorage.removeItem(KEY) : localStorage.setItem(KEY, v); } catch (e) {} };
  var vp = document.querySelector('meta[name=viewport]');
  function apply(v) {
    document.documentElement.classList.toggle('view-sp', v === 'sp');
    // スマホで「PC表示」を選んだら、画面幅を1200pxとして描画
    if (vp) vp.setAttribute('content', v === 'pc' ? 'width=1200' : 'width=device-width,initial-scale=1');
    document.querySelectorAll('.viewsw button').forEach(function (b) {
      b.setAttribute('aria-pressed', b.dataset.view === v);
    });
  }
  apply(get());
  document.addEventListener('click', function (e) {
    var b = e.target.closest('.viewsw button');
    if (!b) return;
    set(b.dataset.view); apply(b.dataset.view);
    document.body.classList.remove('menu-open');
  });
})();

// ===== ハンバーガーメニュー =====
document.querySelector('.burger')?.addEventListener('click', function (e) {
  var open = document.body.classList.toggle('menu-open');
  e.currentTarget.setAttribute('aria-expanded', open);
});

// ===== スクロール表示・トップへ戻る =====
var io = new IntersectionObserver(function (es) {
  es.forEach(function (x) { if (x.isIntersecting) { x.target.classList.add('on'); io.unobserve(x.target); } });
}, { threshold: .1 });
document.querySelectorAll('.rv').forEach(function (el) { io.observe(el); });
var toTop = document.querySelector('.totop');
addEventListener('scroll', function () { toTop && toTop.classList.toggle('on', scrollY > 500); }, { passive: true });

// ===== 実績の絞り込み =====
var fb = document.querySelectorAll('.filter button');
fb.forEach(function (b) {
  b.addEventListener('click', function () {
    fb.forEach(function (x) { x.setAttribute('aria-pressed', x === b); });
    document.querySelectorAll('.card').forEach(function (c) {
      c.hidden = !(b.dataset.cat === 'all' || c.dataset.cat === b.dataset.cat);
    });
  });
});
