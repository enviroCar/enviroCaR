library(enviroCaR)

#query track IDs and choose random track
serverUrl = "https://envirocar.org/api/stable"
trackIds = getTrackIDs(serverUrl)
randomId = trackIds[sample(1:length(trackIds),1)]

#import track 
trackData = importSingleTrack(serverUrl,randomId)

#aggregate to average speed of tracks over groups of ten measurements
newTrack = aggregateTrack(track=trackData,phen="Speed",interval=10,fn=mean)

#aggregate with default values
newTrack2 = aggregateTrack(track=trackData)

#plot points which are chosen
plot(trackData@tracks$Track1@sp@coords,col="blue",pch="*")
points(newTrack@sp,col="red",pch="o")
points(newTrack2@sp,col="green",pch="O")

#plot 
plot(trackData@tracks$Track1@data$time,trackData@tracks$Track1@data$Speed,type="l",col="blue",ylab="Speed",xlab="Minutes");
lines(newTrack@data$time,newTrack@data$aggr.Speed,col="red")
lines(newTrack2@data$time,newTrack2@data$Speed,col="green")


