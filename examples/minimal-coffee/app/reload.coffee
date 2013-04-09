socket = new eio.Socket("ws://localhost/")

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

socket.on "open", ->
  console.log "open!"
  socket.send "hello"

socket.on "close", ->
  console.log "close!"

