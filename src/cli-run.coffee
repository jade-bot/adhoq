server = require './liveserver'
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
  
  server.start './app', port
  console.info "Live server listening on http://localhost:#{port}/"
  
  server.on 'ws:connect', (sid) ->
    server.broadcast "welcome #{sid}"
  
  server.on 'ws:message', (sid, msg) ->
    console.log "(#{sid})", msg
    server.broadcast "echo #{msg}"
