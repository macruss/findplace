convertToKm = (radius) ->
  (radius / 1000).toFixed 1

Template.queriesHistory.helpers
  queries: ->
    Queries.find().map (query)->
      query.radius = "#{convertToKm query.radius}km"
      query.date = moment(query.date).format("MMM Do YY, hh:mm:ss")
      query

Template.queriesHistory.events
  'click .delete': (e) ->
    e.stopPropagation()
    Queries.remove @_id

  #repeat the stored query
  'click .query': (e, t) ->
    $row = $(e.currentTarget)

    map.setCenter new google.maps.LatLng(@lat, @lng)
    map.setZoom(@zoom)

    if not $row.hasClass('selected')
      $('.selected').removeClass('selected')
      $row.addClass 'selected'

      map.removeAllMarkers()
      map.getVenues(@query)
