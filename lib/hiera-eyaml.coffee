{BufferedProcess} = require 'atom'
StatusView = require './status-view.coffee'
utils = require './utils'

eyamlCmd = ({args, options, stdout, stderr, exit, data}={}) ->
  command = atom.config.get 'hiera-eyaml.eyamlPath' ? 'eyaml'
  options ?= {}
  options.cwd ?= utils.dir()

  if data
    options.stdio ?= ['pipe', null, null]

  stdout ?= (data) -> console.log data?.toString()

  stderr ?= (data) ->
    errorText = data.toString()
    if errorText.match /No such file/
      errorText += ' in ' + options.cwd
    new StatusView type: 'error', message: errorText

  bp = new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

  bp.process.stdin.on 'error', (error) =>
    return if error.code == 'EPIPE'
    console.error error.message

  bp.process.on 'error', (error) =>
    if error.code == 'ENOENT'
      msg = "Error executing '#{error.path}', check settings!"
    else
      msg = error.message
    new StatusView type: 'error', message: msg

  if data
    bp.process.stdin?.write?(data)
    bp.process.stdin?.end?()

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
