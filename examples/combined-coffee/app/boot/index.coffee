console.log 'Hello from the boot/index.coffee component'

eio = require 'engine.io'  # i.e. LearnBoost/engine.io-client
url = document.URL.replace /.*?:/, 'ws:'
socket = module.exports = new eio.Socket(url)

socket.on 'message', (data) ->
  # first char is dispatch type for incoming websocket messages
  #  M: message, R: reload page, U: update CSS, else treat as JSON request
  msg = data.substr 1
  switch data[0]
    when 'M'
      console.log 'server:', msg
    when 'R'
      console.log 'reload page'
      window.location.reload true
    when 'U'
      console.log 'update CSS'
      for e in document.getElementsByTagName 'link'
        if e.href and /stylesheet/i.test e.rel
          href = e.href.replace /\?.*/, ''
          e.href = "#{href}?#{Date.now()}"
    else
      socket.emit 'request', JSON.parse data

delay = null  # this will be > 0 while attempting reconnects

socket.on 'open', ->
  socket.emit (if delay then 'reconnect' else 'connect')
  delay = 0

socket.on 'close', ->
  # odd but useful: close events also fire on failed reconnects
  socket.emit 'disconnect'  unless delay
  delay += 1000  if delay < 10000
  setTimeout (-> socket.open()), delay

socket.on 'connect', ->
  socket.send 'hello'

socket.on 'reconnect', ->
  window.location.reload true

socket.on 'disconnect', ->
  console.log 'disconnected'
