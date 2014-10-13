path = require 'path'

dir = ->
  ## get project's directory
  directory = atom.project.getRepo()?.getWorkingDirectory() ? atom.project.getPath()
  filename = atom.workspace.getActiveEditor().getBuffer().getPath()
  ## if the file doesn't belong to this project, use it's directory instead.
  if not directory or not filename.match directory
    directory = path.dirname(filename)
  directory

module.exports.dir = dir
