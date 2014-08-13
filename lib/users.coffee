Yo = require 'yo-api'
log = require './log'
config = require './config'

yo = new Yo config.yoApiKey

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

module.exports =
  add: add
  cleanUp: cleanUp
  notify: notify
  getUserNames: getUserNames

