(() => {
  const d = document;
  d.documentElement.classList.add('js');
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  // header: solid after first view
  const hd = d.querySelector('.hd');
  const fv = d.querySelector('.fv');
  const onScroll = () => {
    const limit = fv ? fv.offsetHeight - 90 : 10;
    hd.classList.toggle('is-solid', window.scrollY > limit);
  };
  if (fv) { onScroll(); addEventListener('scroll', onScroll, { passive: true }); }
  else hd.classList.add('is-solid');

  // drawer menu
  const btn = d.querySelector('.menu-btn');
  const drawer = d.getElementById('drawer');
  const setMenu = (open) => {
    btn.setAttribute('aria-expanded', open);
    drawer.hidden = !open;
    d.body.style.overflow = open ? 'hidden' : '';
    hd.classList.toggle('is-solid', open || (fv ? window.scrollY > fv.offsetHeight - 90 : true));
  };
  btn && btn.addEventListener('click', () => setMenu(btn.getAttribute('aria-expanded') !== 'true'));
  drawer && drawer.addEventListener('click', (e) => { if (e.target.closest('a')) setMenu(false); });
  d.addEventListener('keydown', (e) => { if (e.key === 'Escape' && btn && btn.getAttribute('aria-expanded') === 'true') { setMenu(false); btn.focus(); } });

  // count-up
  const countUp = (el) => {
    const to = +el.dataset.count;
    if (reduce || !to) return;
    const t0 = performance.now(), dur = 1400;
    const step = (t) => {
      const p = Math.min(1, (t - t0) / dur);
      el.textContent = Math.round(to * (1 - Math.pow(1 - p, 3)));
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  };

  // scroll reveal
  const items = d.querySelectorAll('.rv');
  if (!('IntersectionObserver' in window) || reduce) {
    items.forEach((el) => el.classList.add('is-in'));
    return;
  }
  const io = new IntersectionObserver((entries) => {
    entries.forEach((en) => {
      if (!en.isIntersecting) return;
      en.target.classList.add('is-in');
      en.target.querySelectorAll('[data-count]').forEach(countUp);
      io.unobserve(en.target);
    });
  }, { rootMargin: '0px 0px -12% 0px', threshold: 0.05 });
  items.forEach((el) => io.observe(el));
})();
