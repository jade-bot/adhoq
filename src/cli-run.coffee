server = require './liveserver'
fs = require 'fs'
{watch} = require './utils'
{spawn} = require 'child_process'
debug = require('debug') 'adhoq:run'

child = null

module.exports = (port = 3333) ->
  
  watchSlave './server'

  server.start './app', port
  console.info "Live server listening on http://localhost:#{port}/"
  
  server.on 'ws:connect', (sid) ->
    server.broadcast "welcome #{sid}"
  
  server.on 'ws:message', (sid, msg) ->
    console.log "(#{sid})", msg
    server.broadcast "echo #{msg}"

watchSlave = (dir) ->
  if fs.existsSync dir
    launchSlave dir
    
    # send a signal to the slave server wheneever a file changes
    watch dir, (event, path) ->
      if event is 'change'
        debug 'server change', path
        if child
          child.kill 'SIGHUP'
        else
          launchSlave dir
    
launchSlave = (dir) ->
  debug 'launch slave', dir
  
  child = spawn 'node', [dir],
    stdio: ['ipc', 1, 2]
    env: process.env

  child.on 'message', (data) ->
    console.info '(server)', data
    child.send 'echo: ' + data

  child.on 'exit', (code, signal) ->
    child = null
    if signal is 'SIGHUP'
      console.log 'restarting slave server'
      setTimeout ->
        launchSlave dir
      , 500
    else
      console.log 'slave server exit code', code
