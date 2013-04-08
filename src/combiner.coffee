Builder = require 'component-builder'
fs = require 'fs'
coffee = require 'coffee-script'
{EventEmitter} = require 'events'
crypto = require 'crypto'
debug = require('debug') 'adhoq:combiner'

cache = new EventEmitter

exports.invalidate = ->
  cache.data = null

exports.build = (type) ->
  # type must be either "js" or "css"

  (req, res, next) ->
    # Fairly convoluted logic: to avoid redundant builds when multiple requests
    # come in, we tag the build as "in progress" (by setting cache.data to {})
    # and postpone all replies until the builder fires off a cache "done" event.

    cache.once 'done', (data) ->
      return next()  unless data

      {text,etag,mime} = data[type]
      res.setHeader 'Content-Type', mime

      # use etags to avoid sending (and re-rendering) unmodified build results
      debug 'etag %s', type, etag
      if req.headers?['if-none-match'] is etag
        res.statusCode = 304
        res.end()
      else
        res.setHeader 'ETag', etag
        res.setHeader 'Content-Length', Buffer.byteLength text
        res.end text

    # handle the three different cache states: done, in progress, and fresh
    if cache.data
      if cache.data[type]
        cache.emit 'done', cache.data
      # else empty object, i.e. the build is in progress
    else
      buildAll (js, css) ->
        if js and css
          cache.data =
            js: { text: js,  etag: hash(js), mime: 'application/javascript' }
            css: { text: css, etag: hash(css), mime: 'text/css' }
        else
          cache.data = null
        cache.emit 'done', cache.data

hash = (data) ->
  md5 = crypto.createHash 'md5'
  md5.update data
  JSON.stringify md5.digest 'hex'

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

    cb obj.require + obj.js, obj.css
