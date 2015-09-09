Template.header.events
  'click #logout': () ->
    Meteor.logout()
  'click #login': () ->
    Meteor.loginWithGoogle(
      requestPermissions: ['email']
    , (err) ->
      console.log err.reason if err
    )