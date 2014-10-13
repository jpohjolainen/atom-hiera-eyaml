{$, BufferedProcess, EditorView, View} = require 'atom'
fs = require 'fs'
eyaml = require './hiera-eyaml'
StatusView = require './status-view.coffee'
utils = require './utils'

module.exports =
class CreateKeysView extends View
  previouslyFocusedElement: null
  mode: null

  @content: ->
    @div class: 'hiera-eyaml overlay from-top', =>
      @subview 'miniEditor', new EditorView(mini: true)
      @div class: 'error', outlet: 'error'
      @div class: 'message', outlet: 'message'

  initialize: ->
    @miniEditor.hiddenInput.on 'focusout', => @detach()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

  attach: ->
    @previouslyFocusedElement = $(':focus')
    @message.text("Give a path where keys directory is created.")
    atom.workspaceView.append(this)
    @setPathText(utils.dir())
    @miniEditor.focus()

  setPathText: (placeholderName) ->
    {editor} = @miniEditor
    editor.setText(placeholderName)
    pathLength = editor.getText().length

  detach: ->
    return unless @hasParent()
    @previouslyFocusedElement?.focus()
    super

  confirm: ->
    if @validPackagePath()
      stdout = (data) =>
        new StatusView type: 'info', message: "#{data.toString()} to #{@getPath()}/keys"
      eyaml.createKeys @getPath(), stdout
      @miniEditor.hide()
      @detach

  getPath: ->
    @miniEditor.getText()

  validPackagePath: ->
    if not fs.existsSync(@getPath())
      @error.text("Path doesn't exist")
      @error.show()
      false
    else if fs.existsSync(@getPath() + '/keys/private_key.pkcs7.pem') or
            fs.existsSync(@getPath() + '/keys/public_key.pkcs7.pem')
      @error.text("Keys already exists in '#{@getPath()}'")
      @error.show()
      false
    else
      @error.hide()
      true
