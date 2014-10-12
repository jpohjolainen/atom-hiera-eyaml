eyaml = require './hiera-eyaml.coffee'
CreateKeysView = require './create-keys-view.coffee'

module.exports =
  configDefaults:
    eyamlPath: 'eyaml'
    messageTimeout: 5

  activate: (state) ->
    atom.workspaceView.command 'hiera-eyaml:encrypt-selection', => @encryptSelection()
    atom.workspaceView.command 'hiera-eyaml:decrypt-selection', => @decryptSelection()
    atom.workspaceView.command 'hiera-eyaml:create-keys', => @createKeys()

  getSelections: (call) ->
    editor = atom.workspace.getActiveEditor()
    for sel in editor.getSelectedBufferRanges()
      break if sel.start.isEqual(sel.end)
      selectedText = editor.getTextInBufferRange(sel)
      stdout = (data) ->
        text = data.toString().replace /\n/, ''
        editor.setTextInBufferRange(sel, text)

      call selectedText, stdout

  encryptSelection: ->
    @getSelections eyaml.encrypt

  decryptSelection: ->
    @getSelections eyaml.decrypt

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
