eyaml = require './hiera-eyaml.coffee'
CreateKeysView = require './create-keys-view.coffee'

module.exports =
  config:
    eyamlPath:
      type: 'string'
      default: 'eyaml'
    messageTimeout:
      type: 'integer'
      default: 5

  activate: (state) ->
    atom.workspaceView.command 'hiera-eyaml:encrypt-selection', => @doSelections eyaml.encrypt
    atom.workspaceView.command 'hiera-eyaml:decrypt-selection', => @doSelections eyaml.decrypt
    atom.workspaceView.command 'hiera-eyaml:create-keys', => @createKeys()

  doSelections: (call) ->
    editor = atom.workspace.getActiveEditor()
    for sel in editor.getSelectedBufferRanges()
      break if sel.start.isEqual(sel.end)
      selectedText = editor.getTextInBufferRange(sel)
      stdout = (data) ->
        text = data.toString().replace /\n/, ''
        editor.setTextInBufferRange(sel, text)

      call selectedText, stdout

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
