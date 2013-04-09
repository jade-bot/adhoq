console.log 'Hello from the boot/index.coffee component'

eio = require 'engine.io'  # i.e. LearnBoost/engine.io-client
url = document.URL.replace /.*?:/, 'ws:'
if url.slice(0, 6) is 'ws:///'
  url = 'ws://localhost:3333/' # FIXME temporary hack
socket = module.exports = new eio.Socket(url)

socket.on 'message', (data) ->
  msg = JSON.parse data
  #  string: message, true: reload page, false: update CSS, else: request
  switch typeof msg
    when 'string'
      console.log '(server)', msg
    when 'boolean'
      if msg
        console.log 'reload page'
        window.location.reload true
      else
        console.log 'update CSS'
        for e in document.getElementsByTagName 'link'
          if e.href and /stylesheet/i.test e.rel
            href = e.href.replace /\?.*/, ''
            e.href = "#{href}?#{Date.now()}"
    else
      socket.emit 'request', msg

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
