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

  constructor: ->
    @disposables = new CompositeDisposable
    super

  initialize: ->
    @disposables.add atom.commands.add 'atom-text-editor.editor.mini',
      'core:confirm': => @confirm()
    @disposables.add atom.commands.add 'atom-text-editor.editor.mini',
      'core:cancel': => @detach()
      'core:close': => @detach()

  destroy: ->
    @disposables?.dispose()

  attach: ->
    @prevFocus = $(':focus')
    @message.text("Give a path where keys directory is created.")
    @panel = atom.workspace.addTopPanel(item: this)
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
