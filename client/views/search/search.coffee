Template.search.rendered = () ->

  # ======== Map =============
  class Map extends google.maps.Map
    _getCenter: ->
      (value for own _, value of @getCenter())

    _getQueryParams: (query)->
      center = @_getCenter()

      ## search in a quadrangle area
      # ne: map.getNECorner().toString()
      # sw: map.getSWCorner().toString()
      
      ## alt search in a rounded area
      ll: center.toString()
      radius: @getRadius(center[0], @getNECorner()[0])
      intent:'browse'
      query: query
      limit: 50
      v: moment().format('YYYYMMDD') # version of data

    markers: []
    
    getRadius:  (center, lat) ->
      MPG = 111111 # meters per grad lat
      MPG * Math.abs(center - lat)

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
      prop.animation = google.maps.Animation.DROP
      @markers.push new google.maps.Marker(prop)

    removeAllMarkers: ->
      @markers.forEach (marker) ->
        marker.setMap(null)
      @markers.length = 0
      Session.set 'venues', null

    storeQuery: (query) ->
      center = map._getCenter()
      radius = map.getRadius(center[0], map.getNECorner()[0])

      Queries.insert
        query: query
        lat: center[0]
        lng: center[1]
        radius: radius
        date: new Date()

    getVenues: (query) ->
      Meteor.call "getVenues", @_getQueryParams(query), (err, venues) ->
        if err then throw err
        
        venues = venues.map (venue, i) ->
          #render each venue on the map
          setTimeout ->
            map.addMarker
              position: 
                lat: venue.location.lat
                lng: venue.location.lng
              title: venue.name
          , i * 100

          # and return object for serch result table
          name: venue.name
          lat: venue.location.lat
          lng: venue.location.lng
          address: venue.location.address
          city: venue.location.city

        Session.set 'venues', venues


  mapCanvas = @find '#map'
  mapOptions = 
    center: new google.maps.LatLng 50.44985, 30.523151 # Tokyo
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
    if e.which == 14
      query = e.target.value

      map.removeAllMarkers() if map.markers.length
      map.storeQuery query 
      map.getVenues query
