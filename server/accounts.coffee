Accounts.onCreateUser (options, user) ->
  if options.profile
    _.extend options.profile, user.services.google
    user.profile = options.profile
  user
