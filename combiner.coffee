Builder = require 'component-builder'

module.exports = (root) ->

  (req, res, next) ->
    
    console.log 'combiner!'
  
    next()