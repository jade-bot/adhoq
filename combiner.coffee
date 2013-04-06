Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'
fs = require 'fs'
coffee = require 'coffee-script'

module.exports = (dir) ->

  (req, res, next) ->
    
    builder = new Builder(dir)
    # TODO get these paths from component.json or make them configurable
    builder.addLookup('app');
    builder.addLookup('node_modules/briqs');

    builder.use (builder) ->
      builder.hook 'before scripts', (pkg, cb) ->
        for file in pkg.conf.cscripts or []
          if /\.coffee$/i.test file
            path = pkg.path file
            if fs.existsSync path
              js = coffee.compile fs.readFileSync path, 'utf8'
              jsfile = file.replace /coffee$/i, 'js'
              pkg.addFile 'scripts', jsfile, js
        cb()
    
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
