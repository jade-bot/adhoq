Builder = require 'component-builder'
fs = require 'fs'
coffee = require 'coffee-script'
{EventEmitter} = require 'events'
debug = require('debug') 'adhoq:combiner'

cache = new EventEmitter

exports.invalidate = ->
  cache.build = null

exports.build = (type) ->
  # type must be either "js" or "css"

  (req, res, next) ->

    # Fairly convoluted logic: to avoid redundant builds when multiple requests
    # come in, we tag the build as "in progress" (by setting cache.build to {})
    # and postpone all replies until the builder fires off a cache "done" event.

    cache.once 'done', ->
      if type is 'js'
        res.setHeader 'Content-Type', 'application/javascript'
        out = cache.build.require + cache.build.js
      else
        res.setHeader 'Content-Type', 'text/css'
        out = cache.build.css
      res.setHeader 'Content-Length', Buffer.byteLength out
      res.end out

    if cache.build
      if cache.build[type]
        cache.emit 'done'
      else
        # if empty object, then the build is in progress
    else
      cache.build = {}
      buildAll (obj) ->
        if obj
          cache.build = obj
          cache.emit 'done'
        else
          next()

buildAll = (cb) ->
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

    cb obj
