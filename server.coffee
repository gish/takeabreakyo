restify = require 'restify'
config = require './lib/config'
users = require './lib/users'
log = require './lib/log'

runEngine = ->
  timer = setInterval ->
    userNames = users.getUserNames()
    log.info "Notify users"
    users.notify name for name in userNames
    log.info "Clean up users"
    users.cleanUp()
  , config.breakInterval * 1e3 * 60

server = restify.createServer()
respond =  (req, res, next) ->
  username = req.params.username
  res.send "Ok, got #{username}"
  users.add username
  next()

server.get '/api/v1/subscribe/:username', respond
server.head '/api/v1/subscribe/:username', respond

server.listen 8080, -> log.info "#{server.name} listening at #{server.url}"
runEngine()

