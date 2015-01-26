_ = require 'underscore-plus'
eyaml = require './hiera-eyaml.coffee'
CreateKeysView = require './create-keys-view.coffee'
{Point, Range} = require 'atom'

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
    indentToColumn:
      type: 'boolean'
      default: false

  activate: ->
    atom.commands.add 'atom-text-editor',
      'hiera-eyaml:encrypt-selection': => @doCrypt 'encrypt'
      'hiera-eyaml:decrypt-selection': => @doCrypt 'decrypt'
      'hiera-eyaml:create-keys': => @createKeys()

  trim: (str) ->
    str.replace /\s*\n$/, ''

  wrap: (range, text, length) ->
    output = ''
    wrapped = []
    lines = 0
    indent = false
    text = text.replace /^\s*>\s+/, ''
    multiLine = text.split /[\n\r]/

    return if @type == 'decrypt'

    if multiLine.length == 1 and text.length >= length
      while text.length >= (lines * length)
        wrapped.push text.slice lines * length, lines * length + length
        lines++
    else
      wrapped = multiLine
      lines = wrapped.length

    startPoint = range.start.copy()
    endPoint = range.end.copy()

    if lines > 1
      output = '>\n'
      output += wrapped.join "\n"
      endPoint.row = startPoint.row + lines
      startPoint.row = startPoint.row + 1
      indent = true
    else
      output = text

    @editor.setTextInBufferRange(range, output)

    if indent
      indentLevel = @editor.indentationForBufferRow(range.start.row)
      tabWidth = @editor.getTabLength()

      if @indentToColumn
        indentLevelNew = startPoint.column / tabWidth
      else
        indentLevelNew = indentLevel + 1

      @indentRows(startPoint, endPoint, indentLevelNew)

  indentRows: (start, end, level=1) ->
    row = start.row
    while row <= end.row
      @editor.setIndentationForBufferRow row, level
      row++

  bufferSetText: (idx, text) ->
    @count--
    @crypts[idx] = text

    if @count <= 0
      sorted = _.values(@ranges).sort (a, b) ->
        a.start.compare(b.start)

      @editor.getBuffer().beginTransaction()

      for point in sorted.reverse()
        index = @startPoints[point.start.toString()]
        selection = @ranges[index]
        if @wrapEncoded
          @wrap selection, @crypts[index], @wrapLength
        else
          @editor.setTextInBufferRange selection, @crypts[index]

      @editor.getBuffer().commitTransaction()

  isQuotedString: (selectionRange) ->
    cursorScopeObject = @editor.scopeDescriptorForBufferPosition(selectionRange.start)
    cursorScope = cursorScopeObject.scopes

    scopes = _.find(cursorScope, (scope) ->
      scope in ['string.quoted.single.yaml', 'string.quoted.double.yaml']
    )

    scopes?

  hasQuotes: (string) ->
    (string[0] == "'" or string[0] == '"')

  getSelectedText: (selectionRange) ->
    selectedText = @editor.getTextInBufferRange(selectionRange)

    ## If we're wrapping output, check and remove quotes around it.
    if @wrapEncoded and @isQuotedString(selectionRange) and not @hasQuotes(selectedText)
      startPoint = new Point(selectionRange.start.row, selectionRange.start.column - 1)
      endPoint = new Point(selectionRange.end.row, selectionRange.end.column + 1)
      newSelectionRange = new Range(startPoint, endPoint)
      @ranges[@rangeIndex] = newSelectionRange
      @startPoints[newSelectionRange.start.toString()] = @rangeIndex

    selectedText

  getConfig: () ->
    @wrapEncoded = atom.config.get 'hiera-eyaml.wrapEncoded'
    @wrapLength = atom.config.get 'hiera-eyaml.wrapLength'
    @indentToColumn = atom.config.get 'hiera-eyaml.indentToColumn'
    @editor = atom.workspace.getActiveEditor()

  doCrypt: (type) ->
    @rangeIndex = 0
    @addQuotes = false
    @startPoints = {}
    @ranges = {}
    @crypts = {}

    @getConfig()

    rootScopes = @editor.getRootScopeDescriptor()?.getScopesArray()
    rootScopes ?= @editor.getRootScopeDescriptor()

    if not ("source.yaml" in rootScopes)
      console.log "Not a YAML file. Scope: " + rootScopes
      return

    selectedBufferRanges = @editor.getSelectedBufferRanges()
    ## Remove cursor locations which don't have anything selected
    @realSelections = _.reject selectedBufferRanges, (s) -> s.start.isEqual(s.end)

    @count = @realSelections.length ? 0

    @type == type

    if type == 'encrypt'
      funx = eyaml.encrypt
    else
      funx = eyaml.decrypt
      @addQuotes = true

    for selectionRange in @realSelections
      @ranges[@rangeIndex] = selectionRange
      @startPoints[selectionRange.start.toString()] = @rangeIndex
      selectedText = @getSelectedText(selectionRange)
      funx selectedText, @rangeIndex, (idx, text) =>
        output = @trim(text)
        @bufferSetText idx, output
      @rangeIndex++

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
