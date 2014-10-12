eyaml = require './hiera-eyaml.coffee'
StatusView = require './status-view.coffee'

module.exports =
  configDefaults:
    eyamlPath: 'eyaml'
    messageTimeout: 3

  activate: (state) ->
    atom.workspaceView.command 'hiera-eyaml:encrypt-selection', => @encryptSelection()
    atom.workspaceView.command 'hiera-eyaml:decrypt-selection', => @decryptSelection()


  getSelections: (call) ->
    editor = atom.workspace.getActiveEditor()
    for sel in editor.getSelectedBufferRanges()
      break if sel.start.isEqual(sel.end)
      selectedText = editor.getTextInBufferRange(sel)
      stdout = (data) ->
        text = data.toString().replace /\n/, ''
        editor.setTextInBufferRange(sel, text)
      stderr = (data) ->
        console.error data.toString()
        new StatusView type: 'error', message: data.toString()

      call selectedText, stdout, stderr

   encryptSelection: ->
    @getSelections eyaml.encrypt

  decryptSelection: ->
    @getSelections eyaml.decrypt
