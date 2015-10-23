convertMeterToKm = (radius) ->
  (radius / 1000).toFixed 1

Template.queriesHistory.helpers
  queries: ->
    Queries.find().map (query)->
      query.radius = "#{convertMeterToKm query.radius}km"
      query.date = moment(query.date).format("MMM Do YY, hh:mm:ss")
      query
  currentQuery: -> Session.get 'currentQueryId' 
  searching: -> Session.get 'searching'

Template.queriesHistory.events
  #delete query
  'click .delete': (e) ->
    e.stopPropagation()
    Queries.remove @_id

  #repeat the stored query
  'click .query': ->
    currentQueryId = Session.get 'currentQueryId'

    map.move(@lat, @lng, @zoom)

    if @_id != currentQueryId
      map.update @query
      Session.set 'currentQueryId', @_id
