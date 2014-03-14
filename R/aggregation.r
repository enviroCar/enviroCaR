
#' Function that is used to aggregate measurements of a Track object
#' 
#' @param track Track object that has to be aggregated
#' @param phen Phenomenon (a string) for aggregation (all phenomenons by default)
#' @param interval The interval size (a number) of measurements that have to be aggregated (20 by default)
#' @param fn Specification for aggregation function (mean by default)
#' @return aggregated Track object
#'
#' TODO: aggregate over list of phenomenons; aggregation over time?
#'
aggregateTrack <- function(track,phen,interval,fn){
  
  if (!missing(track)){
    
    if(missing (interval)){interval = 20} 
    tdf = track@tracks$Track1@data
    size = nrow(tdf)
    groupCount = ceiling(size/interval)
    remainder = interval*(groupCount-1)
    groupNr = 1
    
    #create groups for aggregation according to interval length
    for(i in 1:remainder){
      if (i!=1 && i%%interval == 1) {groupNr = groupNr + 1}
      tdf$Group[i] = groupNr
    }
    groupNr = groupCount
    for (j in (remainder+1):size){
      tdf$Group[j] = groupNr
    }
    
    #aggegation of values
    #if no phenomenon was specified, aggregate over the whole track
    if (missing (fn)){fn = mean}
    if (missing (phen)){ 
      aggrData = aggregate(tdf,list(tdf$Group),fn, na.rm=TRUE)
      #names(aggrData)[names(aggrData)=="Group.1"] <- "id"
      aggrData$id <- aggrData$Group-1
      aggrData$Group.1 <- NULL
      aggrData$Group <-NULL
      #TODO: add "aggr." in front of each attribute name
    }
    else {
      #a bit ugly: solving naming problem
      tdf2 = NULL
      tdf2 = as.list(tdf2)
      tdf2$time = tdf$time
      tdf2$phen = tdf[phen]
      
      #aggrData = aggregate(tdf[phen],list(tdf$Group),mean,rm.na=TRUE)
      aggrData = aggregate(tdf2,list(tdf$Group),fn,na.rm=TRUE)
      names(aggrData)[names(aggrData)==phen] <- paste("aggr",phen,sep=".")
      aggrData$id = aggrData$Group-1      
      aggrData$Group.1 <- NULL
      aggrData$Group <-NULL
      aggrData <- aggrData[,c(3,1,2)]
    }
    
    #time-slot:
    aggrTime = as.POSIXct(aggrData$time, format="%Y-%m-%dT%H:%M:%SZ")
    
    #selecting coordinates
    indexList = list(1:groupCount)
    #for spatial points: take the point at half of each interval step as coord
    for (k in 1:groupCount){
      indx = k*interval-floor(interval/2)
      #print(indx)
      if(k<groupCount) {
        indexList[k] = indx 
      }else{
        lastIndx = floor((size-remainder)/2)+remainder
        #print(lastIndx)
        indexList[k] = lastIndx
      }
    }
    #aggrSp <- track@sp[do.call(c,indexList)]
    aggrSp <- track@tracks$Track1@sp[do.call(c,indexList)]
    
    #Create Track object from the data, time and spatial points
    aggrSTIDF = STIDF(geometry(aggrSp), aggrTime, aggrData)
    aggrTrack = Track(aggrSTIDF)
    
    return(aggrTrack)
  }
}