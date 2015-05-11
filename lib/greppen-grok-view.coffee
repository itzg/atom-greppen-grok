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
      @header class: 'header', =>
        @span 'Use this to grep and grok your buffer into just what you want'

      @section class: 'input-block', =>
        @div class: 'input-block-item expands', =>
          @subview 'grepEditor', new TextEditorView(mini:true, placeholderText:'Grep pattern')

        @div class: 'input-block-item', =>
          @div class: 'btn-group', =>
            @button outlet:'grepButton', class:'btn', click:'handleGrep', 'Grep'
          @div class: 'btn-group', =>
            @button outlet:'toKeepButton', class:'btn', click:'handleToKeep', 'to keep'
            @button outlet:'toRemoveButton', class:'btn', click:'handleToRemove', 'to remove'

      @section class: 'input-block', =>
        @div 'Grok controls coming soon...'

  initialize: (model) ->
    console.log("Initializing", model)
    @model = model

  attached: ->
    @applyConfig()

  applyConfig: ->
    if (@config.grep.keepMatches)
      @toggleButtons(@toKeepButton, @toRemoveButton)
    else
      @toggleButtons(@toRemoveButton, @toKeepButton)

  toggleButtons: (selected, unselected...) ->
    selected.addClass 'selected'
    for e in unselected
      e.removeClass 'selected'

  handleGrep: ->
    console.log("handleGrep")
    @model.doGrep @grepEditor.getText(), @config

  handleToKeep: ->
    @config.grep.keepMatches = true
    @applyConfig()

  handleToRemove: ->
    @config.grep.keepMatches = false
    @applyConfig()
