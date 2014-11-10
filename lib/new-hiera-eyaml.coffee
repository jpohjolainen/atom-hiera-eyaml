_ = require 'underscore-plus'

class HieraEyaml

  constructor: () ->
    console.log 'c'

  getSelections: () ->
    @editor = atom.workspace.getActiveEditor()
    @selections ||= []

    userSelectedBufferRanges = @editor.getSelectedBufferRanges()
    userSelections = _.reject selectedBufferRanges, (range) -> range.start.isEqual(range.end)

    for selection in userSelections
      selectedText = @editor.getTextInBufferRange(selection)
      selections.push { text: selectedText, range: selection }

    selections

  encrypt: () ->
    console.log getSelections

    # encrypt selections

  decrypt: () ->
    console.log 'd'
    # decrypt

  createKeys: () ->
    console.log 'cK'
    # createKeys

module.export.HieraEyaml = HieraEyaml
