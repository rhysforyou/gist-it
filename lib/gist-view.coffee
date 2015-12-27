{TextEditorView, View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

Gist = require './gist-model'
shell = require 'shell'

module.exports =
class GistView extends View
  @content: ->
    @div tabIndex: -1, class: "gist overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span outlet: "title"
          @div class: "btn-toolbar pull-right", outlet: 'toolbar', =>
            @div class: "btn-group", =>
              @button outlet: "privateButton", class: "btn", "Secret"
              @button outlet: "publicButton", class: "btn", "Public"
        @div class: "panel-body padded", =>
          @div outlet: 'gistForm', class: 'gist-form', =>
            @subview 'descriptionEditor', new TextEditorView(mini: true, placeholder: 'Gist Description')
            @div class: 'block pull-right', =>
              @button outlet: 'cancelButton', class: 'btn inline-block-tight', "Cancel"
              @button outlet: 'gistButton', class: 'btn btn-primary inline-block-tight', "Gist It"
            @div class: 'clearfix'
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'
          @div outlet: 'urlDisplay', =>
            @span "All Done! the Gist's URL has been copied to your clipboard."

  initialize: (serializeState) ->
    @gist = null
    @subscriptions = new CompositeDisposable

    @handleEvents()

    atom.commands.add 'atom-text-editor',
      'gist-it:gist-current-file': => @gistCurrentFile(),
      "gist-it:gist-selection": => @gistSelection(),
      "gist-it:gist-open-buffers": => @gistOpenBuffers()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @subscriptions?.dispose()
    atom.views.getView(atom.workspace).focus()
    @detach()

  handleEvents: ->
    @gistButton.on 'click', => @gistIt()
    @cancelButton.on 'click', => @destroy()
    @publicButton.on 'click', => @makePublic()
    @privateButton.on 'click', => @makePrivate()

    @subscriptions.add atom.commands.add @descriptionEditor.element,
      'core:confirm': => @gistIt()
      'core:cancel': => @destroy()

    @subscriptions.add atom.commands.add @element,
      'core:close': => @destroy
      'core:cancel': => @destroy

    @on 'focus', =>
      console.log("foo")
      @descriptionEditor.focus()

  gistCurrentFile: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    fileContent = activeEditor.getText()

    if !!(fileContent.trim())
      @gist = new Gist()

      @gist.files[activeEditor.getTitle()] =
        content: fileContent

      @title.text "Gist Current File"
      @presentSelf()

    else
      atom.notifications.addError('Gist could not be created: The current file is empty.')

  gistSelection: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    selectedText = activeEditor.getSelectedText()

    if !!(selectedText.trim())
      @gist = new Gist()

      @gist.files[activeEditor.getTitle()] =
        content: selectedText

      @title.text "Gist Selection"
      @presentSelf()
    else
      atom.notifications.addError('Gist could not be created: The current selection is empty.')

  gistOpenBuffers: ->
    skippedEmptyBuffers = false
    skippedAllBuffers = true
    @gist = new Gist()

    for editor in atom.workspace.getTextEditors()
      editorText = editor.getText()
      if !!(editorText.trim())
        @gist.files[editor.getTitle()] = content: editorText
        skippedAllBuffers = false
      else
        skippedEmptyBuffers = true

    if !skippedAllBuffers
      @title.text "Gist Open Buffers"
      @presentSelf()
    else
      atom.notifications.addError('Gist could not be created: No open buffers with content.')
      return

    if skippedEmptyBuffers
      atom.notifications.addWarning('Some empty buffers will not be added to the Gist.')

  presentSelf: ->
    @showGistForm()
    atom.workspace.addTopPanel(item: this)

    @descriptionEditor.focus()

  gistIt: ->
    @showProgressIndicator()

    @gist.description = @descriptionEditor.getText()

    @gist.post (response) =>
      atom.clipboard.write response.html_url

      if atom.config.get('gist-it.openAfterCreate')
        shell.openExternal(response.html_url)

      @showUrlDisplay()
      setTimeout (=>
        @destroy()
      ), 1000


  makePublic: ->
    @publicButton.addClass('selected')
    @privateButton.removeClass('selected')
    @gist.isPublic = true

  makePrivate: ->
    @privateButton.addClass('selected')
    @publicButton.removeClass('selected')
    @gist.isPublic = false

  showGistForm: ->
    if @gist.isPublic then @makePublic() else @makePrivate()
    @descriptionEditor.setText @gist.description

    @toolbar.show()
    @gistForm.show()
    @urlDisplay.hide()
    @progressIndicator.hide()

  showProgressIndicator: ->
    @toolbar.hide()
    @gistForm.hide()
    @urlDisplay.hide()
    @progressIndicator.show()

  showUrlDisplay: ->
    @toolbar.hide()
    @gistForm.hide()
    @urlDisplay.show()
    @progressIndicator.hide()
