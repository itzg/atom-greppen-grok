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

    @panel = atom.workspace.addBottomPanel(item: new GreppenGrokView(@model), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'greppen-grok:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @panel.destroy?()

  toggle: ->
    console.log 'AtomGreppenGrok was toggled!'

    if @panel.isVisible()
      @panel.hide()
    else
      @panel.show()
