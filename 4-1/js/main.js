(() => {
  const d = document;
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const hd = d.querySelector('.hd');
  const toTop = d.querySelector('.totop');
  const onScroll = () => {
    hd.classList.toggle('is-scrolled', scrollY > 10);
    if (toTop) toTop.classList.toggle('is-show', scrollY > 600);
  };
  onScroll(); addEventListener('scroll', onScroll, { passive: true });

  const btn = d.querySelector('.menu-btn');
  const drawer = d.getElementById('drawer');
  const setMenu = (open) => {
    btn.setAttribute('aria-expanded', open);
    drawer.hidden = !open;
    d.body.style.overflow = open ? 'hidden' : '';
  };
  btn && btn.addEventListener('click', () => setMenu(btn.getAttribute('aria-expanded') !== 'true'));
  drawer && drawer.addEventListener('click', (e) => { if (e.target.closest('a')) setMenu(false); });
  d.addEventListener('keydown', (e) => { if (e.key === 'Escape' && btn.getAttribute('aria-expanded') === 'true') { setMenu(false); btn.focus(); } });

  // scroll reveal
  const items = d.querySelectorAll('.vcard, .tk, .value__panel, .banner, .profile, .teaser');
  if (reduce || !('IntersectionObserver' in window)) return;
  items.forEach((el) => el.classList.add('rv'));
  const io = new IntersectionObserver((es) => es.forEach((e) => {
    if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); }
  }), { rootMargin: '0px 0px -8% 0px' });
  items.forEach((el, i) => { el.style.transitionDelay = (i % 6) * 60 + 'ms'; io.observe(el); });
})();
