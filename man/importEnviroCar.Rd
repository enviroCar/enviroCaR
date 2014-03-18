\name{importEnviroCar}
\alias{importEnviroCar}
\title{Imports the envirocar data}
\usage{
importEnviroCar(serverUrl, trackIDs, bbox, timeInterval)
}
\arguments{
  \item{serverUrl}{url to server}

  \item{trackIDs}{ids of tracks that should be retrieved}

  \item{bbox}{spatial bounding box as defined in package sp
  (matrix with two columns min and max)}

  \item{timeInterval}{interval (list of POSIXct objects)}
}
\value{
Tracks objects for the requested tracks
}
\description{
Imports the envirocar data
}
\examples{
\dontrun{
serverUrl = "https://envirocar.org/api/stable"
boundingbox = matrix(c(7.61,51.96,7.62,51.97),ncol=2,dimnames=list(c("x","y"),c("min","max")))
interval = .parseISO8601('2013-12-01T13:30/2013-12-06T13:39')
tracks=importEnviroCar(serverUrl,bbox=boundingbox)
}
}

