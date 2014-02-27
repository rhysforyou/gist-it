GistView = require './gist-view'

module.exports =
  gistView: null

  activate: (state) ->
    atom.config.setDefaults('gist-it', token: '')
    @gistView = new GistView(state.gistViewState)

  deactivate: ->
    @gistView.destroy()

  serialize: ->
    gistViewState: @gistView.serialize()
