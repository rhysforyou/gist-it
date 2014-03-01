{EditorView, View} = require 'atom'
Clipboard = require 'clipboard'
https = require 'https'

module.exports =
class GistView extends View
  @content: ->
    @div class: "gist overlay from-top padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span "Gist Current File"
          @div class: "btn-toolbar pull-right", outlet: 'toolbar', =>
            @div class: "btn-group", =>
              @button outlet: "privateButton", class: "btn", "Private"
              @button outlet: "publicButton", class: "btn", "Public"
        @div class: "panel-body padded", =>
          @div outlet: 'signupForm', =>
            @subview 'descriptionEditor', new EditorView(mini:true, placeholderText: 'Description')
            @div class: 'pull-right', =>
              @button outlet: 'gistButton', class: 'btn btn-primary', "Gist It"
          @div outlet: 'progressIndicator', =>
            @span class: 'loading loading-spinner-medium'
          @div outlet: 'urlDisplay', =>
            @span "All Done! the Gist's URL has been copied to your clipboard."

  initialize: (serializeState) ->
    @handleEvents()
    atom.workspaceView.command "gist:gist-current-file", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  handleEvents: ->
    @gistButton.on 'click', => @gistIt()
    @publicButton.on 'click', => @makePublic()
    @privateButton.on 'click', => @makePrivate()
    @descriptionEditor.on 'core:confirm', => @gistIt()
    @descriptionEditor.on 'core:cancel', => @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      @showGistForm()

      atom.workspaceView.append(this)

      if atom.config.get('gist-it.newGistsDefaultToPrivate')
        @makePrivate()
      else
        @makePublic()

      @descriptionEditor.setText ""
      @descriptionEditor.focus()

  gistIt: ->
    @showProgressIndicator()

    parameters =
      description: @descriptionEditor.getText()
      public: @public
      files: {}

    activeEditor = atom.workspaceView.getActivePaneItem()

    parameters.files[activeEditor.getTitle()] =
      content: activeEditor.getText()

    @postGist parameters, (response) =>
      Clipboard.writeText response.html_url
      @showUrlDisplay()
      setTimeout (=>
        @detach()
      ), 1000


  makePublic: ->
    @publicButton.addClass('selected')
    @privateButton.removeClass('selected')
    @public = true

  makePrivate: ->
    @privateButton.addClass('selected')
    @publicButton.removeClass('selected')
    @public = false

  showGistForm: ->
    @toolbar.show()
    @signupForm.show()
    @urlDisplay.hide()
    @progressIndicator.hide()

  showProgressIndicator: ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.hide()
    @progressIndicator.show()

  showUrlDisplay: ->
    @toolbar.hide()
    @signupForm.hide()
    @urlDisplay.show()
    @progressIndicator.hide()

  postGist: (parameters, callback) ->
    options =
      hostname: 'api.github.com'
      path: '/gists'
      method: 'POST'
      headers:
        "User-Agent": "Atom"

    # Use the user's token if we have one
    if (atom.config.get("gist-it.userToken"))
      options.headers["Authorization"] = "token #{atom.config.get('gist-it.userToken')}"

    request = https.request options, (res) ->
      res.setEncoding "utf8"
      body = ''
      res.on "data", (chunk) ->
        body += chunk
      res.on "end", ->
        response = JSON.parse(body)
        callback(response)

    request.write(JSON.stringify(parameters))

    request.end()
