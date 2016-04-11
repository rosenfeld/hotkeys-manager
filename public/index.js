var list = document.getElementById('list');

function refreshHotkeys(hotkeys) {
  var content = [];
  for (var i = 0; i < hotkeys.length; i++) {
    var hk = hotkeys[i],
      input = '<input data-id=' + hk[0] + ' type=text class=js-name size=30 value="' +
        hk[1] + '" />';

    var button = '<button class=js-update-key data-id=' + hk[0] + ' >Change key</button>';
    content.push('<div data-id=' + hk[0] + ' >' + input + ' ' + button + ' (' + hk[2] +  ')<div>');

  }
  list.innerHTML = content.join("\n")
}

function live(id, type, handler, context) {
  (context || document).addEventListener(type, function(ev) {
    if (ev.target.id == id || ev.target.className == id) handler.apply(this, arguments);
  });
}

function post(path, data) {
  var xhr = new XMLHttpRequest();
  xhr.open('POST', path, true);
  xhr.setRequestHeader("Content-type","application/x-www-form-urlencoded");
  xhr.send(data);
}

function idFromEv(ev) { return ev.target.dataset.id }

refreshHotkeys(HOTKEYS);

live('capture', 'click', function() {
  post('/capture');
  location.reload();
});

live('js-name', 'change', function(ev) {
  var id = idFromEv(ev);
  post('/update_name/' + id, 'name=' + encodeURIComponent(ev.target.value));
});

live('js-update-key', 'click', function(ev) {
  var id = idFromEv(ev);
  post('/update_key/' + id);
  location.reload();
});

