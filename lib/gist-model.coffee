https = require 'https'

module.exports =
class Gist
  constructor: ->
      @isPublic = !atom.config.get('gist-it.newGistsDefaultToPrivate')
      @files = {}
      @description = ""

  post: (callback) ->
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
        debugger
        response = JSON.parse(body)
        callback(response)

    request.write(JSON.stringify(@toParams()))

    request.end()

  toParams: ->
    description: @description
    files: @files
    public: @isPublic
