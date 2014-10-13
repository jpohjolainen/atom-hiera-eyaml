{$, BufferedProcess, EditorView, View} = require 'atom'
fs = require 'fs'
eyaml = require './hiera-eyaml'
StatusView = require './status-view.coffee'
utils = require './utils'

module.exports =
class CreateKeysView extends View
  prevFocus: null

  @content: ->
    @div class: 'hiera-eyaml overlay from-top', =>
      @subview 'miniEditor', new EditorView(mini: true)
      @div class: 'error', outlet: 'error'
      @div class: 'message', outlet: 'message'

  initialize: ->
    @miniEditor.hiddenInput.on 'focusout', => @detach()
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()
    @error.hide()

  attach: ->
    @prevFocus = $(':focus')
    @message.text("Give a path where keys directory is created.")
    atom.workspaceView.append(this)
    @setPathText(utils.dir())
    @miniEditor.focus()

  setPathText: (text) ->
    {editor} = @miniEditor
    editor.setText(text)
    pathLength = editor.getText().length

  detach: ->
    return unless @hasParent()
    @prevFocus?.focus()
    super

  confirm: ->
    if @validKeysPath()
      stdout = (data) =>
        new StatusView type: 'success', message: "#{data.toString()} to #{@getPath()}/keys"
      eyaml.createKeys @getPath(), stdout
      @miniEditor.hide()
      @detach

  getPath: ->
    @miniEditor.getText()

  validKeysPath: ->
    if not fs.existsSync(@getPath())
      @error.text("Path doesn't exist.")
      @error.show()
      setTimeout =>
        @error.hide()
      , atom.config.get('hiera-eyaml.messageTimeout') * 500

      false
    else if fs.existsSync(@getPath() + '/keys/private_key.pkcs7.pem') or
            fs.existsSync(@getPath() + '/keys/public_key.pkcs7.pem')
      @error.text("Keys already exists in '#{@getPath()}'.")
      @error.show()
      false
    else
      @error.hide()
      true
