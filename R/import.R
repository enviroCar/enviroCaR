#' Imports the envirocar data
#' 
#' @param serverUrl url to server
#' @param trackIDs ids of tracks that should be retrieved
#' @param bbox spatial bounding box as defined in package sp (matrix with two columns min and max)
#' @param timeInterval interval (list of POSIXct objects)
#' @return Tracks objects for the requested tracks
#' @examples
#' \dontrun{
#' serverUrl = "https://envirocar.org/api/stable"
#' boundingbox = matrix(c(7.61,51.96,7.62,51.97),ncol=2,dimnames=list(c("x","y"),c("min","max")))
#' interval = .parseISO8601('2013-12-01T13:30/2013-12-06T13:39')
#' tracks=importEnviroCar(serverUrl,bbox=boundingbox)
#' }
#' 
importEnviroCar = function(serverUrl, trackIDs, bbox, timeInterval) {
  
  # query track IDs for bounding box and time interval; if trackIDs paramter is set, bbox and timeInterval are ignored
  if (missing(trackIDs)){
    trackIDs = getTrackIDs(serverUrl,bbox,timeInterval)
  }
  
  # query track for each trackID
  if(length(trackIDs)==0)
    stop("No tracks available for the specified boundingbox and/or temporal filter.")
  tracks = TracksCollection(lapply(trackIDs,importSingleTrack,serverUrl=serverUrl))
  
  return(tracks)
}


#' Imports a single track
#' 
#' @param serverUrl url to server
#' @param trackID ids of the track that should be retrieved
#' @param verbose print debug output
#' @return Tracks objects for the requested tracks
#' 
#'
importSingleTrack <- function(serverUrl, trackID, verbose = FALSE){
  
  singleTrackUrl=paste(serverUrl,"/tracks/",trackID,sep="")
  if(verbose)message(paste("Retrieving single track from url ",singleTrackUrl,sep=""))
  
  # read data as spatial object:
  layer = readOGR(getURL(singleTrackUrl,ssl.verifypeer = FALSE), layer = "OGRGeoJSON")
  
  # convert time from text to POSIXct:
  layer$time = as.POSIXct(layer$time, format="%Y-%m-%dT%H:%M:%SZ")
  # the third column is JSON, we want it in a table (data.frame) form:
  # 1. form a list of lists
  l1 = lapply(as.character(layer[[3]]), fromJSON)
  # 2. parse the $value elements in the sublist:
  l2 = lapply(l1,
              function(x) as.data.frame(lapply(x, function(X) X$value)))
  # create a matrix with all columns and then convert it to a data frame
  # thanks to Kristina Helle!
  # dynamic parsing of phenomenon names and units
  phenomenonsUrl = paste(serverUrl,"/phenomenons",sep="")
  phenomenons = fromJSON(getURL(phenomenonsUrl,ssl.verifypeer = FALSE))
  colNames = str_replace_all(sapply(phenomenons[[1]], "[[", "name"),
  													 pattern = " ",
  													 replacement = ".")
  colNames = str_replace_all(colNames, pattern = "-", replacement = ".")
  resultMatrix = matrix(nrow=length(l2),ncol=length(colNames))
  dimnames(resultMatrix)[[2]]=colNames
  for (i in seq(along = l2))
    resultMatrix[i,names(l2[[i]])]=as.numeric(l2[[i]])
  result = as.data.frame(resultMatrix)
  
  # set the units:
  units <- sapply(phenomenons[[1]], "[[", "unit")
  names(units)=colNames

  layer[[3]] = NULL
  # add the table as attributes to the spatial object 
  if (length(layer) == nrow(result)) {
    layer = spCbind(layer, result)
    stidf = STIDF(geometry(layer), layer$time, layer@data)
    #filtering of duplicate measurements in a single track
    redundant = which(diff(as.numeric(index(stidf@time)))==0)
    if(length(redundant)!=0){
      stidf = stidf[-redundant,]
    }
    track = Track(stidf)
    attr(track, "units") = units
    tracks = Tracks(list(track)) #TODO: group single tracks 
    return(tracks)
  } else
    NULL  
}

