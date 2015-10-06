Template.searchResults.helpers
  venues: -> Session.get 'venues'
  currentMarker: -> Session.get 'currentMarker'

Template.searchResults.events
  'click #export': ->
    venues = Session.get 'venues'
    
    if venues.length
      csv = Papa.unparse venues
      blob = new Blob([csv],{type:"text/plain"})
      saveAs(blob, 'venues.csv')

  # select and animate venue on map
  'click .venue': (ev, tmpl) ->
    currentMarker = Session.get 'currentMarker'

    if @name != currentMarker
      tmpl.marker.setAnimation null if tmpl.marker
      
      tmpl.marker = _.find map.markers, (marker) =>
        marker.title == @name

      tmpl.marker.setAnimation google.maps.Animation.BOUNCE
      Session.set 'currentMarker', tmpl.marker.title
