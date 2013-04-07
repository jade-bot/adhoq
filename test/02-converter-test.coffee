converter = require '../converter'

describe 'converter', ->
  it 'should be a function', ->
    converter.should.be.a 'function'

  describe 'request', ->
    fn = converter "#{__dirname}/fixtures"

    it 'should act as middleware', ->
      fn.should.be.a 'function'
      
    it 'should convert a Jade file', (done) ->
      setHeader = sinon.spy()
      html = '<head><title>Hello</title></head><body><p>Dolly!</p></body>'
      fn { method: 'GET', url: '/page1.html' },
        setHeader: setHeader
        end: (data) ->
          assert setHeader.calledWith('Content-Type', 'text/html')
          assert setHeader.calledWith('Content-Length', 59)
          data.should.equal html
          done()
      
    it 'should convert a Markdown file', (done) ->
      setHeader = sinon.spy()
      html = '<p>Hello <em>world</em> !</p>\n'
      fn { method: 'GET', url: '/page2.html' },
        setHeader: setHeader
        end: (data) ->
          assert setHeader.calledWith('Content-Type', 'text/html')
          assert setHeader.calledWith('Content-Length', 30)
          data.should.equal html
          done()
      
    it 'should convert a CoffeeScript file', (done) ->
      setHeader = sinon.spy()
      js = '(function() {\n  console.log(123);\n\n}).call(this);\n'
      fn { method: 'GET', url: '/script1.js' },
        setHeader: setHeader
        end: (data) ->
          assert setHeader.calledWith('Content-Type', 'text/js')
          assert setHeader.calledWith('Content-Length', 50)
          data.should.equal js
          done()
      
    it 'should convert a Stylus file', (done) ->
      setHeader = sinon.spy()
      css = 'body {\n  margin: 20px;\n}\n'
      fn { method: 'GET', url: '/style1.css' },
        setHeader: setHeader
        end: (data) ->
          assert setHeader.calledWith('Content-Type', 'text/css')
          assert setHeader.calledWith('Content-Length', 25)
          data.should.equal css
          done()
