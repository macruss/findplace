getRoundRadius = (radius) ->
  (radius / 1000).toFixed 1

Template.queriesHistory.helpers
  queries: ->
    Queries.find().map (query)->
      query.radius = getRoundRadius(query.radius) + 'km'
      query.date = query.date.toLocaleString()
      query

Template.queriesHistory.events
  'click .delete': ->
    Queries.remove @_id