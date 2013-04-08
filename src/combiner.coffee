Builder = require 'component-builder'
debug = require('debug') 'adhoq:combiner'
fs = require 'fs'
coffee = require 'coffee-script'

module.exports = (type) ->
  # type must be either "js" or "css"

  (req, res, next) ->
    builder = new Builder('.')
    
    # TODO get these paths from component.json or make them configurable
    builder.addLookup('app');
    builder.addLookup('node_modules/briqs');

    # add a hook too look for .coffee files and compile them on-the-fly
    builder.use (builder) ->
      builder.hook 'before scripts', (pkg, cb) ->
        for file in pkg.conf.scripts or []
          if /\.js$/i.test file
            path = pkg.path file
            cspath = path.replace /js$/i, 'coffee'
            if fs.existsSync cspath
              js = coffee.compile fs.readFileSync cspath, 'utf8'
              pkg.addFile 'scripts', file, js
        cb()
    
    builder.build (err, obj) ->
      if err
        console.log 'build error', err
        return next()

      sizes = {}
      sizes[k] = v.length  for k,v of obj
      debug "sizes", sizes
      
      out = obj.require + obj[type]
      mime = { js: 'application/javascript', css: 'text/css' }[type]
      res.setHeader 'Content-Type', mime
      res.setHeader 'Content-Length', Buffer.byteLength out
      res.end out
