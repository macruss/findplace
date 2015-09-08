Meteor.methods
  getVenues: (params) ->
    check params.query, String
    check params.ll, String
    # check params.ne, String
    # check params.sw, String
    check params.v, String

    url = "https://api.foursquare.com/v2/venues/search"

    _.extend params, foursquareAccess

    try
      res = Meteor.http.get url, {params:params}
      res.data.response.venues
    catch err
      throw err