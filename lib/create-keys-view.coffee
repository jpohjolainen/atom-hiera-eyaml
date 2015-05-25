{BufferedProcess, Disposable, CompositeDisposable} = require 'atom'
{$, View, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'
eyaml = require './hiera-eyaml'
utils = require './utils'

module.exports =
class CreateKeysView extends View

  @content: ->
    @div tabIndex: -1, class: 'hiera-eyaml', =>
      @header class: 'header', =>
        @span outlet: 'descriptionLabel', class: 'header-item description',
          'Give a path where the keys directory will created.'
      @section class: 'input-block keys-directory-container', =>
        @div class: 'input-block-item editor-container', =>
          @subview 'miniEditor', new TextEditorView(mini: true)
        @div class: 'input-block-item buttons', =>
          @button outlet: 'confirmButton', class: 'btn btn-confirm', 'Confirm'
          @button outlet: 'cancelButton', class: 'btn btn-cancel', 'Cancel'


  initialize: ->
    @disposables = new CompositeDisposable
    @editor = atom.workspace.getActiveTextEditor()

  attach: ->
    @panel = atom.workspace.addBottomPanel(item: this)
    @disposables.add atom.commands.add @element,
      'core:confirm': => @confirm()
    @disposables.add atom.commands.add @element,
      'core:cancel': => @detach()
      'core:close': => @detach()
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null
    @confirmButton.on 'click', => @confirm()
    @cancelButton.on 'click', => @detach()
    @setPathText(utils.dir())
    @miniEditor.focus()

  setPathText: (text) ->
    @miniEditor.setText(text)

  detach: ->
    @disposables?.dispose()
    atom.views.getView(atom.workspace).focus()

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
