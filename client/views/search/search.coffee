Template.search.rendered = () ->
  message = humane.create
    baseCls: 'humane-bigbox'
    timeout: 2000

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
      zoom = map.getZoom()

      Queries.insert
        userId: Meteor.userId()
        query: query
        lat: center[0]
        lng: center[1]
        radius: radius
        zoom: zoom
        date: new Date()

    getVenues: (query) ->
      Meteor.call "getVenues", @_getQueryParams(query), (err, venues) ->
        if err then throw err
        
        message.log 'Nothing found' if venues.length == 0
        #render each venue on the map
        venues.forEach (venue, i) ->
          setTimeout ->
            map.addMarker
              position: 
                lat: venue.lat
                lng: venue.lng
              title: venue.name
          , i * 20

        Session.set 'venues', venues


  mapCanvas = @find '#map'
  mapOptions = 
    center: new google.maps.LatLng 50.44985, 30.523151 # Tokyo
    zoom: 15
    panControl: false
    overviewMapControl: false
    mapTypeId: google.maps.MapTypeId.ROADMAP

  window.map = new Map mapCanvas, mapOptions

Template.search.events
  'keyup #search': (e, t) ->
    if e.which == 13
      query = e.target.value

      map.removeAllMarkers()
      map.getVenues query
      map.storeQuery query if Meteor.user()
