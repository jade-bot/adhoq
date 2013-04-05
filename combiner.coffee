Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'

module.exports = (dir) ->

  (req, res, next) ->
    
    console.log 12
    builder = new Builder(dir)

    builder.build (err, obj) ->
      console.log 34
      console.log err
      return next() if err
      console.log 56
      sizes = {}
      sizes[k] = v.length  for k,v of obj
      debug "builds sizes", sizes
      console.log 78
      
      js = obj.require + obj.js
      res.setHeader 'Content-Type', 'application/javascript'
      res.setHeader 'Content-Length', Buffer.byteLength js
      res.end js
