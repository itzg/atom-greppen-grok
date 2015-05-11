GreppenGrokView = require './greppen-grok-view'
GreppenGrokModel = require './greppen-grok-model'
{CompositeDisposable} = require 'atom'

module.exports = GreppenGrok =
  model: null
  panel: null
  subscriptions: null

  activate: (state) ->
    console.log("Activating", state)

    @model = new GreppenGrokModel

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'greppen-grok:show', =>
      @createViews()
      @panel.show()
      @view.focusEditor()

  deactivate: ->
    @subscriptions.dispose()
    @panel.destroy?()

  createViews: ->
    return if @view?

    @view = new GreppenGrokView(@model)
    @panel = atom.workspace.addBottomPanel(item: @view, visible: false, className: 'tool-panel panel-bottom')

    @view.setPanel(@panel)
