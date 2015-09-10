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
      res.data.response.venues.map (venue) ->
        name: venue.name
        city: venue.location.city
        address: venue.location.address
        lat: venue.location.lat
        lng: venue.location.lng
    catch err
      throw err