require "./list.jade"

{ Chart, Charts } = require "/imports/chartData/chartData.coffee"

Template.list.viewmodel
  newChartName : ""
  saveNewChart : ->
    chart = new Chart
      symbol : @newChartName()[0..3].trim().toUpperCase()
      name : @newChartName()
    chart.save()
    @newChartName.reset()
    console.log "list.viewmodel", this
  items : ->
    Charts.find()

Template.listItem.viewmodel
  share : "Chart"
  test : -> console.log "test"
