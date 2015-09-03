Queries = new Mongo.Collection 'queries'

Queries.allow
  insert: (userId, doc) -> !!userId
  update: (userId, doc) -> !!userId
  remove: (userId, doc) -> !!userId
