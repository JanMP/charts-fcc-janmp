{ Class } = require "meteor/jagi:astronomy"
{ ViewModel } = require "meteor/manuel:viewmodel"

exports.astroView = (options) ->
  ClassObj = Class.create options
  if Meteor.isClient
    fields = (keys for keys of options.fields)
    shareObject =
      "#{options.name}" :
        "#{options.name}" : {}
        autorun : fields.map (field) ->
          -> this[options.name]()[field] = this[field]()
        onCreated : ->
          this[options.name] ClassObj.findOne @_id()
    ViewModel.mixin shareObject
  ClassObj
