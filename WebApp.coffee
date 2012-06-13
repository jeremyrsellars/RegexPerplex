fs = require 'fs'
express = require 'express'
connect = require 'connect'

console.combine = (a, item, remaining...) ->
   a.push item if item?
   console.combine a, remaining if remaining? and remaining.length > 0
console.logInColor = (octalColor, message) ->
   if require('util').isArray(message)
      console.logArrayInColor octalColor, message
      return
   console.logStringInColor octalColor, message
console.logArrayInColor = (octalColor, message) ->
   a = ['\u001b[' + octalColor]
   a.push ' array: '
   console.combine a, message
   a.push '\u001b[0m'
   console.log a.join('')
console.logStringInColor = (octalColor, message) ->
   console.log '\u001b[' + octalColor, message, '\u001b[0m'
console.red = (message) ->
   console.logInColor '31m', message
console.green = (message) ->
   console.logInColor '32m', message
console.gold = (message) ->
   console.logInColor '33m', message

class WebApp

   run: ->
      process.title = 'Regex Fun Web App - initializing'
      @writeHeader()
      process.title += '.'
      @configureWeb()
      process.title += '.'
      @listen()
      process.title = 'Regex Fun Web App'

   writeHeader: ->
      console.log  '==================='
      console.gold '   Regex Fun App'
      console.log  '==================='

   configureWeb: ->
      console.log 'configuring web'
      @app = express.createServer()
      @app.use("/styles", express.static(__dirname + '/styles'));
      @app.use connect.basicAuth @tryAuthenticate
      @app.use express.bodyParser()
      @app.set 'view engine', 'jade'
      @app.set('view options', { layout: false })
      @addResources()

   tryAuthenticate: (username, token) ->
      return true

   addResources: ->
      resource = require 'express-resource'
      connect.logger('dev')
      @addAllResources()

   addAllResources: ->
      resources =
         'vowels':
            module: (require "./RegexTest.coffee").createResource require("./tests/vowels.json")
         'sheepish':
            module: (require "./RegexTest.coffee").createResource require("./tests/sheepish.json")
         'phrase':
            module: (require "./RegexTest.coffee").createResource require("./tests/phrase.json")
         'firstword':
            module: (require "./RegexTest.coffee").createResource require("./tests/firstword.json")
      
      @addResourceXList null, resources

   addResourceXList: (parent, resources) ->
      @addResourceX parent, name, moduleAndChildren for name, moduleAndChildren of resources

   addResourceX: (parent, name, moduleAndChildren) ->
      resource = @app.resource name, moduleAndChildren.module
      parent.add resource if (parent?)
      moduleAndChildren.module.init(@appContext, resource) if (moduleAndChildren.module.init?)
      @addResourceXList resource, moduleAndChildren.children if moduleAndChildren.children?

   listen: ->
      @app.listen 3001

new WebApp().run()
