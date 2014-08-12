Yo = require 'yo-api'
restify = require 'restify'
config = require './config'

yo = new Yo config.yoApiKey

Users = ->
  subscribeTimeByUser = {}
  add = (name) ->
    subscribeTimeByUser[name] = (new Date()).getTime()
    console.log "Added user #{name}"

  remove = (name) ->
    delete subscribeTimeByUser[name]
    console.log "Removed user #{name}"

  notify = (name) ->
    console.log "Notifying #{name}"
    yo.yo name, (err, res, body) ->
      console.log "Yo result for #{name}: #{body}"

  getUserNames = ->
    name for name, time of subscribeTimeByUser

  cleanUp = ->
    toRemove = []
    now = (new Date()).getTime()
    offset = 1e3 * 60 * config.sessionTime
    for name, time of subscribeTimeByUser
      console.log "Remove #{name} #{time} #{now} (#{now-time})"
      if time + offset <= now
        console.log "add to remove #{name}"
        toRemove.push name
    [remove name for name in toRemove]

  add: add
  cleanUp: cleanUp
  notify: notify
  getUserNames: getUserNames


users = Users()

runEngine = ->
  console.log "Starting server"
  cleanTimer = setInterval ->
    console.log "Cleaning up users"
    users.cleanUp()
  , config.sessionTime + 1e3*60

  notifyTimer = setInterval ->
    userNames = users.getUserNames()
    console.log "Notifying users", userNames
    users.notify name for name in userNames
  , 5*1e3

server = restify.createServer()
respond =  (req, res, next) ->
  username = req.params.username
  res.send "Ok, got #{username}"
  console.log "New subscriber: #{username}"
  users.add username
  next()

server.get '/api/v1/subscribe/:username', respond
server.head '/api/v1/subscribe/:username', respond

server.listen 8080, -> console.log "#{server.name} listening at #{server.url}"
runEngine()
