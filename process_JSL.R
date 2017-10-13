library(stringr)
library(plyr)
library(dplyr)
library(lubridate)
library(measurements)

# Macrozooplankton data ----
#read in  data
z <- read.csv("195101-201404_Zoop.csv")
z <- z[,which(unlist(lapply(z, function(x)!all(is.na(x)))))] #using the "lapply" function from the "dplyr" package, remove fields which contain all "NA" values
#create new fields with decimal degree latitude and longitude values
z$latdeg<-paste(z$Lat_Deg, z$Lat_Min, sep = " ")
z$londeg<-paste(z$Lon_Deg, z$Lon_Min, sep = " ")
z$Lat_DecDeg <- conv_unit(z$latdeg,"deg_dec_min", "dec_deg")
z$Lon_DecDeg<-conv_unit(z$londeg,"deg_dec_min","dec_deg")
z$latdeg<-NULL;z$londeg<-NULL
z$Lon_DecDeg<-as.numeric(z$Lon_DecDeg)
z$Lon_DecDeg<-z$Lon_DecDeg*-1
# create a date-time field
z$tow_date<-as.character(z$Tow_Date)
z$tow_time<-as.character(z$Tow_Time)
z$dateTime <- str_c(z$tow_date," ", z$tow_time, ":00")
z$dateTime <- as.POSIXct(strptime(z$dateTime, format = "%m/%d/%Y %H:%M:%S",  tz = "America/Los_Angeles")) #Hint: look up input time formats for the 'strptime' function
z$tow_date <- NULL; z$tow_time <- NULL
#export data as tab delimited file
write.table(z, file="zoop.txt",sep="\t",row.names = FALSE)
#subset to 1997/1998 
z$date <- substr(z$dateTime, 0, 10)
ninostart<-as.Date("1997-06-01")
ninoend<-as.Date("1998-05-31")
znino<-subset(z, date>ninostart & date<ninoend)
write.table(znino, file="zoopnino.txt",sep="\t",row.names = FALSE)

#Egg data Set-----
#read in data set
e <- read.csv("erdCalCOFIcufes_bb4a_5c83_ad3a.csv")
#turn these character fields into date-time field
e$stop_time_UTC <- gsub(x=e$stop_time_UTC, pattern="T", replacement = " ")
e$stop_time_UTC <- gsub(x=e$stop_time_UTC, pattern="Z", replacement = "")
e$time_UTC <- gsub(x = e$time_UTC, pattern = "T", replacement = " ")
e$time_UTC <-gsub(x=e$time_UTC, pattern="Z", replacement = "")
e$stop_time_UTC<-as.POSIXct(strptime(e$stop_time_UTC, format = "%Y-%m-%d %H:%M:%S",  tz = "America/Los_Angeles")) 
e$time_UTC<-as.POSIXct(strptime(e$time_UTC, format = "%Y-%m-%d %H:%M:%S",  tz = "America/Los_Angeles")) 
e <- e[,c(1:26,28)]
#export data
write.table(e, file="eggs.txt",sep="\t",row.names = FALSE)
#subset to 1997/1998 
e$date <- substr(e$time_UTC, 0, 10)
enino<-subset(e, date>ninostart & date<ninoend)
write.table(enino, file="eggsnino.txt",sep="\t",row.names = FALSE)
