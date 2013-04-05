jade = require 'jade'
stylus = require 'stylus'
marked = require 'marked'
{parse} = require 'url'
path = require 'path'
fs = require 'fs'
debug = require('debug') 'adhoq:convert'

# Look for requetsts which can be satsified by translating known formats.
# Currently implemented for .jade / .md -> .html and .styl -> .css

module.exports = (root) ->
  
  (req, res, next) ->
    return next() unless req.method in ['GET', 'HEAD']
    
    dest = path.join root, parse(req.url).pathname
    dest += 'index.html'  if dest.slice(-1) is '/'
    
    # FIXME ugly code
    
    # convert (static) Jade to HTML if possible
    if dest.match /\.html/i
      src = dest.replace /html$/, 'jade'
      fs.readFile src, 'utf8', (err, data) ->
        if not err
          debug 'jade', dest
          html = jade.compile(data, filename: src)()
          res.setHeader 'Content-Type', 'text/html'
          res.setHeader 'Content-Length', Buffer.byteLength html
          res.end html
        else
          # convert Markdown to HTML if possible
          src = dest.replace /html$/, 'md'
          fs.readFile src, 'utf8', (err, data) ->
            return next()  if err
            debug 'markdown', dest
            html = marked(data)
            res.setHeader 'Content-Type', 'text/html'
            res.setHeader 'Content-Length', Buffer.byteLength html
            res.end html
        
    # convert Stylus to CSS if possible
    else if dest.match /\.css/i
      src = dest.replace /css$/, 'styl'
      fs.readFile src, 'utf8', (err, data) ->
        return next()  if err
        stylus.render data, { filename: src }, (err, css) ->
          return next()  if err
          debug 'css', dest
          res.setHeader 'Content-Type', 'text/css'
          res.setHeader 'Content-Length', Buffer.byteLength css
          res.end css
          
    else
      next()