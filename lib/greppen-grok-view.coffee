{View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class GreppenGrokView extends View
  config:
    grep:
      keepMatches: true

  @content: ->
    @div tabIndex: -1, class: 'greppen-grok', =>
      @section class: 'input-block', =>
        @div class: 'input-block-item expands', =>
          @subview 'grepEditor', new TextEditorView(mini:true, placeholderText:'Grep pattern')

        @div class: 'input-block-item', =>
          @div class: 'btn-group', =>
            @button outlet:'grepButton', class:'btn', 'Grep'
          @div class: 'btn-group', =>
            @button outlet:'toKeepButton', class:'btn', click:'handleToKeep', 'to keep'
            @button outlet:'toRemoveButton', class:'btn', click:'handleToRemove', 'to remove'

      @section class: 'input-block', =>
        @div 'Grok controls coming soon...'

  initialize: (@model) ->
    console.log("Initializing", @model)
    @subscriptions = new CompositeDisposable
    @handleEvents()
    @applyConfig()

  destroy: ->
    @subscriptions?.dispose()

  didShow: ->
    atom.views.getView(atom.workspace).classList.add('greppen-grok-visible')

  didHide: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()
    workspaceElement.classList.remove('greppen-grok-visible')

  handleEvents: ->
    @subscriptions.add atom.commands.add @grepEditor.element,
      'core:confirm': => @handleGrep()

    @grepButton.on 'click', => @handleGrep()

    @on 'focus', => @grepEditor.focus()

    @subscriptions.add atom.commands.add @element,
      'core:close': => @panel?.hide()
      'core:cancel': => @panel?.hide()

  setPanel: (@panel) ->
    @subscriptions.add @panel.onDidChangeVisible (visible) =>
      if visible then @didShow() else @didHide()

  applyConfig: ->
    if (@config.grep.keepMatches)
      @toggleButtons(@toKeepButton, @toRemoveButton)
    else
      @toggleButtons(@toRemoveButton, @toKeepButton)

  focusEditor: ->
    selectedText = atom.workspace.getActiveTextEditor()?.getSelectedText?()
    if selectedText and selectedText.indexOf('\n') < 0
      @grepEditor.setText(selectedText)
    @grepEditor.focus()
    @grepEditor.getModel().selectAll()


  toggleButtons: (selected, unselected...) ->
    selected.addClass 'selected'
    for e in unselected
      e.removeClass 'selected'

  handleGrep: ->
    console.log("handleGrep")
    @model.doGrep @grepEditor.getText(), @config
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()

  handleToKeep: ->
    @config.grep.keepMatches = true
    @applyConfig()

  handleToRemove: ->
    @config.grep.keepMatches = false
    @applyConfig()
