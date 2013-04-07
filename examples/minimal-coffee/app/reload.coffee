socket = new eio.Socket("ws://localhost/")

socket.on "message", (data) ->
  # first char is dispatch type for incoming websocket messages
  #  M = message, R = reload page, U = update CSS
  if data[0] is "M"
    console.log "message:", data.substr(1)
  else if data is "R"
    console.log "reload page"
    window.location.reload true
  else if data is "U"
    console.log "update CSS"
    elems = document.getElementsByTagName("link")
    for e in elems when e.href and e.rel.match(/stylesheet/i)
      e.href = e.href.replace(/\?.+/, "") + "?" + Date.now()

socket.on "open", ->
  console.log "open!"
  socket.send "hello"

socket.on "close", ->
  console.log "close!"

