require "/imports/collections/charts.coffee"

if Meteor.isClient
  require "/imports/list/list.coffee"
  require "/imports/chart/chart.coffee"

  Meteor.subscribe "charts.charts"
