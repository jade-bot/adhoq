if process.send
  console.info "Socket server listening on IPC"
  server = process
  process.nextTick ->
    server.emit 'connected'
else
  port = 3333
  console.info "Socket server listening on http://localhost:#{port}/"

  engine = require 'engine.io'
  listener = engine.listen port
  
  events = require 'events'
  server = new events.EventEmitter
  
  listener.on 'connection', (socket) ->
    server.send = (data) ->
      socket.send data
    socket.on 'message', (data) ->
      server.send 'message', data
    server.emit 'connected', port

server.on 'connected', ->
  server.send 'Mserving'

server.on 'message', (data) ->
  console.log 'MSG:', data

module.exports = server
