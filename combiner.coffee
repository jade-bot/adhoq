Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'

connectScript = '''
  var eio = require('engine.io'); // i.e. LearnBoost/engine.io-client
  var socket = module.exports = new eio.Socket('ws://localhost/');

  socket.on('open', function () {
    console.log('open!');

    socket.on('message', function (data) {
      // first char is dispatch type for incoming websocket messages
      //  M = message, R = reload page, U = update CSS
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
            e.href = e.href.replace(/\\?.+/, '') + '?' + Date.now();
          }
        }
      }
    });

    socket.on('close', function () {
      console.log('close!');
    });
  });
'''

module.exports = (dir) ->

  (req, res, next) ->
    
    builder = new Builder(dir)
    builder.addLookup('app');
    builder.addLookup('node_modules/briqs');
    
    # see https://github.com/component/builder.js/issues/72
    builder.on 'config', ->
      builder.addFile 'scripts', 'connect.js', connectScript 

    builder.build (err, obj) ->
      if err
        console.log 'build error', err
        return next()

      sizes = {}
      sizes[k] = v.length  for k,v of obj
      debug "sizes", sizes
      
      js = obj.require + obj.js
      res.setHeader 'Content-Type', 'application/javascript'
      res.setHeader 'Content-Length', Buffer.byteLength js
      res.end js
