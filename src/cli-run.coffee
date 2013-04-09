liveserver = require './liveserver'
fs = require 'fs'
{spawn} = require 'child_process'

module.exports = (port = 3333) ->
  
  if fs.existsSync('./server') or fs.existsSync('./server.js')
    child = spawn 'node', ['server'],
      stdio: ['ipc', 1, 2]
      env: process.env

    child.on 'message', (data) ->
      console.info '>', data
      child.send 'echo: ' + data
  
  liveserver.start './app', port
  console.info "Live server listening on http://localhost:#{port}/"
  
  liveserver.on 'ws:connect', (socket) ->
    socket.sendMessage 'welcome'
  
  liveserver.on 'ws:message', (socket, msg) ->
    console.log 'message:', msg
    socket.sendMessage "echo #{msg}"
