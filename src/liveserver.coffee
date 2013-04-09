connect = require 'connect'
http = require 'http'
engine = require 'engine.io'
fs = require 'fs'
converter = require './converter'
combiner = require './combiner'
debug = require('debug') 'adhoq:run'

app = module.exports = connect()

app.start = (appDir, port) ->
  app.use connect.logger 'dev'
  app.use '/build.js', combiner.build 'js'
  app.use '/build.css', combiner.build 'css'
  app.use converter appDir
  app.use connect.static appDir

  listener = http.createServer(app).listen port
  server = engine.attach listener
  
  app.connections = {}
  
  sendToAll = (data) ->
    for sid, socket of app.connections
      debug 'send %s', data, sid
      socket.send data
      
  app.broadcast = (tag, args) ->
    if args?
      sendToAll JSON.stringify [tag, args]
    else
      sendToAll 'M' + tag

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

  watch appDir, (event, path) ->
    if event is 'change'
      debug 'file change', path
      unless /\.(html|jade)$/.test path
        combiner.invalidate()
      sendToAll (if /\.(css|styl)$/.test path then 'U' else 'R')
  
  server.on 'connection', (socket) ->
    sid = socket.id
    app.connections[sid] = socket
    
    socket.sendMessage = (msg) ->
      socket.send msg
    
    debug 'connect', sid
    app.emit 'ws:connect', socket

    socket.on 'message', (data) ->
      try # ignore errors
        json = JSON.parse data  if data[0] is '['
      if json
        app.emit 'ws:request', socket, json
      else
        app.emit 'ws:message', socket, data

    socket.on 'close', ->
      debug 'disconnect', sid
      app.emit 'ws:disconnect', socket
      delete app.connections[sid]
