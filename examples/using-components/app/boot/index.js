console.log('haha');
var eio = require('engine.io');
var socket = new eio.Socket('ws://localhost/');
socket.on('open', function () {
  console.log('open!');
  socket.on('message', function (data) {
    if (data[0] == 'M') {
      console.log('message:', data.substr(1));
    } else if (data == 'R') {
      console.log('reload page');
      window.location.reload(true);
    } else if (data == 'U') {
      console.log('update CSS');
      var elems = document.getElementsByTagName("link");
      for (var i = 0; i < elems.length; ++i) {
        var e = elems[i];
        if (e.href && e.rel.match(/stylesheet/i)) {
          e.href = e.href.replace(/\?.+/, "") + "?" + Date.now();
        }
      }
    }
  });
  socket.on('close', function () {
    console.log('close!');
  });
  socket.send('hello');
});
