# This socket server startup code can be used in two different ways:
#
# 1. as a slave server, launched from "adhoq run" and connected to it via IPC
# 2. as a Websocket-only server, talking to local or remote web browsers
#
# The slave mode is useful for development, because the server can be restarted
# anytime by adhoq to reload new code, while keeping the browser(s) connected.
#
# The WS-only mode turns this server into a pure application server, responding
# to all incoming request for dynamic data - "databased-backed" or otherwise.
# In this mode, the browser loads all assets from elsewhere, such as the file
# system, an httpd web server, or a CDN.
#
# The difference between these two modes is fully encapsulated by the following
# code, so that the rest of the server application will work in either mode.

debug = require('debug') 'server'
events = require 'events'
  
server = new events.EventEmitter

dispatchIncoming = (data) ->
  if typeof data is 'string'
    console.log '(client)', data
  else
    server.emit 'ws:message', data...

# - with IPC, messages have already been converted to/from JSON
# - there is only one connection, the clients need to be de-mux'ed
setupSlaveServer = () ->

  server.send = (args...) ->
    process.send args

  process.on 'message', dispatchIncoming

  process.nextTick ->
    server.emit 'ws:connect', 'ipc'

# - need to stringify/parse to use JSON over the wire
# - all connections need to be managed as separate sockets
setupSocketServer = (port) ->  

  engine = require 'engine.io'
  listener = engine.listen port
  
  server.connections = {}

  server.send = (args...) ->    
    data = JSON.stringify if args[1]? then args else args[0]
    for sid, socket of server.connections
      debug 'send %s', args[0], sid
      socket.send data

  listener.on 'connection', (socket) ->
    sid = socket.id
    server.connections[sid] = socket    

    socket.on 'message', (data) ->
      if data[0] is '['
        dispatchIncoming JSON.parse data
      else
        console.log "(#{socket.id})", data
      
    socket.on 'close', ->
      debug 'disconnect', sid
      server.emit 'ws:disconnect', sid
      delete server.connections[sid]
      
    debug 'connect', sid
    server.emit 'ws:connect', sid

if process.send
  debug "Listening on IPC"
  setupSlaveServer()
else
  port = process.env.npm_package_config_port or 3333
  debug "Listening on ws://localhost:#{port}/"
  setupSocketServer port

server.on 'ws:connect', (sid) ->
  server.send 'serving ' + sid

server.on 'ws:message', (data) ->
  console.log 'MSG:', data

module.exports = server
