restify = require 'restify'
config = require './lib/config'
users = require './lib/users'
log = require './lib/log'
emailLogger = require './lib/email-logger'

runEngine = ->
  timer = setInterval ->
    userNames = users.getUserNames()
    users.notify name for name in userNames
    users.cleanUp()
  , config.breakInterval * 1e3 * 60

server = restify.createServer()
serverResponse =  (req, res, next) ->
  username = req.params.username
  res.send "Ok, got #{username}"
  users.add username
  emailLogger.send 'Add user', username
  next()

server.use restify.queryParser()
server.get '/api/v1/subscribe/', serverResponse
server.head '/api/v1/subscribe/', serverResponse

server.listen config.serverPort, -> log.info "#{server.name} listening at #{server.url}"
runEngine()
