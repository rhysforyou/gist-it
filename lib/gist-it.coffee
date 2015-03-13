GistView = require './gist-view'

module.exports =
  gistView: null

  activate: (state) ->
    @gistView = new GistView(state.gistViewState)

  deactivate: ->
    @gistView.destroy()

  serialize: ->
    gistViewState: @gistView.serialize()

  config:
    userToken:
      title: 'OAuth token'
      description: 'Enter an OAuth token to have Gists posted to your GitHub account. This token must include the gist scope.'
      type: 'string'
      default: ''
    newGistsDefaultToPrivate:
      title: 'New Gists default to private'
      description: 'Make Gists private by default.'
      type: 'boolean'
      default: false
    gitHubEnterpriseHost:
      title: 'GitHub Enterprise Host'
      description: 'If you want to publish Gists to a GitHub Enterprise instance, enter the hostname here.'
      type: 'string'
      default: ''
    useHttp:
      title: 'Use HTTP'
      description: 'Enable if your GitHub Enterprise instance is only available via HTTP, not HTTPS.'
      type: 'boolean'
      default: false
