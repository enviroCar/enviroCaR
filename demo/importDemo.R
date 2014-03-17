library(xts)
library(sp)
library(spacetime)

serverUrl = "https://envirocar.org/api/stable"
boundingbox = matrix(c(7.61,51.96,7.62,51.97),ncol=2,dimnames=list(c("x","y"),c("min","max")))
interval = .parseISO8601('2013-12-01T13:30/2013-12-06T13:39')
tracks=importEnviroCar(serverUrl,bbox=boundingbox)

summary(tracks)

# what is the lengthof the collection
length(tracks@tracksCollection)

stplot(tracks)
