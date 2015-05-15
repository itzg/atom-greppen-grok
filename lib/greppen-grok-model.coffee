
{Emitter} = require 'atom'
GrokExpression = require './grok-expression'

module.exports =
class GreppenGrokModel

  constructor: ->
    @emitter = new Emitter

  destroy: ->
    @emitter.dispose()

  doGrep: (pattern, config) ->
    console.debug("Performing grep with the pattern #{pattern}", config)
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

    @emitter.emit 'status-change', success:true, message:"Removed #{rowsToDelete.length} rows."

  doGrok: (pattern, config) ->
    console.debug("Performing grok with the pattern #{pattern}", config)
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    grokExp = new GrokExpression(pattern)

    transform = switch
      when not grokExp.hasPlaceholders()
        (result) -> result.trimmedAs
      else
        (result) ->
          parts = for key, value of result.values
            "#{key}=#{value}"
          parts.join(',')

    grokCount = 0
    rowsToDelete = []

    buffer.transact ->

      for r in [buffer.getLastRow()..0]
        result = grokExp.exec(buffer.lineForRow(r))
        if (!result.matched)
          console.debug("Not matched")
          rowsToDelete.push(r) if (config.grok.keepOnlyMatchingLines)
        else
          console.debug("Grok'ed")
          ++grokCount
          range = buffer.rangeForRow(r, false)
          buffer.setTextInRange range, transform(result)
          console.debug("Line set")

      console.debug("About to delete", rowsToDelete)
      for r in rowsToDelete
        buffer.deleteRow r

    @emitter.emit 'status-change',
      success:true
      message:"Grok'ed #{grokCount} lines" +
        if (rowsToDelete.length > 0)
          " and removed #{rowsToDelete.length}."
        else
          "."

  onStatusChange: (callback) ->
    @emitter.on 'status-change', callback
