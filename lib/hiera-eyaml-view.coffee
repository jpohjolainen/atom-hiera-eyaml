{View} = require 'atom'

module.exports =
class HieraEyamlView extends View
  @content: ->
    @div class: 'hiera-eyaml overlay from-top', =>
      @div "The HieraEyaml package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "hiera-eyaml:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "HieraEyamlView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
