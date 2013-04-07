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
  app.use '/build.js', combiner 'js'
  app.use '/build.css', combiner 'css'
  app.use converter CLIENT_DIR
  app.use connect.static CLIENT_DIR

  listener = http.createServer(app).listen port
  server = engine.attach listener
  
  app.connections = {}
  
  app.sendToAll = (data) ->
    for sid, socket of app.connections
      debug 'send %s', data, sid
      socket.send data

  # recursive directory watcher
  watch = (path, cb) ->
    fs.stat path, (err, stats) ->
      unless err
        if stats.isDirectory()
          debug 'watch', path
          fs.watch path, {}, cb
          fs.readdir path, (err, files) ->
            unless err
              watch "#{path}/#{file}", cb  for file in files

  watch CLIENT_DIR, (event, path) ->
    if event is 'change'
      debug 'file change', path
      app.sendToAll (if path.match /\.(css|styl)$/i then 'U' else 'R')
  
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

# fail = (err, code, args...) ->
#   console.error args...
#   console.error err  unless err.code is code
#   process.exit 1
