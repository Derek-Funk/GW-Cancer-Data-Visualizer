# 1) downloaded EPQ air quality index files from https://aqs.epa.gov/aqsweb/airdata/download_files.html to
# C:\Users\derek.funk\Desktop\MSDS\Capstone\Cancer_Data_Visualizer\Data\Raw_Data\EPA
# 2) used this file to process these files into a dataframe that I appended to master file in v.6.8

library(dplyr)

setwd("C:\\Users\\derek.funk\\Desktop\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data\\EPA")

REGIONS_LIST = c(
  paste("Ward", 1:8), #wards 1-8
  "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", #VA counties 9-12
  "Charles County", "Prince George's County", "Montgomery County", #MD counties 13-15
  "District of Columbia", #DC 16
  "DMV Catchment Area" #DMV catchment 17
)

states = c("District Of Columbia",rep("Maryland",3),rep("Virginia",4))
counties = c("District of Columbia","Montgomery","Prince George's","Charles","Arlington","Fairfax",
             "Loudoun","Prince William")
renamedCounties = c("District of Columbia","Montgomery County","Prince George's County","Charles County",
                    "Arlington County","Fairfax County","Loudoun County","Prince William County")
# stateCountyList = list(states, counties)
pairing = paste(states, counties)

lastYear = 2017
firstYear = 2013
numberOfYears = lastYear - firstYear + 1
numberOfRegions = 17

dataFrameToWrite = data.frame(
  variable = rep("airQualityIndex", numberOfYears*numberOfRegions),
  year = rep(lastYear:firstYear, each=numberOfRegions),
  region = rep(1:numberOfRegions, times = numberOfYears),
  category = NULL,
  count = NA
)

aqis = NULL
for(year in lastYear:firstYear) {
  tempFile = paste0("annual_aqi_by_county_", year, ".csv")
  wholeFrame = read.csv(file = tempFile)
  wholeFrame = wholeFrame %>%
    select(State, County, Median.AQI) %>%
    filter(paste(State, County) %in% pairing) %>%
    mutate(RenamedCounty = renamedCounties[match(County, counties)]) %>%
    mutate(region = match(RenamedCounty, REGIONS_LIST)) %>%
    arrange(region)
  
  aqis = c(aqis, rep(NA,8), wholeFrame$Median.AQI, NA)
}

dataFrameToWrite$rate = aqis

setwd("C:\\Users\\derek.funk\\Desktop\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Shiny_Application\\Cancer_Data_Visualizer_v6\\Cancer_Data_Visualizer_v6.8\\www")

write.table(dataFrameToWrite, file = "masterDataFile_nonCancer_countyWard.csv", sep = ",",
            row.names = FALSE, col.names = FALSE, append = TRUE)
