{View} = require 'space-pen'
{TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class GreppenGrokView extends View
  config:
    grep:
      keepMatches: true
    grok:
      keepOnlyMatchingLines: false

  @content: ->
    @div tabIndex: -1, class: 'greppen-grok', =>
      @header class:'header', =>
        @span outlet: 'statusLabel', =>
            @span class: 'status-icon icon'
            @span class: 'status-msg', 'Ready to grep and grok'

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
        @div class: 'input-block-item expands', =>
          @subview 'grokEditor', new TextEditorView(mini:true, placeholderText:'Grok pattern')

        @div class: 'input-block-item', =>
          @div class: 'btn-group', =>
            @button outlet:'grokButton', class:'btn', 'Grok'
          @div class: 'btn-group', =>
            @button outlet:'grokKeepButton', class:'btn', click: 'handleGrokToKeep', 'Keep only matching'

  initialize: (@model) ->
    console.log("Initializing", @model)
    @subscriptions = new CompositeDisposable
    @handleEvents()
    @applyConfig()

  destroy: ->
    @subscriptions?.dispose()

  handleShow: ->
    atom.views.getView(atom.workspace).classList.add('greppen-grok-visible')

  handleHide: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()
    workspaceElement.classList.remove('greppen-grok-visible')

  handleEvents: ->
    @subscriptions.add atom.commands.add @grepEditor.element,
      'core:confirm': => @handleGrep()

    @subscriptions.add atom.commands.add @grokEditor.element,
      'core:confirm': => @handleGrok()

    @grepButton.on 'click', => @handleGrep()
    @grokButton.on 'click', => @handleGrok()

    @on 'focus', => @grepEditor.focus()

    @subscriptions.add atom.commands.add @element,
      'core:close': => @panel?.hide()
      'core:cancel': => @panel?.hide()
      'greppen-grok:focus-next': @toggleFocus
      'greppen-grok:focus-previous': @toggleFocus

    @model.onStatusChange @handleStatusChange

  setPanel: (@panel) ->
    @subscriptions.add @panel.onDidChangeVisible (visible) =>
      if visible then @handleShow() else @handleHide()

  applyConfig: ->
    if (@config.grep.keepMatches)
      @toggleButtons(@toKeepButton, @toRemoveButton)
    else
      @toggleButtons(@toRemoveButton, @toKeepButton)
    @grokKeepButton.toggleClass('selected', @config.grok.keepOnlyMatchingLines)

  focusEditor: ->
    selectedText = atom.workspace.getActiveTextEditor()?.getSelectedText?()
    if selectedText and selectedText.indexOf('\n') < 0
      @grepEditor.setText(selectedText)
    @grepEditor.focus()
    @grepEditor.getModel().selectAll()

  toggleFocus: =>
    if @grepEditor.hasClass('is-focused')
      @grokEditor.focus()
    else
      @grepEditor.focus()

  toggleButtons: (selected, unselected...) ->
    selected.addClass 'selected'
    for e in unselected
      e.removeClass 'selected'

  handleStatusChange: ({success, message}) =>
    @statusLabel.find('.status-msg').text(message)

    icon = @statusLabel.find('.status-icon')
    icon.toggleClass('icon-info', false)
    icon.toggleClass('icon-check', success)
    icon.toggleClass('icon-alert', !success)

    @statusLabel.toggleClass('success', success)
    @statusLabel.toggleClass('failure', !success)

  focusOnWorkspace: ->
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()

  handleGrep: ->
    console.log("handleGrep")
    @model.doGrep @grepEditor.getText(), @config
    @focusOnWorkspace()

  handleGrok: ->
    console.log("handleGrok")
    @model.doGrok @grokEditor.getText(), @config
    @focusOnWorkspace()

  handleToKeep: ->
    @config.grep.keepMatches = true
    @applyConfig()

  handleToRemove: ->
    @config.grep.keepMatches = false
    @applyConfig()

  handleGrokToKeep: ->
    currently = @grokKeepButton.hasClass('selected')
    @config.grok.keepOnlyMatchingLines = !currently
    @applyConfig()
