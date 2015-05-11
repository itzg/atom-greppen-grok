
module.exports =
class GreppenGrokModel

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

    for r in rowsToDelete
      console.log("Deleting row #{r}")
      buffer.deleteRow r
