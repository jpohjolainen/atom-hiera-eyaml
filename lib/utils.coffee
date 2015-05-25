path = require 'path'

dir = ->
  ## get project's directory

  projectDir = atom.config.get 'hiera-eyaml.defaultDir'

  return projectDir if projectDir

  project = atom.project

  projectDir = project.getRepositories()?[0]?.getWorkingDirectory() ? project.getPath()
  filePath = atom.workspace.getActiveTextEditor()?.getBuffer().getPath()

  projectDir = switch
    when projectDir then projectDir
    when filePath then path.dirname(filePath)
    else process.env['HOME']


  projectDir

module.exports.dir = dir
