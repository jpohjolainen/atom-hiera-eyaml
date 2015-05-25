{BufferedProcess, Disposable, CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'
eyaml = require './hiera-eyaml'
utils = require './utils'

module.exports =
class CreateKeysView extends View
  prevFocus: null

  @content: ->
    @div class: 'hiera-eyaml panel-top', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  initialize: ->
    @disposables = new CompositeDisposable

  attach: ->
    @prevFocus = $(':focus')
    @message.text("Give a path where keys directory is created.")
    @panel = atom.workspace.addTopPanel(item: this)
    @disposables.add atom.commands.add @element,
      'core:confirm': => @confirm()
    @disposables.add atom.commands.add @element,
      'core:cancel': => @detach()
      'core:close': => @detach()
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null
    @setPathText(utils.dir())
    @miniEditor.focus()

  setPathText: (text) ->
    @miniEditor.setText(text)

  detach: ->
    @disposables?.dispose()
    @prevFocus?.focus()

  confirm: ->
    if @validKeysPath()
      stdout = (data) =>
              atom.notifications.addSuccess("#{data.toString()} to '#{@getPath()}'!")
      eyaml.createKeys @getPath(), stdout
      @detach()

  getPath: ->
    @miniEditor.getText()

  validKeysPath: ->
    if not fs.existsSync(@getPath())
      atom.notifications.addError "Path doesn't exists!"
      false
    else if fs.existsSync(@getPath() + '/keys/private_key.pkcs7.pem') or
            fs.existsSync(@getPath() + '/keys/public_key.pkcs7.pem')
      atom.notifications.addError("Keys already exists in '#{@getPath()}'.")
      false
    else
      true
