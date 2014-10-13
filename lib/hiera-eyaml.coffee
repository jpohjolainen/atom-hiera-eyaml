{BufferedProcess} = require 'atom'
StatusView = require './status-view.coffee'
utils = require './utils'

eyamlCmd = ({args, options, stdout, stderr, exit, data}={}) ->
  command = atom.config.get 'hiera-eyaml.eyamlPath'
  options ?= {}
  options.cwd ?= utils.dir()

  if data
    options.stdio ?= ['pipe', null, null]
  stdout ?= (data) -> console.log data.toString()
  stderr ?= (data) ->
    errorText = data.toString()
    if errorText.match /No such file/
      errorText += ' in ' + options.cwd
    console.error errorText
    new StatusView type: 'error', message: errorText

  bp = new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

  if data
    bp.process.stdin.write(data)
    bp.process.stdin.end()

eyamlEncrypt = (text, stdout) ->
  eyamlCmd
    args: ['encrypt', '-q', '-o', 'string', '--stdin']
    stdout: stdout
    data: text

eyamlDecrypt = (text, stdout) ->
  eyamlCmd
    args: ['decrypt', '-q', '--stdin']
    stdout: stdout
    data: text

eyamlCreateKeys = (path, stdout) ->
  eyamlCmd
    args: ['createkeys', '-q']
    stdout: stdout
    options: { cwd: path }

module.exports.encrypt = eyamlEncrypt
module.exports.decrypt = eyamlDecrypt
module.exports.createKeys = eyamlCreateKeys
