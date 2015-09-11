Template.header.events
  'click #logout': () ->
    Meteor.logout ->
      delete Session.set 'venues', null
      map.removeAllMarkers()
  'click #login': () ->
    Meteor.loginWithGoogle(
      requestPermissions: ['email']
    , (err) ->
      throw err if err
    )