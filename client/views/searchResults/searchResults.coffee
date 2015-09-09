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