path = require 'path'

dir = ->
  found = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
  filename = atom.workspace.getActiveEditor().getBuffer().getPath()
  ## if the file doesn't belong to this project, use it's directory instead.
  if not found or not filename.match found
    found = path.dirname(filename)
  found

module.exports.dir = dir
