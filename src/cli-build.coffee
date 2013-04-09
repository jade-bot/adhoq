combiner = require './combiner'
fs = require 'fs'
jade = require 'jade'
stylus = require 'stylus'
marked = require 'marked'

OUT_DIR = 'out'

module.exports = ->

  fs.mkdir OUT_DIR, (err) ->
    # ignore error, usually EEXIST
    
    combiner.fullBuild (js, css) ->
      saveFile "#{OUT_DIR}/build.js", js
      saveFile "#{OUT_DIR}/build.css", css
        
      treeBuild = (dir) ->        
        for file in fs.readdirSync dir
          path = "#{dir}/#{file}"
          stats = fs.statSync path
          if stats.isDirectory()
            treeBuild path
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
              dest = path.replace /app/, OUT_DIR
              saveFile dest, output
            
      treeBuild 'app'

saveFile = (path, data) ->
  if data
    fs.writeFileSync path, data
    console.info "  #{path} - #{Buffer.byteLength data} b"
  else
    console.error 'build error for %s', path
