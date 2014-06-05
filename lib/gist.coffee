GistView = require './gist-view'

module.exports =
  gistView: null

  activate: (state) ->
    @gistView = new GistView(state.gistViewState)

  deactivate: ->
    @gistView.destroy()

  serialize: ->
    gistViewState: @gistView.serialize()

  configDefaults:
    userToken: ""
    newGistsDefaultToPrivate: false
    gitHubEnterpriseHost: ""
    useHttp: false
