#= require distance
#= require backbone/views/map/create_location_view
#= require backbone/views/map/directions_dialog_view

class RollFindr.Views.MapView extends Backbone.View
  el: $('.wrapper')
  map: null
  directionsView: null
  markerView: null
  listView: null
  events: {
    'change [name="sort_order"]': 'sortOrderChanged'
    'click .refresh-button': 'clearSearchAndFetchViewport'
    'click .map-prev-page': 'navigatePrevPage'
    'click .map-next-page': 'navigateNextPage'
  }
  initialize: (options)->
    _.bindAll(this,
      'activeMarkerChanged',
      'clearSearchAndFetchViewport',
      'search',
      'setCenterFromModel',
      'setupEventListeners',
      'navigateNextPage',
      'navigatePrevPage',
      'onFiltersChanged',
      'offFiltersChanged',
      'initializeMarkerView',
      'initializeMap',
      'setCenterGeolocate',
      'fetchViewport',
      'geolocate',
      'activateMarker',
      'render')

    if @setupGoogleMap()
      @initializeMarkerView(options.editable)
      @listView = new RollFindr.Views.MapListView({
        el: @$('.map-list-view')
        model: @model
        markerIdFunction: @markerView.getMarkerId
        filteredCount: 0
      })

      @setupEventListeners()
      @initializeMap()
      @directionsView = new RollFindr.Views.DirectionsOverlayView({el: @el, model: @model, map: @map})
  
    @activateRandom = options.activateRandom || false

  activateMarker: (id)->
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})
  
  navigateNextPage: (e)->
    @model.set('offset', @model.get('offset') + 50)
    alert('next page')

  navigatePrevPage: (e)->
    @model.set('offset', @model.get('offset') - 50)
    alert('prev page')

  initializeMap: ->
    hasCenter = @model.get('lat')? && @model.get('lng')?
    shouldGeolocate = @model.get('geolocate') || !hasCenter

    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate =>
        @fetchViewport()
    else
      @setCenterFromModel =>
        @fetchViewport()

  initializeMarkerView: (editable)->
    shouldRender = @markerView?
    @markerView.destroy() if @markerView?

    @markerView = new RollFindr.Views.MapMarkerView({editable: editable, map: @map, model: @model})
    @markerView.render() if shouldRender

  setupGoogleMap: ->
    return false unless google?

    mapOptions = {
      mapTypeControl: false
      zoom: @model.get('zoom')
      minZoom: @model.get('minZoom')
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    mapCanvas = @$('.map-canvas')[0]

    @map = new google.maps.Map(mapCanvas, mapOptions)

    if @model.get('refresh')
      refreshButton = JST['templates/refresh_button']()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(refreshButton)[0])
      @createLocationView = new RollFindr.Views.MapCreateLocationView({map: @map})

    return true

  onFiltersChanged: ->
    filtersChanged = _.debounce(@fetchViewport, 500)
    @model.on('change:event_type', filtersChanged)
    @model.on('change:location_type', filtersChanged)
    @model.on('change:count', filtersChanged)
    @model.on('change:offset', filtersChanged)
    @model.on('change:flags', filtersChanged)
    @model.on('change:sort', filtersChanged)
  
  offFiltersChanged: ->
    @model.off('change:event_type')
    @model.off('change:location_type')
    @model.off('change:count')
    @model.off('change:offset')
    @model.off('change:flags')
    @model.off('change:sort')

  setupEventListeners: ->
    @listenTo(@model, 'sync reset', @render)
    @onFiltersChanged()

    RollFindr.GlobalEvents.on('geolocate', @geolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)
    RollFindr.GlobalEvents.on('editing', @initializeMarkerView)

  activeMarkerChanged: (e)->
    if null != e.id
      locationModel = @model.get('locations').findWhere({id: e.id})
      lat = locationModel.get('lat')
      lng = locationModel.get('lng')
      newCenter = new google.maps.LatLng(lat, lng)
      @map.panTo(newCenter)

  visibleLocations: ->
    @filteredLocations.filter(
      (loc) =>
        coords = loc.get('coordinates')
        position = new google.maps.LatLng(coords[0], coords[1])
        return this.map.getBounds().contains(position)
    )
  sortOrderChanged: (e)->
    selectedSort = $('option:selected', e.currentTarget)
    @model.get('locations').sortByField(selectedSort.val())

  render: ->
    #filteredCount = @model.get('locations').models.length - @filteredLocations.models.length
    @markerView.render()
    @listView.render(0)

  search: (e)->
    @model.set('query', e.query)
    @model.set('geoquery', e.geoquery)

    @fetchViewport()

  geolocate: ->
    @setCenterGeolocate =>
      @fetchViewport()

  setCenterGeolocate: (doneCallback)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @map.setCenter(initialLocation)
      doneCallback() if doneCallback?

    geolocateFailedCallback = =>
      losAngeles = new google.maps.LatLng(34.0522, -118.2437)
      #userModelLocation = new google.maps.LatLng(RollFindr.CurrentUser.get('lat'), RollFindr.CurrentUser.get('lng'))
      @map.setCenter(losAngeles)

      doneCallback() if doneCallback?

    if navigator? && navigator.geolocation?
      options = { enableHighAccuracy: true, maximumAge: 0, timeout: 5000 }
      navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback, options)
    else
      geolocateFailedCallback()


  setCenterFromModel: (callback)->
    defaultLat = @model.get('lat')
    defaultLng = @model.get('lng')
    defaultLocation = new google.maps.LatLng(defaultLat, defaultLng)
    google.maps.event.addListenerOnce(@map, 'idle', callback) if callback?
    @map.setCenter(defaultLocation)

  clearSearch: ->
    @model.set('query', null)
    @model.set('geoquery', null)

  clearSearchAndFetchViewport: ->
    @clearSearch()
    @fetchViewport()

  fetchViewport: -> 
    if (undefined == @map.getCenter() || undefined == @map.getBounds())
      google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
      return

    lat = @map.getCenter().lat()
    lng = @map.getCenter().lng()

    distance = @model.get('distance') 
    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast()) unless distance?

    @$('.refresh-button .fa').addClass('fa-spin')

    @fetchMap(_.extend({
      location_type: @model.get('location_type')
      event_type: @model.get('event_type')
      team: @model.get('team')
      lat: lat
      lng: lng
      offset: @model.get('offset')
      segment: @model.get('segment')
      distance: distance
      count: @model.get('count')
      sort: @model.get('sort')
      query: @model.get('query')
      geoquery: @model.get('geoquery')
    }, @model.get('flags')))

  fetchMap: (args)->
    @offFiltersChanged()
    @model.fetch({
      data: args
      success: =>
        if @activateRandom
          @activateRandom = false

          setTimeout =>
            sz = @model.get('locations').size()
            randomIndex = Math.floor(Math.random() * 100) % sz
            randomMarker = @model.get('locations').at(randomIndex)
            @activateMarker(randomMarker.get('id'))
          , 100
        else
          @setCenterFromModel()

        toastr.success("Found #{'location'.pluralize(@model.get('location_count'))} and #{'event'.pluralize(@model.get('event_count'))}", 'Map refreshed')
      complete: =>
        @onFiltersChanged()
        @$('.refresh-button .fa').removeClass('fa-spin')
      error: =>
        toastr.error('Failed to refresh map', 'Error')
    })
