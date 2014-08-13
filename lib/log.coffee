Log = require 'simple-node-logger'
config = require './config'

if config.logTarget is 'file'
  logFile = "#{__dirname}/../log"
  log = Log.createSimpleFileLogger logFile
else
  log = Log.createSimpleLogger()

module.exports = log
