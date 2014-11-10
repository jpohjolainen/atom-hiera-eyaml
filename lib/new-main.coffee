{HieraEyaml} = require './new-hiera-eyaml'

module.exports =
  config:
    eyamlPath:
      type: 'string'
      default: 'eyaml'
    defaultDir:
      type: 'string'
      default: ''
    publicKeyPath:
      type: 'string'
      default: ''
    privateKeyPath:
      type: 'string'
      default: ''
    messageTimeout:
      type: 'integer'
      default: 5
    wrapEncoded:
      type: 'boolean'
      default: false
    wrapLength:
      type: 'integer'
      default: 60
    strictIndentation:
      type: 'boolean'
      default: true
      description: "Indent only one level deeper. If off, indent to same level as block literal."

  activate: (state) ->
    atom.workspaceView.command 'hiera-eyaml:encrypt-selection', -> HieraEyaml.encrypt()
    atom.workspaceView.command 'hiera-eyaml:decrypt-selection', -> HieraEyaml.decrypt()
    atom.workspaceView.command 'hiera-eyaml:create-keys', -> HieraEyaml.createKeys()
