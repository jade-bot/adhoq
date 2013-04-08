Builder = require 'component-builder'
fs = require 'fs'
coffee = require 'coffee-script'
debug = require('debug') 'adhoq:combiner'

cachedBuild = null

buildOnce = (cb) ->
  return cb cachedBuild  if cachedBuild

  debug 'new build'
  builder = new Builder('.')
  
  # TODO get these paths from component.json or make them configurable
  builder.addLookup('app');
  builder.addLookup('node_modules/briqs');

  # add a hook too look for .coffee files and compile them on-the-fly
  builder.use (builder) ->
    builder.hook 'before scripts', (pkg, done) ->
      for file in pkg.conf.scripts or []
        if /\.js$/i.test file
          path = pkg.path file
          cspath = path.replace /js$/i, 'coffee'
          if fs.existsSync cspath
            js = coffee.compile fs.readFileSync cspath, 'utf8'
            pkg.addFile 'scripts', file, js
      done()
  
  builder.build (err, obj) ->
    if err
      console.log 'build error', err
      return cb()

    sizes = {}
    sizes[k] = v.length  for k,v of obj
    debug "sizes", sizes

    cachedBuild = obj
    cb cachedBuild

exports.invalidate = ->
  cachedBuild = null

exports.build = (type) ->
  # type must be either "js" or "css"

  (req, res, next) ->
    buildOnce (obj) ->
      if obj
        if type is 'js'
          out = obj.require + obj.js
        else
          out = obj[type]
        mime = { js: 'application/javascript', css: 'text/css' }[type]
        res.setHeader 'Content-Type', mime
        res.setHeader 'Content-Length', Buffer.byteLength out
        res.end out
      else
        next()
