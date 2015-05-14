
{Emitter} = require 'atom'
GrokExpression = require './grok-expression'

module.exports =
class GreppenGrokModel

  constructor: ->
    @emitter = new Emitter

  destroy: ->
    @emitter.dispose()

  doGrep: (pattern, config) ->
    console.log("Performing grep with the pattern #{pattern}", config)
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()

    shouldDelete = (line) ->
      if config.grep.keepMatches
        line.search(pattern) == -1
      else
        line.search(pattern) != -1

    rowsToDelete = ( r for r in [buffer.getLastRow()..0] when shouldDelete(buffer.lineForRow(r)) )

    buffer.transact ->
      for r in rowsToDelete
        console.debug("Deleting row #{r}")
        buffer.deleteRow r

    @emitter.emit 'status-change', success:true, message:"Removed #{rowsToDelete.length} rows"

  onStatusChange: (callback) ->
    @emitter.on 'status-change', callback
