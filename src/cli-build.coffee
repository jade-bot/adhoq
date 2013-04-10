combiner = require './combiner'
fs = require 'fs'
jade = require 'jade'
stylus = require 'stylus'
marked = require 'marked'
{minify} = require 'uglify-js'
cleancss = require 'clean-css'
mkdirp = require 'mkdirp'
path = require 'path'

module.exports = (outdir = 'out') ->
  combiner.fullBuild (js, css) ->
    if js and css
      treeDel outdir  if fs.existsSync outdir
      
      cssMin = cleancss.process css
      saveFile "#{outdir}/build.css", cssMin
      
      jsMin = minify js, fromString: true
      saveFile "#{outdir}/build.js", jsMin.code
      
      treeBuild 'app', outdir
    else
      console.error 'build error'

treeDel = (dir) ->
  for name in fs.readdirSync dir
    src = "#{dir}/#{name}"
    if fs.statSync(src).isDirectory()
      treeDel src
    else
      fs.unlinkSync src
  fs.rmdirSync dir

# translate some file types, and copy the rest as is
# also updates the pendingStylus map of .styl files to build later
treeBuild = (dir, out) ->
  for name in fs.readdirSync dir
    src = "#{dir}/#{name}"
    if fs.statSync(src).isDirectory()
      treeBuild src, out
    else if /\.(jade|md)$/.test src
      data = fs.readFileSync src, 'utf8'
      if /\.jade$/.test src
        data = jade.compile(data, filename: src)()
        src = src.replace /jade$/, 'html'
      else if /\.md$/.test src
        data = marked data
        src = src.replace /md$/, 'html'
      dest = src.replace /app/, out
      saveFile dest, data
    else if /\.styl$/.test src
      data = fs.readFileSync src, 'utf8'
      src = src.replace /styl$/, 'css'
      dest = src.replace /app/, out
      stylus.render data, { filename: src }, (err, css) ->
        # nasty: runs async, relies on the app waiting for it to finish
        saveFile dest, css
    else unless /\.(js|json|coffee|styl)$/.test src
      data = fs.readFileSync src
      dest = src.replace /app/, out
      saveFile dest, data

saveFile = (file, data) ->
  len = if typeof data is 'string' then Buffer.byteLength data else data.length
  console.info "  #{file} - #{len} b"
  mkdirp.sync path.dirname file
  fs.writeFileSync file, data
