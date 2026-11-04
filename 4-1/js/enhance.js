/* 案4-1 追加機能 */
(() => {
  const d = document;
  const html = d.documentElement;
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- 公式SNS（ここに追加すればレール・一覧の両方に反映） ---------- */
  const SNS = [
    {
      name: 'Facebook',
      note: '日々の活動やその思いを発信しています',
      url: 'https://www.facebook.com/share/1K62X7trj1/?mibextid=wwXIfr',
      icon: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a10 10 0 0 0-1.6 19.9v-7H7.9V12h2.5V9.8c0-2.5 1.5-3.9 3.8-3.9 1.1 0 2.2.2 2.2.2v2.5h-1.3c-1.2 0-1.6.8-1.6 1.6V12h2.8l-.4 2.9h-2.4v7A10 10 0 0 0 12 2z"/></svg>'
    }
    // 例：{ name:'Instagram', note:'…', url:'https://www.instagram.com/…', icon:'<svg …>' }
  ];
  d.querySelectorAll('[data-sns-list]').forEach((ul) => {
    const isRail = !!ul.closest('.snsrail');
    ul.innerHTML = SNS.map((s) => isRail
      ? `<li><a href="${s.url}" target="_blank" rel="noopener" aria-label="${s.name}（新しいタブで開きます）">${s.icon}<span class="tip">${s.name}</span></a></li>`
      : `<li><a href="${s.url}" target="_blank" rel="noopener">${s.icon}<span><b>${s.name}（公式）</b><small>${s.note}</small></span></a></li>`
    ).join('');
  });

  /* SNSレールはヒーロー画像の上では隠し、本文に入ったら表示 */
  const rail = d.querySelector('.snsrail');
  const heroEl = d.querySelector('.fv');
  if (rail && heroEl) {
    const r = () => rail.classList.toggle('is-hidden', heroEl.getBoundingClientRect().bottom > 120);
    r(); addEventListener('scroll', r, { passive: true }); addEventListener('resize', r);
  }

  /* ---------- ローディング ---------- */
  const loader = d.getElementById('loader');
  const hideLoader = () => {
    if (!html.classList.contains('is-loading') || !loader || loader.classList.contains('is-out')) return;
    loader.classList.add('is-out');
    try { sessionStorage.setItem('chie-loaded', '1'); } catch (e) {}
    setTimeout(() => html.classList.remove('is-loading'), 800);
  };
  if (html.classList.contains('is-loading')) {
    const start = window.__ldStart || Date.now();
    const MIN = 1100, MAX = 2600;
    const done = () => setTimeout(hideLoader, Math.max(0, MIN - (Date.now() - start)));
    if (d.readyState === 'complete') done(); else addEventListener('load', done, { once: true });
    setTimeout(hideLoader, MAX);           // 読み込みが遅くても待たせすぎない
    loader && loader.addEventListener('click', hideLoader);
  }

  /* ---------- スライドショー ---------- */
  const fv = d.querySelector('.fv');
  const slides = fv ? [...fv.querySelectorAll('.slide')] : [];
  if (slides.length > 1) {
    const dots = [...fv.querySelectorAll('.fv__dots button')];
    const pauseBtn = fv.querySelector('.fv__pause');
    const INTERVAL = 6500;
    let i = 0, timer = null, userPaused = reduce, hover = false;
    const show = (n) => {
      i = (n + slides.length) % slides.length;
      slides.forEach((s, k) => {
        s.classList.toggle('is-active', k === i);
        s.setAttribute('aria-hidden', k === i ? 'false' : 'true');
        if (k === i) s.querySelectorAll('img[loading="lazy"]').forEach((im) => { im.loading = 'eager'; });
      });
      dots.forEach((b, k) => b.setAttribute('aria-selected', k === i ? 'true' : 'false'));
      // 次のスライド画像を先読み
      const next = slides[(i + 1) % slides.length];
      next && next.querySelectorAll('img[loading="lazy"]').forEach((im) => { im.loading = 'eager'; });
    };
    const stop = () => { clearInterval(timer); timer = null; };
    const play = () => { stop(); if (!userPaused && !hover && !d.hidden) timer = setInterval(() => show(i + 1), INTERVAL); };
    const go = (n) => { show(n); play(); };
    fv.querySelector('.fv__prev').addEventListener('click', () => go(i - 1));
    fv.querySelector('.fv__next').addEventListener('click', () => go(i + 1));
    dots.forEach((b, k) => b.addEventListener('click', () => go(k)));
    const syncPause = () => {
      pauseBtn.setAttribute('aria-pressed', userPaused ? 'true' : 'false');
      pauseBtn.setAttribute('aria-label', userPaused ? '自動再生を開始' : '自動再生を停止');
    };
    pauseBtn.addEventListener('click', () => { userPaused = !userPaused; syncPause(); play(); });
    fv.addEventListener('mouseenter', () => { hover = true; stop(); });
    fv.addEventListener('mouseleave', () => { hover = false; play(); });
    fv.addEventListener('focusin', () => { hover = true; stop(); });
    fv.addEventListener('focusout', () => { hover = false; play(); });
    d.addEventListener('visibilitychange', play);
    // スワイプ（スマートフォン）
    let sx = null;
    fv.addEventListener('touchstart', (e) => { sx = e.touches[0].clientX; }, { passive: true });
    fv.addEventListener('touchend', (e) => {
      if (sx === null) return;
      const dx = e.changedTouches[0].clientX - sx; sx = null;
      if (Math.abs(dx) > 50) go(i + (dx < 0 ? 1 : -1));
    }, { passive: true });
    syncPause(); show(0); play();
  }

  /* ---------- 現在のセクションをナビに表示 ---------- */
  const navLinks = [...d.querySelectorAll('.gnav a[href^="#"]')];
  const targets = navLinks.map((a) => d.getElementById(a.getAttribute('href').slice(1))).filter(Boolean);
  if ('IntersectionObserver' in window && targets.length) {
    const spy = new IntersectionObserver((es) => {
      es.forEach((e) => {
        if (!e.isIntersecting) return;
        navLinks.forEach((a) => {
          const on = a.getAttribute('href') === '#' + e.target.id;
          a.classList.toggle('is-current', on);
          if (on) a.setAttribute('aria-current', 'location'); else a.removeAttribute('aria-current');
        });
      });
    }, { rootMargin: '-45% 0px -50% 0px' });
    targets.forEach((t) => spy.observe(t));
  }

  /* ---------- セクションのフェードイン ---------- */
  const secs = d.querySelectorAll('.sec__head, .party__grid, .mv__list');
  if (!reduce && 'IntersectionObserver' in window) {
    secs.forEach((el) => el.classList.add('rv-sec'));
    const io = new IntersectionObserver((es) => es.forEach((e) => {
      if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); }
    }), { rootMargin: '0px 0px -8% 0px' });
    secs.forEach((el) => io.observe(el));
  }

  /* ---------- 動画（タップで再生・音声の自動再生なし） ---------- */
  const modal = d.getElementById('mvmodal');
  if (modal) {
    const media = modal.querySelector('.mvmodal__media');
    const title = modal.querySelector('.mvmodal__t');
    let lastBtn = null;
    const close = () => {
      media.innerHTML = '';
      modal.hidden = true;
      d.body.style.overflow = '';
      lastBtn && lastBtn.focus();
    };
    d.querySelectorAll('.mv[data-video], .mv[data-youtube]').forEach((btn) => {
      btn.addEventListener('click', () => {
        lastBtn = btn;
        title.textContent = btn.dataset.title || '';
        if (btn.dataset.youtube) {
          const id = encodeURIComponent(btn.dataset.youtube);
          media.innerHTML = `<iframe src="https://www.youtube-nocookie.com/embed/${id}?autoplay=1&mute=1&cc_load_policy=1&playsinline=1&rel=0" title="${title.textContent}" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>`;
        } else {
          const v = d.createElement('video');
          v.src = btn.dataset.video; v.controls = true; v.playsInline = true; v.muted = true; v.preload = 'metadata';
          if (btn.dataset.track) {
            const t = d.createElement('track');
            t.kind = 'captions'; t.srclang = 'ja'; t.label = '日本語'; t.src = btn.dataset.track;
            v.appendChild(t);
          }
          media.appendChild(v);
          const p = v.play(); if (p && p.catch) p.catch(() => {});
        }
        modal.hidden = false;
        d.body.style.overflow = 'hidden';
        modal.querySelector('.mvmodal__close').focus();
      });
    });
    modal.querySelector('.mvmodal__close').addEventListener('click', close);
    modal.addEventListener('click', (e) => { if (e.target === modal) close(); });
    d.addEventListener('keydown', (e) => { if (e.key === 'Escape' && !modal.hidden) close(); });
  }
})();
