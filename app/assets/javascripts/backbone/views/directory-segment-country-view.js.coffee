class RollFindr.Views.DirectorySegmentCountryView extends Backbone.View
  model: null
  mapView: null

  initialize: (options)->
    _.bindAll(this, 'initializeMap')

    @initializeMap(options.mapModel)

  initializeMap: (model)->
    mapView = new RollFindr.Views.StaticMapView(model: model, el: @$el)

