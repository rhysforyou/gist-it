fs = require 'fs'
# Enterprise hosts may be served on a protocol other than HTTPS
if atom.config.get('gist-it.gitHubEnterpriseHost') and atom.config.get('gist-it.useHttp')
    protocol = require 'http'
else
    protocol = require 'https'
path = require 'path'

module.exports =
class Gist
  constructor: ->
      @isPublic = !atom.config.get('gist-it.newGistsDefaultToPrivate')
      @files = {}
      @description = ""

      # GitHub Enterprise Support https://enterprise.github.com/help/articles/using-the-api
      if atom.config.get('gist-it.gitHubEnterpriseHost')
        @hostname = atom.config.get('gist-it.gitHubEnterpriseHost')
        @path = '/api/v3/gists'
      else
        @hostname = 'api.github.com'
        @path = '/gists'

  getSecretTokenPath: ->
    path.join(atom.getConfigDirPath(), "gist-it.token")

  getToken: ->
    if not @token?
      config = atom.config.get("gist-it.userToken")
      @token = if config? and config.toString().length > 0
                 config
               else if fs.existsSync(@getSecretTokenPath())
                 fs.readFileSync(@getSecretTokenPath())
    @token

  post: (callback) ->
    options =
      hostname: @hostname
      path: @path
      method: 'POST'
      headers:
        "User-Agent": "Atom"

    # Use the user's token if we have one
    if @getToken()?
      options.headers["Authorization"] = "token #{@getToken()}"

    request = protocol.request options, (res) ->
      res.setEncoding "utf8"
      body = ''
      res.on "data", (chunk) ->
        body += chunk
      res.on "end", ->
        response = JSON.parse(body)
        callback(response)

    request.write(JSON.stringify(@toParams()))

    request.end()

  toParams: ->
    description: @description
    files: @files
    public: @isPublic
