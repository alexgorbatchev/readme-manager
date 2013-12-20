fibrous = require 'fibrous'
colors = require 'colors'
path = require 'path'
fs = require 'fs'
slugify = require 'slugify'

trim = (str) -> str.replace /^\s+|\s+$/g, ''

class Readme
  read: fibrous (@readmePath) ->
    content = fs.sync.readFile @readmePath, 'utf8'
    {@data, @blocks} = @parse content

  parse: (content) ->
    blocks = []
    data = {}
    current = null

    for line in content.split /\n/g
      if line.charAt(0) is '#'
        blocks.push current = slugify line.replace(/^#+\s*/, '').toLowerCase()
        data[current] = ''

      data[current] += line + '\n'

    {data, blocks}

  set: (block, content) ->
    throw new Error "`#{block}` not found in #{@readmePath}".red unless @data[block]
    lines = @data[block].split /\n/g
    content = trim content
    @data[block] = lines[0] + '\n\n' + content + '\n\n'

  save: fibrous ->
    fs.sync.writeFile @readmePath, @toString()

  toString: ->
    result = ''

    for block in @blocks
      result += @data[block]

    trim result

module.exports = {Readme}