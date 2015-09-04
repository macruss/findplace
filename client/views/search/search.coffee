Template.search.rendered = () ->

  # ======== Map =============
  class Map extends google.maps.Map
    _getRadius:  (center, lat) ->
      MPG = 111111 # meters per grad lat
      MPG * Math.abs(center - lat)

    _getCenter: ->
      (value for own _, value of @getCenter())

    _getQueryParams: (value)->
      center = @_getCenter()
      ## search in a quadrangle area
      # ne: map.getNECorner().toString()
      # sw: map.getSWCorner().toString()
      
      ## alt search in a rounded area
      ll: center.toString()
      radius: @_getRadius(center[0], @getNECorner()[0])
      intent:'browse'
      query: value
      limit: 50
      v: '20150901'

    markers: []

    # get south-west map corner [lat, lng]
    getSWCorner: ->
      bounds = @getBounds()
      [bounds.Ja.G, bounds.Ea.j]

    # get north-east map corner [lat, lng]
    getNECorner: ->
      bounds = @getBounds()
      [bounds.Ja.j, bounds.Ea.G]

    addMarker: (prop) ->
      prop.map = this
      @markers.push new google.maps.Marker(prop)

    removeAllMarkers: ->
      @markers.forEach (marker) ->
        marker.setMap(null)
      @markers.length = 0


    getVenues: (value) ->
      Meteor.call "getVenues", @_getQueryParams(value), (err, venues) ->
        if err then throw err
        
        venues = venues.map (venue) ->
          map.addMarker
            position: 
              lat: venue.location.lat
              lng: venue.location.lng
            title: venue.name

          name: venue.name
          lat: venue.location.lat
          lng: venue.location.lng
          address: venue.location.address
          city: venue.location.city

        Session.set 'venues', venues


  mapCanvas = @find '#map'
  mapOptions = 
    center: new google.maps.LatLng 35.7116, 139.8014 # Tokyo
    zoom: 12
    panControl: on
    zoomControl: on
    mapTypeControl: on
    scaleControl: on
    streetViewControl: on
    overviewMapControl: no
    mapTypeId: google.maps.MapTypeId.ROADMAP

  window.map = new Map mapCanvas, mapOptions

Template.search.events
  'keyup #search': (e, t) ->
    if e.which == 13
      center = map._getCenter()
      radius = map._getRadius(center[0], map.getNECorner()[0])

      map.removeAllMarkers()

      Queries.insert
        query: e.target.value
        lat: center[0]
        lng: center[1]
        radius: radius
        date: new Date()

      map.getVenues e.target.value


