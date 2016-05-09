{ Mongo } = require "meteor/mongo"
{ Class } = require "meteor/jagi:astronomy"
#{ createClassPlus }  = require "/imports/createClassPlus.js"

createClassPlus = (options) ->
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
    ViewModel.share shareObject
  ClassObj

Charts = new Mongo.Collection "charts"
Chart = createClassPlus
  name : "Chart"
  collection : Charts
  fields :
    symbol : String
    name : String

exports.Chart = Chart
exports.Charts = Charts
