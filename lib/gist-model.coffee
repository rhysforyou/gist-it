module.exports =
class Gist
  constructor: ->
      @isPublic = !atom.config.get('gist-it.newGistsDefaultToPrivate')
      @files = {}
      @description = ""
