require "./chart.jade"
require "/node_modules/c3/c3.css"
c3 = require "/node_modules/c3/c3.js"
moment = require "/node_modules/moment/moment.js"
{ Charts } = require "/imports/collections/charts.coffee"
_ = require "/node_modules/lodash"

Template.chart.viewmodel
  key : "Close"
  keyOptions : ->
    charts = @charts().fetch().map (chart) -> chart.dataset.keys
    options = []
    if charts.length > 0
      options =
        _(charts[0])
          .filter (option) -> option isnt "Date"
          .value()
      for chart in charts
        options =
          _(options)
            .filter (option) -> option in chart
            .value()
    options


  c3Chart : null
  charts : -> Charts.find()
  xs : ->
    xs = {}
    for chart in @charts().fetch()
      xs[chart.symbol] = "#{chart.symbol}-x"
    xs
  oldCharts : null
  columns : ->
    columns = []
    for chart in @charts().fetch()
      xArr = ["#{chart.symbol}-x"]
      yArr = [chart.symbol]
      keyIndex = chart.dataset.keys.indexOf @key()
      dateIndex = chart.dataset.keys.indexOf "Date"
      for row in chart.dataset.rows
        xArr.push row[dateIndex]
        yArr.push row[keyIndex]
      columns.push xArr, yArr
    columns
  onRendered : ->
    $ "#dropdown"
      .dropdown()
  autorun : ->
    setOldCharts = =>
      @oldCharts @charts().fetch().map (chart) -> chart.symbol
    unless @c3Chart.value
      setOldCharts()
      @c3Chart c3.generate
        bindto : '#chart'
        data :
          xs : @xs()
          columns : @columns()
        transition :
          duration : 1000
        axis :
          x :
            type : "timeseries"
            localtime : false
            tick :
              count : 10
              format : (x) -> moment(x).format "Y-M-D"
    else
      removed =
        _(@oldCharts.value)
          .filter (chart) =>
            chart not in @charts().fetch().map (chart) -> chart.symbol
          .value()
      @c3Chart.value.load
        unload : removed
        xs : @xs()
        columns : @columns()
      setOldCharts()
