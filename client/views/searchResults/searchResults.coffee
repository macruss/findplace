Template.searchResults.helpers
  venues: ->
    Session.get 'venues'

Template.searchResults.events
  'click #export': ->
    venues = Session.get 'venues'
    
    if venues.length
      csv = Papa.unparse venues
      blob = new Blob([csv],{type:"text/plain"})
      saveAs(blob, 'venues.csv')

  'click .venue': (e, t) ->
    $row = t.$(e.target).parent('tr')

    if not $row.hasClass('selected')
      t.marker.setAnimation null if t.marker
      t.$('.selected').removeClass('selected')
      $row.addClass 'selected'
      t.marker = _.find map.markers, (m) =>
        m.title == @name

      t.marker.setAnimation(google.maps.Animation.BOUNCE)
