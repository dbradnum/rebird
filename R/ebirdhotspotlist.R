#' Hotspots in a region or nearby coordinates 
#'
#' Get the list of hotspots within a region, or within a radius of up to 50 kilometers, from a given set of coordinates.
#' 
#' @param regionCode The country, subnational1 or subnational2 code. If `regionCode` is provided then 
#' latitude and longitude are ignored.
#' @param lat Decimal latitude. value between -90.00 and 90.00, up to two
#'    decimal places of precision. 
#' @param lng Decimal longitude. value between -180.00 and 180.00, up to
#'    two decimal places of precision.
#' @param dist The search radius from the given set of coordinates, in kilometers (between 0 and 500, defaults to 25).
#' @param back Only fetch hotspots which have been visited up to 'back' days ago (defaults to `NULL`).
#' @param sleep Time (in seconds) before function sends API call (defaults to
#'    zero. Set to higher number if you are using this function in a loop with
#'    many API calls).
#' @param key ebird API key. You can obtain one from https://ebird.org/api/keygen.
#'    We strongly recommend storing it in your \code{.Renviron} file as an 
#'    environment variable called \code{EBIRD_KEY}.
#' @param ... Curl options passed on to \code{\link[httr]{GET}}
#' @return A data.frame with ten columns containing:
#' @return "locID": unique identifier for the hotspot
#' @return "locName": hotspot name
#' @return "countryCode": country code
#' @return "subnational1Code": subnational1 code (state/province level)
#' @return "subnational2Code": subnational2 code (county/municipality level)
#' @return "lat": latitude of the hotspot
#' @return "lng": longitude of the hotspot
#' @return "latestObsDt": Date of latest observation
#' @return "numSpeciesAllTime": Total number of species recorded in the hotspot
#' @return "locID": unique identifier for the hotspot (redundant)
#' @export
#' @examples \dontrun{
#' ebirdhotspotlist("CA-NS-HL")
#' ebirdhotspotlist("VA")
#' ebirdhotspotlist(lat = 30, lng = -90, dist = 10)
#' library(httr)
#' ebirdhotspotlist("CA-NS-HL", config = verbose())
#' }
#' @author Sebastian Pardo \email{sebpardo@@gmail.com}
#' @references \url{http://ebird.org/}

ebirdhotspotlist <-  function(regionCode = NULL, lat = NULL, lng = NULL, dist = NULL, back = NULL,
                      sleep = 0, key = NULL, ...) {
  
  if (length(regionCode) > 1) {
    stop("More than one location specified")
  }
  
  if (is.null(regionCode) & any(is.null(lat), is.null(lng))) stop("Both region and lat/lng include NULL values")
  
  if (!is.null(back)) {
    if (back > 30) {
      back <- 30
      warning("'Back' supplied was >30 days, using 30 days")
    }
    back <- round(back)
  }
  
  if (is.null(regionCode) & all(!is.null(lat), !is.null(lng))) {
    message("Coordinates provided instead of region code, locating hostpots using lat/lng")
    lat <- round(lat, 2)
    lng <- round(lng, 2)
    
    if (!is.null(dist)) {
      if (dist > 500) {
        dist <- 500
        warning("Distance supplied was >500km, using 500km")
      }
      dist <- round(dist)
    }
    
    url <- paste0(ebase(),"ref/hotspot/geo?lat=", lat, "&lng=", lng) 
    args <- ebird_compact(list(fmt = "json", back = back, dist = dist))
  } else {
    invisible(ebirdregioninfo(regionCode, key = key))
    url <- paste0(ebase(),"ref/hotspot/", regionCode)
    args <- ebird_compact(list(fmt = "json", back = back))
  }
  
  Sys.sleep(sleep)
  ebird_GET(url, args = args, key = key, ...)
}
