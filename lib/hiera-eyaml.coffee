{BufferedProcess} = require 'atom'

eyamlCmd = ({args, options, stdout, stderr, exit, data}={}) ->
  command = atom.config.get 'hiera-eyaml.eyamlPath'
  options ?= {}
  options.cwd ?= atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
  options.stdio ?= ['pipe', null, null]

  stdout ?= (data) -> console.log data.toString()
  stderr ?= (data) -> console.error data.toString()

  bp = new BufferedProcess
    command: command
    args: args
    options: options
    stdout: stdout
    stderr: stderr
    exit: exit

  bp.process.stdin.write(data)
  bp.process.stdin.end()

eyamlEncrypt = (text, stdout, stderr) ->
  eyamlCmd
    args: ['encrypt', '-o', 'string', '--stdin']
    stdout: stdout
    stderr: stderr
    data: text

eyamlDecrypt = (text, stdout, stderr) ->
  eyamlCmd
    args: ['decrypt', '--stdin']
    stdout: stdout
    stderr: stderr
    data: text

module.exports.encrypt = eyamlEncrypt
module.exports.decrypt = eyamlDecrypt
