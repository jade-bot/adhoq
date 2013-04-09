fs = require 'fs'
debug = require('debug') 'adhoq:utils'

# recursive directory watcher
watch = (path, cb) ->
  fs.stat path, (err, stats) ->
    unless err
      if stats.isDirectory()
        debug 'watch', path
        fs.watch path, {}, cb
        fs.readdir path, (err, files) ->
          unless err
            watch "#{path}/#{file}", cb  for file in files

module.exports = {watch}
