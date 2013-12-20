{PathScanner} = require 'scandal'
fibrous = require 'fibrous'
colors = require 'colors'
path = require 'path'
fs = require 'fs'
slugify = require 'slugify'
{Readme} = require './readme'

blocks = {}
files = []

processReadme = fibrous (readmePath) ->
  readme = new Readme()
  readme.sync.read readmePath

  for block, content of blocks
    try
      readme.set block, content
    catch {message}
      console.log "  #{message}"

  readme.sync.save()
  console.log '  DONE'.green

processModule = fibrous (packagePath) ->
  dir = path.dirname packagePath

  try
    packageJson = JSON.parse fs.sync.readFile packagePath
  catch
    return

  try
    console.log packageJson.name.blue
    readmePath = "#{dir}/README.md"
    processReadme.sync readmePath
  catch e
    if e.code is 'ENOENT'
      console.error "No README.md with in #{dir}".red
    else
      console.error e.stack

loadBlocks = (done) ->
  scanner = new PathScanner "#{__dirname}/blocks"

  scanner.on 'path-found', (filepath) ->
    blocks[path.basename filepath, '.md'] = fs.readFileSync filepath, 'utf8'

  scanner.on 'finished-scanning', -> done()
  scanner.scan()

scanForPackages = (done) ->
  scanner = new PathScanner process.cwd(),
    excludeVcsIgnores: yes
    exclusions: ['node_modules', 'test']

  scanner.on 'path-found', (filepath) ->
    if /\/package\.json$/.test filepath
      files.push filepath

  scanner.on 'finished-scanning', -> done()
  scanner.scan()

fibrous.run ->
  loadBlocks.sync()
  scanForPackages.sync()

  processModule.sync file for file in files
