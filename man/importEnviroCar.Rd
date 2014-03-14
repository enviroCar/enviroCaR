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

TODO: unclear how to encode temporalFilter; should Tracks
or TracksCollection be returned?
}
\description{
Imports the envirocar data
}

