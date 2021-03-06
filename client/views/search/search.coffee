Template.search.rendered = () ->
  message = humane.create
    baseCls: 'humane-bigbox'
    timeout: 2000

  # ======== Map =============
  class Map extends google.maps.Map
    # convert coords to format [lat: number, lng: number]
    _toArray: (coords) ->
      coords.toUrlValue().split(',').map (n) -> +n
    _getCenter: () ->
      @_toArray @getCenter()

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
      @_toArray @getBounds().getNorthEast()

    # get north-east map corner [lat, lng]
    getNECorner: ->
      @_toArray @getBounds().getSouthWest()

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
      center = @_getCenter()
      radius = @getRadius(center[0], map.getNECorner()[0])
      zoom = @getZoom()

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
        Session.set 'searching', null

    move: (lat, lng, zoom) ->
      @setCenter new google.maps.LatLng(lat, lng)
      @setZoom(zoom)

    update: (query) ->
      @removeAllMarkers()
      @getVenues query
      Session.set 'searching', true


  mapCanvas = @find '#map'
  mapOptions = 
    center: new google.maps.LatLng 50.44985, 30.523151 # Kiev
    zoom: 15
    panControl: false
    overviewMapControl: false
    mapTypeId: google.maps.MapTypeId.ROADMAP

  window.map = new Map mapCanvas, mapOptions

Template.search.events
  'keyup #search': (e, t) ->
    if e.which == 13
      query = e.target.value

      map.update query
      currentQueryId = map.storeQuery(query) if Meteor.user()
      Session.set 'currentQueryId', currentQueryId