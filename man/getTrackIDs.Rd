\name{getTrackIDs}
\alias{getTrackIDs}
\title{retrieves the track IDs from the Envirocar server for passed spatial and/or temporal filter}
\usage{
getTrackIDs(serverUrl, bbox, timeInterval, name, password, verbose = FALSE)
}
\arguments{
  \item{serverUrl}{base URL of the Envirocar server}

  \item{bbox}{spatial bounding box}

  \item{timeInterval}{interval represented as list of
  POSIXct}
  
  \item{name}{Username for Envirocar login, in brackets! (optional parameters)}
  
  \item{password}{Password for Envirocar login,in brackets! (optional parameters)}

  \item{verbose}{print debug output}
}
\value{
list containing the track IDs for the specified bbox and
time interval, if these are present; otherwise all track
IDs are returned
}
\description{
retrieves the track IDs from the Envirocar server for
passed spatial and/or temporal filter. 
If name and password of an EnviroCar account is given, 
only ids from corresponding user will be retrieved.
}