#' retrieves the track IDs from the Envirocar server for passed spatial and/or temporal filter
#' 
#' @param serverUrl base URL of the Envirocar server
#' @param bbox spatial bounding box
#' @param timeInterval interval represented as list of POSIXct
#' @param verbose print debug output
#' @return list containing the track IDs for the specified bbox and time interval, if these are present; otherwise all track IDs are returned
#' 
#' 
getTrackIDs <- function(serverUrl, bbox, timeInterval, verbose = FALSE){
  
  trackUrl = paste(serverUrl,"/tracks",sep="")
  
  #add bbox parameter to URL, if present
  if (!missing(bbox)){
    bboxParam = paste("?bbox=", bbox[1,1], ",", bbox[2,1], ",", bbox[1,2], ",",
    									bbox[2,2], sep = "")
    trackUrl = paste(trackUrl, bboxParam, sep = "")
  }
  
  #add timeInterval parameter to URL, if present
  if (!missing(timeInterval)){
    isoFormat="%Y-%m-%dT%H:%M:%SZ"
    timeParam = paste("during=",format(timeInterval$first.time,format=isoFormat),",",format(timeInterval$last.time,format=isoFormat),sep="")
    if(missing(bbox)) trackUrl= paste(trackUrl,"?",sep="") # add '?', if bbox parameter is missing
    else trackUrl= paste(trackUrl,"&",sep="") # if bbox is there, add '&' for seperating parameters
    trackUrl = paste(trackUrl,timeParam,sep="")
  }
  
  if (verbose) message(paste("Basic track url is ",trackUrl))
  
  #set header parameter to retrieve header; passing header function as in RCurl example doesn't work
  body = getURI(trackUrl,ssl.verifypeer=FALSE,header=1)
  
  #split header from body and select header string
  headerAndBody = strsplit(body, split="\r\n\r\n")
  headerString = headerAndBody[[1]][1]
  body = headerAndBody[[1]][2]
  
  if(verbose) message(paste("Header is :",headerString))
  
  #######################
  #check whether there are more than 100 entries (then paging is needed!)
  header = parseHTTPHeader(headerString)
  result = lapply(header,parseLinkHeaderParam)
  result <- result[!sapply(result,is.null)] #remove null items
  pagenumber=0
  if (length(result)>0){
    for (i in 1:length(result)){
      if (grepl("last",result[i]$Link["relation"])){
        pagenumber = as.numeric(result[i]$Link["pagenumber"])
        if(verbose)message(paste("Number of pages for paging is ",pagenumber))
      }
    }
  }
  
  ###################
  ##parsing of actual track IDs, if paging is true (pagenumber>0), repeat parsing for each page
  trackIDs = parseTrackIDs(body)
  if(pagenumber>1){
    for (i in 2:pagenumber){
      if(verbose)message(paste("Iterating page ", i))
      paramString = paste ("limits=100&page=",i,sep="")
      if (missing(bbox)&&missing(timeInterval))requestUrl=paste(trackUrl,"?",paramString,sep="")
      else requestUrl=paste(trackUrl,"&",paramString,sep="")
      body = getURI(requestUrl,ssl.verifypeer=FALSE)
      currentTracks = parseTrackIDs(body)
      if(verbose)message(paste("Current number of tracks ", length(currentTracks)," for request url ",requestUrl))
      trackIDs = c(trackIDs,currentTracks)
    }
  }
  return(trackIDs)
}

#' ugly function for parsing the Link header parameter from the HTTP header, used for the paging mechanism
#' 
#' @param headerParam url to server
#' @return Tracks objects for the requested tracks
#'
#'
parseLinkHeaderParam <- function(headerParam){
  if (grepl("rel=",headerParam)){
    #link parameter looks like 
    #<https://envirocar.org/api/stable/tracks?limit=100&page=1>;rel=first;type=application/json
    lastpart=strsplit(headerParam,"&page=")[[1]][2] #split string by page parameter in order to retrieve page number and type of relation (rel)
    lastpartSplitted=strsplit(lastpart,"[>]")[[1]]
    pageNumberString = strsplit(lastpartSplitted[1],"&")[[1]][1] #needed, if there are additional bbox or time parameter
    rel = strsplit(strsplit(lastpartSplitted[2],"rel=")[[1]][2],";type")[[1]][1]
    result = c(pagenumber=pageNumberString,relation=rel)
    return(result)
    }
  else 
    return(NULL)
}

#' function that is used internally for parsing the trackIDs from JSON response
#' 
#' @param jsonBody that is return for a tracks URL from Envirocar server
#' @return list containing the parsed trackIDs
#'
parseTrackIDs<-function(jsonBody){
  sapply(fromJSON(jsonBody)$tracks,function(x) return(x$id))
}
