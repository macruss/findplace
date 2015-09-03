Template.search.rendered = () ->

  # ======== Map =============
  class Map extends google.maps.Map
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


  mapCanvas = @find '#map'
  mapOptions = 
    center: new google.maps.LatLng 35.7116, 139.8014
    zoom: 12
    mapTypeId: google.maps.MapTypeId.ROADMAP

  window.map = new Map mapCanvas, mapOptions

Template.search.events
  'keyup #search': (e, t) ->
    if e.which == 13
      params =
        ## search in a quadrangle area
        ne: map.getNECorner().toString()
        sw: map.getSWCorner().toString()
        intent:'browse'
        
        ## alt search in a rounded area
        # ll: (value for own _, value of t.map.getCenter()).toString()
        # radius: 1000
        query: e.target.value
        v: '20150901'

      map.removeAllMarkers()

      Meteor.call "getVenues", params, (err, venues) ->
        if err then throw err

        venues.forEach (venue) ->
          map.addMarker
            position: 
              lat: venue.location.lat
              lng: venue.location.lng
            title: venue.name
