HieraEyamlMain = require '../lib/main'
{Range} = require 'atom'

describe "HieraEyamlMain", ->
  [workSpaceElement, editor, editorView, activationPromise] = []

  beforeEach ->
    workSpaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.packages.activatePackage("language-yaml")

    waitsForPromise ->
      atom.workspace.open('../test.yaml')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      activationPromise = atom.packages.activatePackage('hiera-eyaml')
      activationPromise.fail (reason) ->
        throw reason

  describe 'when hiera-eyaml:create-keys is triggered', ->
    it 'then attaches and detaches the view', ->
      expect(workSpaceElement.querySelector('.hiera-eyaml')).not.toExist()

      atom.commands.dispatch editorView, 'hiera-eyaml:create-keys'

      waitsForPromise ->
        activationPromise

      expect(workSpaceElement.querySelector('.hiera-eyaml')).toExist()

      atom.commands.dispatch workSpaceElement.querySelector('.hiera-eyaml'), 'core:cancel'

      expect(workSpaceElement.querySelector('.hiera-eyaml')).not.toExist()

      # console.log workSpaceElement.innerHTML

  describe 'when hiera-eyaml:encrypt is triggered', ->
    it 'then encrypts the selected text', ->

      spyOn(HieraEyamlMain, 'bufferSetText')

      range = new Range([6,9], [6,14])
      editor.setSelectedBufferRange(range)
      atom.commands.dispatch editorView, 'hiera-eyaml:encrypt-selection'

      # console.log HieraEyamlMain.bufferSetText
      waitsForPromise ->
        activationPromise

      waitsFor ->
        HieraEyamlMain.bufferSetText.callCount > 0

      runs ->
        expect(HieraEyamlMain.bufferSetText).toHaveBeenCalled()
        expect(HieraEyamlMain.bufferSetText.calls[0].args[1]).toMatch /^ENC\[PKCS7,.*\]$/


  describe 'when hiera-eyaml:decrypt is triggered', ->
    it 'then decrypts the selected text', ->
