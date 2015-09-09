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
        lat: venue.location.lat
        lng: venue.location.lng
        address: venue.location.address
        city: venue.location.city
    catch err
      throw err