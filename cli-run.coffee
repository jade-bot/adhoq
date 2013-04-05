connect = require 'connect'
http = require 'http'
engine = require 'engine.io'
debug = require('debug') 'adhoq:run'
fs = require 'fs'
converter = require './converter'
combiner = require './combiner'

CLIENT_DIR = './app'  # this gets served and is watched for changes

module.exports = (port = 3333) ->
  app = connect()

  app.use connect.logger 'dev'
  app.use '/build.js', combiner CLIENT_DIR
  app.use converter CLIENT_DIR
  app.use connect.static CLIENT_DIR

  listener = http.createServer(app).listen port
  server = engine.attach listener
  
  app.connections = {}
  
  app.sendToAll = (data) ->
    for sid, socket of app.connections
      debug 'send %s', data, sid
      socket.send data

  try
    watcher = fs.watch CLIENT_DIR, {}, (event, filename) ->
      debug 'file %s', event, filename
      app.sendToAll (if filename.match /\.(css|styl)$/i then 'U' else 'R')
  catch err
    fail err, 'ENOENT', 'Directory not found: %s', CLIENT_DIR
  
  server.on 'connection', (socket) ->
    sid = socket.id
    app.connections[sid] = socket
    
    socket.sendMessage = (msg) ->
      socket.send "M#{msg}"
    
    debug 'connect', sid
    app.emit 'ws:connect', socket

    socket.on 'message', (data) ->
      app.emit 'ws:message', socket, data

    socket.on 'close', ->
      debug 'disconnect', sid
      app.emit 'ws:close', socket
      delete app.connections[sid]

  console.info "Live preview server listening on http://localhost:#{port}/"
  
  # TODO test code
  
  app.on 'ws:connect', (socket) ->
    socket.sendMessage 'welcome'
  
  app.on 'ws:message', (socket, msg) ->
    console.log 'message:', msg
    socket.sendMessage "echo #{msg}"

fail = (err, code, args...) ->
  console.error args...
  console.error err  unless err.code is code
  process.exit 1
