mandrill = require 'mandrill-api'
log = require './log'
config = require './config'
client = new mandrill.Mandrill config.mandrillApiKey

send = (type, message) ->
  recipientName = 'Erik Hedberg'
  recipientEmail = 'erik@hedberg.at'
  log.info "Will log to email: #{type}, #{message}"
  message =
    subject: "standupyo: #{type}"
    text: message
    to: [
      email: recipientEmail
      name: recipientName
      type: 'to'
    ]
    from_email: 'erik+yo@hedberg.at'
  client.messages.send
    message: message
    async: true
  , (result) ->
    result = result[0]
    status = result.status
    switch status
      when 'rejected'
        log.error "Mandrill reject error: #{result.reject_reason}"
      else
        log.info "Mandrill e-mail result: #{status}"
  , (error) ->
    log.error "Mandril e-mail error: #{e.name}, #{e.message}"

module.exports =
  send: send
