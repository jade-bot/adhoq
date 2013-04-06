Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'

module.exports = (dir) ->

  (req, res, next) ->
    
    builder = new Builder(dir)
    # TODO get these paths from component.json or make them configurable
    builder.addLookup('app');
    builder.addLookup('node_modules/briqs');
    
    # # see https://github.com/component/builder.js/issues/72
    # builder.on 'config', ->
    #   builder.addFile 'scripts', 'connect.js', connectScript 

    builder.build (err, obj) ->
      if err
        console.log 'build error', err
        return next()

      sizes = {}
      sizes[k] = v.length  for k,v of obj
      debug "sizes", sizes
      
      js = obj.require + obj.js
      res.setHeader 'Content-Type', 'application/javascript'
      res.setHeader 'Content-Length', Buffer.byteLength js
      res.end js
