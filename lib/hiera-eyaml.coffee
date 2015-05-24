{BufferedProcess} = require 'atom'
utils = require './utils'

eyamlCmd = ({args, options, stdout, stderr, exit, data}={}) ->
  command = atom.config.get 'hiera-eyaml.eyamlPath' ? 'eyaml'
  options ?= {}
  options.cwd ?= utils.dir()

  publicKeyPath = atom.config.get 'hiera-eyaml.publicKeyPath'
  privateKeyPath = atom.config.get 'hiera-eyaml.privateKeyPath'

  args = args.concat ['--pkcs7-public-key', publicKeyPath] if publicKeyPath
  args = args.concat ['--pkcs7-private-key', privateKeyPath] if privateKeyPath


  if data
    options.stdio ?= ['pipe', null, null]

  stdout ?= (data) -> console.log data?.toString()

  stderr ?= (data) ->
    publicKeyPath = atom.config.get 'hiera-eyaml.publicKeyPath'
    privateKeyPath = atom.config.get 'hiera-eyaml.privateKeyPath'
    errorText = data.toString()
    if errorText.match /No such file/
      if privateKeyPath
        errorText = "No such private key - #{privateKeyPath}"
      else if publicKeyPath
        errorText = "No such public key - #{publicKeyPath}"
      else
        errorText += ' in ' + options.cwd
    atom.notifications.addError(errorText)


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
    atom.notifications.addError(msg)

  if data
    bp.process.stdin?.write(data)
    bp.process.stdin?.end()

eyamlEncrypt = (text, index, callback) ->
  stdout = (data) ->
    callback index, data, true

  eyamlCmd
    args: ['encrypt', '-q', '-o', 'string', '--stdin']
    stdout: stdout
    data: text

eyamlDecrypt = (text, index, callback) ->
  stdout = (data) ->
    callback index, data, false

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
