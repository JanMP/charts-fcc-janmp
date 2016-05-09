{ Mongo } = require "meteor/mongo"
{ Class } = require "meteor/jagi:astronomy"
{ astroView }  = require "/imports/astroView.coffee"
request = require "/node_modules/request"

Charts = new Mongo.Collection "charts"
Chart = astroView
  name : "Chart"
  collection : Charts
  fields :
    symbol : String
    name : String
  methods :
    download : ->
      getData.call symbol : @symbol

Points = new Mongo.Collection "points"
Point = astroView
  name : "Point"
  collection : Points
  fields :
    chartId : String
    date : String
    open :
      type : Number
      optional : true
    high :
      type : Number
      optional : true
    low :
      type : Number
      optional : true
    close :
      type : Number
      optional : true

exports.getData = getData = new ValidatedMethod
  name : "charts.getData"
  validate : null
  run : ({ symbol }) ->
    if Meteor.isServer
      apiKey = Meteor.settings.apiKey
      chart = Chart.findOne(symbol : symbol) or new Chart(symbol : symbol)
      query = "https://www.quandl.com/api/v3/datasets\
      /WIKI/#{symbol}.json?api_key=#{apiKey}"
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
        chart.save  (err, chartId) ->
          ind = (str) -> api.column_names.indexOf str
          indices =
            date : ind "Date"
            open : ind "Open"
            high : ind "High"
            low : ind "Low"
            close : ind "Close"
          console.log indices
          for row in api.data
            date = row[indices.date]
            point = Point.findOne
              chartId : chartId
              date : date
            point ?= new Point
              chartId : chart._id
              date : date
            for key, value of indices
              point[key] = row[value]
            point.save()


exports.Chart = Chart
exports.Charts = Charts
