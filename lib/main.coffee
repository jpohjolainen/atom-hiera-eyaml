_ = require 'underscore-plus'
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

  trim: (str) ->
    str.replace /\s*\n/, ''

  bufferSetText: (index, crypted) ->
    @count--
    @crypts[index] = crypted

    if @count <= 0
      sorted = _.values(@ranges).sort (a, b) ->
        a.start.compare(b.start)

      for point in sorted.reverse()
        for i in _.keys @ranges
          selection = @ranges[i]
          if selection.start is point.start
            @editor.setTextInBufferRange(selection, @crypts[i])

  doSelections: (func) ->
    index = 0
    @ranges = {}
    @crypts = {}

    @editor = atom.workspace.getActiveEditor()
    selectedBufferRanges = @editor.getSelectedBufferRanges()
    ## Remove cursor locations which don't have anything selected
    @realSelections = _.reject selectedBufferRanges, (s) -> s.start.isEqual(s.end)
    @count = @realSelections.length ? 0

    for selectionRange in @realSelections
      index++
      selectedText = @editor.getTextInBufferRange(selectionRange)
      @ranges[index] = selectionRange

      func selectedText, index, (idx, cryptedText) =>
        @bufferSetText idx, @trim(cryptedText)

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
