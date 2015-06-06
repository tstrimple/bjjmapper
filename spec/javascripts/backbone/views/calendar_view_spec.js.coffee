#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/location
#= require backbone/views/location-calendar-view
#= require backbone/views/create-event-view

describe 'Views.CalendarView', ->
  model = new RollFindr.Models.Location({id: '123'})
  view = null

  beforeEach ->
    view = new RollFindr.Views.LocationCalendarView({el: $('body'), model: model})

  describe 'fullcalendar', ->
    it 'fetches the events for the location', ->

  describe 'subviews', ->
    it 'has a create event dialog view', ->
      view.createEventView.should.be.instanceof(RollFindr.Views.CreateEventView)

