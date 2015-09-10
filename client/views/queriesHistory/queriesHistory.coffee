getRoundRadius = (radius) ->
  (radius / 1000).toFixed 1

Template.queriesHistory.helpers
  queries: ->
    Queries.find().map (query)->
      query.radius = "#{getRoundRadius query.radius}km"
      query.date = moment(query.date).format("MMM Do YY, hh:mm:ss")
      query

Template.queriesHistory.events
  'click .delete': (e) ->
    e.stopPropagation()
    Queries.remove @_id

  'click .query': (e, t) ->
    $row = t.$(e.target).parent('tr')

    if not $row.hasClass('selected')
      t.$('.selected').removeClass('selected')
      $row.addClass 'selected'
      google.maps.event.addListenerOnce map, 'zoom_changed', =>
        map.removeAllMarkers() if map.markers.length
        map.getVenues(@query)

    google.maps.event.addListenerOnce map, 'center_changed', =>
      map.setZoom(@zoom)

    map.panTo new google.maps.LatLng(@lat, @lng)

    # google.maps.event.clearInstanceListeners(map);
