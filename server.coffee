Yo = require 'yo-api'
restify = require 'restify'
config = require './config'
Log = require 'simple-node-logger'


yo = new Yo config.yoApiKey
log = new Log.createSimpleLogger()

Users = ->
  subscribeTimeByUser = {}
  add = (name) ->
    subscribeTimeByUser[name] = (new Date()).getTime()
    log.info "Add user #{name}"

  remove = (name) ->
    log.info "Remove user #{name}"
    delete subscribeTimeByUser[name]

  notify = (name) ->
    log.info "Notify user #{name}"
    yo.yo name, (err, res, body) ->
      if res.statusCode is 400
        log.error "Yo error for #{name}: #{body}"
      else
        log.info "Yo success for #{name}"

  getUserNames = ->
    name for name, time of subscribeTimeByUser

  cleanUp = ->
    toRemove = []
    now = (new Date()).getTime()
    offset = 1e3 * 60 * config.sessionTime
    for name, time of subscribeTimeByUser
      if time + offset <= now
        toRemove.push name
    [remove name for name in toRemove]

  add: add
  cleanUp: cleanUp
  notify: notify
  getUserNames: getUserNames


users = Users()

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

