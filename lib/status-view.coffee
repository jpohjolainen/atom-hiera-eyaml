{$, View} = require 'atom-space-pen-views'

module.exports =
class StatusView extends View

  @content = (params) ->
    @div class: 'hiera-eyaml overlay from-bottom', =>
      @div class: "#{params.type} message", params.message

  initialize: ->
    @on 'core:cancel', => @detact()
    atom.workspaceView.append(this)
    setTimeout =>
      @detach()
    , atom.config.get('hiera-eyaml.messageTimeout') * 1000

  detach: ->
    super
