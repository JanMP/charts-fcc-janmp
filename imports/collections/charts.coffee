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
Charts.attachSchema Charts.schema

Points = new Mongo.Collection "points"
Points.schema = new SimpleSchema
  symbol : symbolDef
  date :
    type : Date
  open :
    type : Number
    optional : true
    decimal : true
  high :
    type : Number
    optional : true
    decimal : true
  low :
    type : Number
    optional : true
    decimal : true
  close :
    type : Number
    optional : true
    decimal : true
Points.attachSchema Points.schema

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
        Charts.upsert chart, $set : chart, (err, chartId) ->
          ind = {}
          keys = ["date", "open", "high", "low", "close"]
          for key in keys
            ind[key] = api.column_names
              .map (e) ->
                e.toLowerCase()
              .indexOf key
          for row in api.data
            selector =
              symbol : chart.symbol
              date : new Date row[ind.date]
            point = Points.findOne(selector) or selector
            for key in keys[1..]
              point[key] = row[ind[key]]
            Points.upsert point, $set : point

exports.Charts = Charts
