require "./list.jade"
{ Charts, getData, removeChart } = require "/imports/collections/charts.coffee"

Template.list.viewmodel
  newChartName : ""
  items : ->
    Charts.find()
  saveNewChart : ->
    getData.call
      symbol : @newChartName()[0..3].trim().toUpperCase()
    @newChartName.reset()

Template.listItem.viewmodel
  removeChart : ->
    removeChart.call id : @_id()
