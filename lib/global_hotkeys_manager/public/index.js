function live(id, type, handler) {
  document.addEventListener(type, function(ev) {
    if (ev.target.id == id || ev.target.className == id) handler.apply(this, arguments);
  });
}

function post(path, data) {
  var xhr = new XMLHttpRequest();
  xhr.open('POST', path, true);
  xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
  xhr.send(data);
}

function idFromEv(ev) { return ev.target.dataset.id }

live('js-name', 'change', function(ev) {
  var id = idFromEv(ev);
  post('/update_name/' + id, 'name=' + encodeURIComponent(ev.target.value));
});

