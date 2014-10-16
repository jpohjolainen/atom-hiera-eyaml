_ = require 'underscore-plus'
eyaml = require './hiera-eyaml.coffee'
CreateKeysView = require './create-keys-view.coffee'

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

  activate: (state) ->
    atom.workspaceView.command 'hiera-eyaml:encrypt-selection', => @doSelections eyaml.encrypt
    atom.workspaceView.command 'hiera-eyaml:decrypt-selection', => @doSelections eyaml.decrypt
    atom.workspaceView.command 'hiera-eyaml:create-keys', => @createKeys()

  trim: (str) ->
    str.replace /\s*\n/, ''

  wrap: (range, text, length=40) ->
    tabWidth = @editor.getTabLength()
    indentLevel = @editor.indentationForBufferRow(range.start.row)
    lines = text.length % length
    newIndent = (indentLevel+1) * tabWidth + 1

    if text.length > 90
      new_text = ">\n" + Array(newIndent).join ' '
      arr = []
      l=0
      while text.length >= (l * length)
        arr.push text.slice l*length, l*length+length
        l++
      new_text += arr.join "\n#{Array(newIndent).join ' '}"
      @editor.setTextInBufferRange(range, new_text)
    else
      @editor.setTextInBufferRange(range, text)

  bufferSetText: (index, crypted) ->
    @count--
    @crypts[index] = crypted

    if @count <= 0
      sorted = _.values(@ranges).sort (a, b) ->
        a.start.compare(b.start)

      for point in sorted.reverse()
        index = @startPoints[point.start.toString()]
        selection = @ranges[index]
        if @wrapEncoded
          @wrap selection, @crypts[index], atom.config.get 'hiera-eyaml.wrapLength'
        else
          @editor.setTextInBufferRange selection, @crypts[i]

  doSelections: (func) ->
    index = 0
    @ranges = {}
    @startPoints = {}
    @crypts = {}
    @isYaml = false

    @editor = atom.workspace.getActiveEditor()

    return if @editor.getRootScopeDescriptor()?[0] != 'source.yaml'

    selectedBufferRanges = @editor.getSelectedBufferRanges()

    @wrapEncoded = atom.config.get 'hiera-eyaml.wrapEncoded'

    ## Remove cursor locations which don't have anything selected
    @realSelections = _.reject selectedBufferRanges, (s) -> s.start.isEqual(s.end)
    @count = @realSelections.length ? 0

    for selectionRange in @realSelections
      index++
      selectedText = @editor.getTextInBufferRange(selectionRange)
      @ranges[index] = selectionRange
      @startPoints[selectionRange.start.toString()] = index

      func selectedText, index, (idx, cryptedText) =>
        @bufferSetText idx, @trim(cryptedText)

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
