path = require 'path'

dir = ->
  ## get project's directory

  projectDir = atom.config.get 'hiera-eyaml.defaultDir'

  return projectDir if projectDir

  project = atom.project
  projectPaths = project.getPaths()

  projectDir = project.getRepositories()?[0]?.getWorkingDirectory() ? projectPaths?[0]
  filePath = atom.workspace.getActiveTextEditor()?.getBuffer().getPath()

  projectDir = switch
    when projectDir then projectDir
    when filePath then path.dirname(filePath)
    else process.env['HOME']


  projectDir

module.exports.dir = dir
