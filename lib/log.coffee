Log = require 'simple-node-logger'

logFile = "#{__dirname}/../log"

log = Log.createSimpleFileLogger logFile

module.exports = log
