@Queries = new Mongo.Collection 'queries'

@Queries.allow
  insert: (userId, doc) -> on #!!userId
  update: (userId, doc) -> on #!!userId
  remove: (userId, doc) -> on #!!userId
