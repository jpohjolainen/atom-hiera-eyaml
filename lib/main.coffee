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
    console.log "activate hiera-eyaml."
    atom.commands.add 'atom-text-editor',
      'hiera-eyaml:encrypt-selection': => @doCrypt 'encrypt'
      'hiera-eyaml:decrypt-selection': => @doCrypt 'decrypt'
    atom.commands.add 'atom-workspace',
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
      tabLength = @editor.getTabLength()

      if @indentToColumn
        indentLevelNew = startPoint.column / tabLength
      else
        indentLevelNew = indentLevel + 1

      @indentRows startPoint, endPoint, indentLevelNew

  indentRows: (start, end, level=1) ->
    row = start.row
    while row <= end.row
      @editor.setIndentationForBufferRow row, level
      row++

  bufferSetText: (idx, text, isCrypted) ->
    @selectionCount--
    @returnBuffer[idx] = text

    ## Change selections only after all has been encrypted.
    if @selectionCount <= 0
      sorted = _.values(@ranges).sort (a, b) ->
        a.start.compare(b.start)

      cp = @editor.getBuffer().createCheckpoint()

      ## Apply changes in reverse to circumvent overlapping ranges.
      for point in sorted.reverse()
        index = @startPoints[point.start.toString()]
        selectionRange = @ranges[index]
        if isCrypted and @wrapEncoded
          @wrap selectionRange, @returnBuffer[index], @wrapLength
        else
          @editor.setTextInBufferRange selectionRange, @returnBuffer[index]

      @editor.getBuffer().groupChangesSinceCheckpoint(cp)

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
    @editor = atom.workspace.getActiveTextEditor()

  doCrypt: (type) ->
    @rangeIndex = 0
    @startPoints = {}
    @ranges = {}
    @returnBuffer = {}

    @getConfig()

    rootScopes = @editor.getRootScopeDescriptor()?.getScopesArray()
    rootScopes ?= @editor.getRootScopeDescriptor()

    if not ("source.yaml" in rootScopes)
      console.log "Not a YAML file. Scope: " + rootScopes
      return

    selectedBufferRanges = @editor.getSelectedBufferRanges()
    ## Remove cursor locations which don't have anything selected
    @realSelections = _.reject selectedBufferRanges, (s) -> s.start.isEqual(s.end)

    @selectionCount = @realSelections.length ? 0

    if type == 'encrypt'
      funx = eyaml.encrypt
    else
      funx = eyaml.decrypt

    for selectionRange in @realSelections
      @ranges[@rangeIndex] = selectionRange
      @startPoints[selectionRange.start.toString()] = @rangeIndex
      selectedText = @getSelectedText(selectionRange)
      funx selectedText, @rangeIndex, (idx, text, isCrypted) =>
        output = @trim(text)
        @bufferSetText idx, output, isCrypted
      @rangeIndex++

  createKeys: ->
    view = new CreateKeysView()
    view.attach()
