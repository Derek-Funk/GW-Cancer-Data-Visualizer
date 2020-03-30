# 1) downloaded EPQ air quality index files from
# https://planning.dc.gov/page/american-community-survey-acs-estimates to
# C:\Users\derek.funk\Desktop\MSDS\Capstone\Cancer_Data_Visualizer\Data\Raw_Data\American Community Survey
# 2) used this file to process these files into a dataframe that I appended to master file in v.7.2

library(dplyr)
library(xlsx)

setwd("C:\\Users\\derek.funk\\Desktop\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data\\American Community Survey")

# REGIONS_LIST = c(
#   paste("Ward", 1:8), #wards 1-8
#   "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", #VA counties 9-12
#   "Charles County", "Prince George's County", "Montgomery County", #MD counties 13-15
#   "District of Columbia", #DC 16
#   "DMV Catchment Area" #DMV catchment 17
# )
# 
# states = c("District Of Columbia",rep("Maryland",3),rep("Virginia",4))
# counties = c("District of Columbia","Montgomery","Prince George's","Charles","Arlington","Fairfax",
#              "Loudoun","Prince William")
# renamedCounties = c("District of Columbia","Montgomery County","Prince George's County","Charles County",
#                     "Arlington County","Fairfax County","Loudoun County","Prince William County")
# # stateCountyList = list(states, counties)
# pairing = paste(states, counties)

lastYear = 2017
firstYear = 2013
numberOfYears = lastYear - firstYear + 1
numberOfRegions = 17
numberOfCategories = 3
categories = c("No vehicles", "1 vehicle", "2 or more vehicles")

dataFrameToWrite = data.frame(
  variable = rep("vehiclesPerHousingUnit", numberOfYears*numberOfRegions*numberOfCategories),
  year = rep(lastYear:firstYear, each=numberOfRegions*numberOfCategories),
  region = rep(rep(1:numberOfRegions, each = numberOfCategories), numberOfYears),
  category = rep(categories, numberOfYears*numberOfRegions),
  count = rep(NA, numberOfYears*numberOfRegions*numberOfCategories)
)

aqis = NULL
for(year in lastYear:firstYear) {
  tempFile = paste0(year-4, "-", year, " ACS 5-Year Ward.xls")
  wholeFrame = xlsx::read.xlsx(file = tempFile, sheetIndex = 1)
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
