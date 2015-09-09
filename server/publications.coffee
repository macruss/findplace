Meteor.publish 'queries', ->
  Queries.find
    userId: @userId