library(dplyr)
library(readxl)
library(stringr)

setwd("C:\\Users\\derek.funk\\Desktop\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data")

REGIONS_LIST = c(
  paste("Ward", 1:8), #wards 1-8
  "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", #VA counties 9-12
  "Charles County", "Prince George's County", "Montgomery County", #MD counties 13-15
  "District of Columbia", #DC 16
  "DMV Catchment Area" #DMV catchment 17
)

virginiaFileNames = c("2013 County Health Ranking Virginia Data - v1_0.xls", "2014 County Health Rankings Virginia Data - v6.xls",
              "2015 County Health Rankings Virginia Data - v3.xls", "2016 County Health Rankings Virginia Data - v3.xls",
              "2017 County Health Rankings Virginia Data - v2.xls")

marylandFilenames = c("2013 County Health Ranking Maryland Data - v1_0.xls",
              "2014 County Health Rankings Maryland Data - v6.xls", "2015 County Health Rankings Maryland Data - v3.xls",
              "2016 County Health Rankings Maryland Data - v3.xls", "2017 County Health Rankings Maryland Data - v2.xls")

years = 2013:2017
regions = 1:17

lookup = data.frame(
  variable = c("poorOrFairHealth", "smoking", "obesity", "physicalInactivity","excessiveDrinking",
               "diabeticScreening", "mammographyScreening", "inadequateSocialSupport", "singleParentHouseholds",
               "violentCrimeRate", "limitedAccessToHealthyFoods", "fastFoodRestaurants",
               
               "diabetic", "hivPrevalence", "prematureMortalityRate", "childrenEligibleForFreeLunch",
               "homicideRate", "accessToParks"),
  sheetName = c(rep("Ranked Measure Data", 12), rep("Additional Measure Data", 6)),
  variableLookupName = c("% Fair/Poor", "% Smokers", "% Obese", "% Physically Inactive", "% Excessive Drinking",
                         "% HbA1c", "% Mammography", "% No Social-Emotional Support", "# Single-Parent Households",
                         "Violent Crime Rate", "# Limited Access", "% Fast Foods",
                         
                         "% diabetic", "HIV Rate", "Age-adjusted Mortality", "% Free lunch",
                         "Homicide Rate", "% park access")
)

finalDataFrame = expand.grid(
  variable = lookup$variable,
  year = years,
  region = regions
)
lookup$sheetName = as.character(lookup$sheetName)
lookup$variableLookupName = as.character(lookup$variableLookupName)

numberOfRows = dim(finalDataFrame)[1]

finalDataFrame$category = NA
finalDataFrame$count = NA
finalDataFrame$rate = NA

for(i in 1:numberOfRows) {
  variableLookup = finalDataFrame$variable[i]
  yearLookup = finalDataFrame$year[i]
  regionLookup = finalDataFrame$region[i]
  
  if(regionLookup %in% 9:12) {
    fileToRead = virginiaFileNames[yearLookup-2012]
    sheetToRead = lookup$sheetName[match(variableLookup, lookup$variable)]
    variableToRead = lookup$variableLookupName[match(variableLookup, lookup$variable)]
    regionToRead = str_remove(REGIONS_LIST[regionLookup], pattern = " County")
    
    readDataFrame = read_excel(path = fileToRead, sheet = sheetToRead, skip = 1)
    
    finalDataFrame$rate[i] = readDataFrame[variableToRead][[1]][match(regionToRead, readDataFrame$County)]
  } else if(regionLookup %in% 13:15) {
    fileToRead = marylandFilenames[yearLookup-2012]
    sheetToRead = lookup$sheetName[match(variableLookup, lookup$variable)]
    variableToRead = lookup$variableLookupName[match(variableLookup, lookup$variable)]
    regionToRead = str_remove(REGIONS_LIST[regionLookup], pattern = " County")
    
    readDataFrame = read_excel(path = fileToRead, sheet = sheetToRead, skip = 1)
    
    finalDataFrame$rate[i] = readDataFrame[variableToRead][[1]][match(regionToRead, readDataFrame$County)]
  } else {
    NULL
  }
}
