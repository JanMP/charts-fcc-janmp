{ Mongo } = require "meteor/mongo"
request = require "/node_modules/request"

symbolDef =
  type : String
  min : 1
  max : 4

Charts = new Mongo.Collection "charts"
Charts.schema = new SimpleSchema
  symbol : symbolDef
  name :
    type : String
  dataset :
    type : Object
    blackbox : true

Charts.attachSchema Charts.schema
exports.Charts = Charts

if Meteor.isServer
  Meteor.publish "charts.charts", ->
    Charts.find()

exports.removeChart = new ValidatedMethod
  name : "charts.removeChart"
  validate :
    new SimpleSchema
      id :
        type : String
    .validator()
  run : ({ id }) ->
    Charts.remove id

exports.getData = new ValidatedMethod
  name : "charts.getData"
  validate :
    new SimpleSchema
      symbol : symbolDef
    .validator()
  run : ({ symbol }) ->
    if Meteor.isServer
      apiKey = Meteor.settings.apiKey
      chart = Charts.findOne(symbol : symbol) or symbol : symbol
      query = "https://www.quandl.com/api/v3/datasets\
      /WIKI/#{symbol}.json?api_key=#{apiKey}&rows=365"
      request query, Meteor.bindEnvironment (err, resp, body) ->
        json = JSON.parse body
        if json?.quandl_error?
          throw new Meteor.Error "charts.getData quandl_error",
            json.quandl_error.message
        unless json.dataset?
          throw new Meteor.Error "charts.getData no dataset",
          "there's no dataset in the response"
        api = json.dataset
        chart.name = api.name
        chart.dataset =
          keys : api.column_names
          rows : api.data
        Charts.upsert chart, $set : chart
