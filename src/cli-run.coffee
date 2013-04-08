liveserver = require './liveserver'

module.exports = (port = 3333) ->  
  liveserver.start './app', port
  console.info "Live server listening on http://localhost:#{port}/"
  
  liveserver.on 'ws:connect', (socket) ->
    socket.sendMessage 'welcome'
  
  liveserver.on 'ws:message', (socket, msg) ->
    console.log 'message:', msg
    socket.sendMessage "echo #{msg}"
