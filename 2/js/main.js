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
