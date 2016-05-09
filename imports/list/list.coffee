require "./list.jade"

{ Chart, Charts } = require "/imports/collections/charts.coffee"
{ Class } = require "meteor/jagi:astronomy"

Template.list.viewmodel
  newChartName : ""
  saveNewChart : ->
    chart = new Chart
      symbol : @newChartName()[0..3].trim().toUpperCase()
    chart.download()
    @newChartName.reset()
  items : ->
    Charts.find()

Template.listItem.viewmodel
  mixin : "Chart"
  logQuery : -> @Chart().download()
