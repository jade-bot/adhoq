jade = require 'jade'
stylus = require 'stylus'
marked = require 'marked'
coffee = require 'coffee-script'
{parse} = require 'url'
path = require 'path'
fs = require 'fs'
debug = require('debug') 'adhoq:convert'

# Look for requetsts which can be satsified by translating known formats.
# Handles .jade / .md -> .html, .coffee -> .js, and .styl -> .css

module.exports = (root) ->
  
  (req, res, next) ->
    return next() unless req.method in ['GET', 'HEAD']
    
    dest = path.join root, parse(req.url).pathname
    dest += 'index.html'  if dest.slice(-1) is '/'
    src = null
    
    trySuffix = (from, to, match, nomatch) ->
      len = to.length
      if to is dest.slice -len
        src = dest.slice(0, -len) + from
        fs.readFile src, 'utf8', (err, data) ->
          if err then nomatch() else match data
      else
        nomatch()
    
    sendResult = (tag, mimetype, text) ->
      debug tag, dest
      res.setHeader 'Content-Type', mimetype
      res.setHeader 'Content-Length', Buffer.byteLength text
      res.end text
    
    trySuffix '.jade', '.html', (data) ->
      html = jade.compile(data, filename: src)()
      sendResult 'Jade', 'text/html', html
    , ->
      trySuffix '.md', '.html', (data) ->
        sendResult 'Markdown', 'text/html', marked data
      , ->
        trySuffix '.coffee', '.js', (data) ->
          sendResult 'CoffeeScript', 'text/js', coffee.compile data
        , ->
          trySuffix '.styl', '.css', (data) ->
            stylus.render data, { filename: src }, (err, css) ->
              if err then next() else
                sendResult 'Stylus', 'text/css', css
          , ->
            next()
