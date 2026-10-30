const menu = document.querySelector('.menu');
const navigation = document.querySelector('#navigation');
function closeMenu(){navigation.classList.remove('open');menu.setAttribute('aria-expanded','false');menu.setAttribute('aria-label','メニューを開く');menu.textContent='☰';}
menu.addEventListener('click',()=>{const open=menu.getAttribute('aria-expanded')!=='true';navigation.classList.toggle('open',open);menu.setAttribute('aria-expanded',String(open));menu.setAttribute('aria-label',open?'メニューを閉じる':'メニューを開く');menu.textContent=open?'×':'☰';});
navigation.querySelectorAll('a').forEach(a=>a.addEventListener('click',closeMenu));
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&menu.getAttribute('aria-expanded')==='true'){closeMenu();menu.focus();}});
