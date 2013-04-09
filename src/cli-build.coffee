combiner = require './combiner'
fs = require 'fs'
jade = require 'jade'
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
    else unless /\.(js|json|coffee|styl)$/.test src
      data = fs.readFileSync src
      dest = src.replace /app/, out
      saveFile dest, data, data.length

saveFile = (file, data, size) ->
  size ?= Buffer.byteLength data
  console.info "  #{file} - #{size} b"
  mkdirp.sync path.dirname file
  fs.writeFileSync file, data
