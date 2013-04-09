combiner = require './combiner'
fs = require 'fs'
jade = require 'jade'
marked = require 'marked'
{minify} = require 'uglify-js'
cleancss = require 'clean-css'
#stylus = require 'stylus'

module.exports = (outdir = 'out') ->

  fs.mkdir outdir, (err) ->
    # ignore error, usually EEXIST
    
    combiner.fullBuild (js, css) ->
      saveFile "#{outdir}/build.css", cleancss.process css
      minified = minify js, fromString: true
      saveFile "#{outdir}/build.js", minified.code
      treeBuild 'app', outdir
  
treeBuild = (dir, out) ->        
  for file in fs.readdirSync dir
    path = "#{dir}/#{file}"
    stats = fs.statSync path
    if stats.isDirectory()
      treeBuild path, out
    else
      if /\.(jade|md)$/.test path
        data = fs.readFileSync path
        output = null
        if /\.jade$/.test path
          output = jade.compile(data, filename: path)()
          path = path.replace /jade$/, 'html'
        else if /\.md$/.test path
          output = marked data
          path = path.replace /md$/, 'html'
        dest = path.replace /app/, out
        saveFile dest, output

saveFile = (path, data) ->
  if data
    fs.writeFileSync path, data
    console.info "  #{path} - #{Buffer.byteLength data} b"
  else
    console.error 'build error for %s', path
