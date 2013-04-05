Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'

module.exports = (dir) ->

  (req, res, next) ->
    
    builder = new Builder(dir)
    builder.build (err, obj) ->
      throw err  if err
      sizes = {}
      sizes[k] = v.length  for k,v of obj
      debug "builds sizes", sizes
      
      js = obj.require + obj.js
      res.setHeader 'Content-Type', 'application/javascript'
      res.setHeader 'Content-Length', Buffer.byteLength js
      res.end js
