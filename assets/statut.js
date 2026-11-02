// Chapter switcher for statut.html. Without JS every chapter is shown in full.
(function () {
  document.body.classList.remove('no-js');
  var buttons = Array.prototype.slice.call(document.querySelectorAll('.chapters button'));
  var chapters = Array.prototype.slice.call(document.querySelectorAll('.chapter'));
  function show(id, scroll) {
    chapters.forEach(function (c) { c.classList.toggle('is-active', c.id === id); });
    buttons.forEach(function (b) { b.setAttribute('aria-selected', String(b.getAttribute('data-chapter') === id)); });
    if (history.replaceState) history.replaceState(null, '', '#' + id);
    if (scroll && window.innerWidth < 960) document.getElementById(id).scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
  buttons.forEach(function (b) {
    b.addEventListener('click', function () { show(b.getAttribute('data-chapter'), true); });
  });
  var initial = location.hash.slice(1);
  show(document.getElementById(initial) && /^cap-\d+$/.test(initial) ? initial : chapters[0].id, false);
})();
