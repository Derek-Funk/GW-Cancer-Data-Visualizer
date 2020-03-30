# takes about 3 minutes
# timePoint1 = proc.time()

library(dplyr)
library(readxl)
library(stringr)

setwd("C:\\Users\\derek.funk\\Documents\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data")

REF_REGIONS = data.frame(
  id = c(
    0,
    1:8,
    11001,
    24017, 24031, 24033,
    51013, 51059, 51107, 51153,
    51510, 51600, 51610, 51683, 51685
  ),
  name = c(
    "DMV Catchment Area",
    paste("Ward", 1:8),
    "District of Columbia",
    "Charles County", "Montgomery County", "Prince George's County", # MD counties
    "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", # VA counties
    "Alexandria", "Fairfax", "Falls Church", "Manassas", "Manassas Park" # independent cities
  )
)
# REGIONS_LIST = c(
#   paste("Ward", 1:8), #wards 1-8
#   "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", #VA counties 9-12
#   "Charles County", "Prince George's County", "Montgomery County", #MD counties 13-15
#   "District of Columbia", #DC 16
#   "DMV Catchment Area" #DMV catchment 17
# )
# regions = 1:17

virginiaFileNames = c("2013 County Health Ranking Virginia Data - v1_0.xls", "2014 County Health Rankings Virginia Data - v6.xls",
              "2015 County Health Rankings Virginia Data - v3.xls", "2016 County Health Rankings Virginia Data - v3.xls",
              "2017 County Health Rankings Virginia Data - v2.xls")

marylandFilenames = c("2013 County Health Ranking Maryland Data - v1_0.xls",
              "2014 County Health Rankings Maryland Data - v6.xls", "2015 County Health Rankings Maryland Data - v3.xls",
              "2016 County Health Rankings Maryland Data - v3.xls", "2017 County Health Rankings Maryland Data - v2.xls")

years = 2013:2017

lookup = data.frame(
  variable = c("poorOrFairHealth", "smoking", "obesity", "physicalInactivity","excessiveDrinking",
               "diabeticScreening", "mammographyScreening", "inadequateSocialSupport", "singleParentHouseholds",
               "violentCrimeRate", "limitedAccessToHealthyFoods",
               
               "diabetic", "hivPrevalence", "prematureMortalityRate", "childrenEligibleForFreeLunch",
               "homicideRate"),
  # sheetName = c(rep("Ranked Measure Data", 12), rep("Additional Measure Data", 6)),
  variableLookupNameRaw = c("% Fair/Poor", "% Smokers", "% Obese", "% Physically Inactive", "% Excessive Drinking",
                         "% HbA1c", "% Mammography", "% No Social-Emotional Support", "% Single-Parent Households",
                         "Violent Crime Rate", "% Limited Access",
                         
                         "% diabetic", "HIV Rate", "Age-adjusted Mortality", "% Free lunch",
                         "Homicide Rate")
)
lookup$variableLookupName = tolower(lookup$variableLookupNameRaw)

finalDataFrame = expand.grid(
  variable = lookup$variable,
  year = years,
  region = REF_REGIONS$id
)
# lookup$sheetName = as.character(lookup$sheetName)
lookup$variableLookupName = as.character(lookup$variableLookupName)

numberOfRows = dim(finalDataFrame)[1]

finalDataFrame$category = NA
finalDataFrame$count = NA
finalDataFrame$rate = NA

for(i in 1:numberOfRows) {
  variableLookup = finalDataFrame$variable[i]
  yearLookup = finalDataFrame$year[i]
  regionLookup = finalDataFrame$region[i]
  
  if(regionLookup %in% c(51013, 51059, 51107, 51153)) {
    fileToRead = virginiaFileNames[yearLookup-2012]
    # sheetToRead = lookup$sheetName[match(variableLookup, lookup$variable)]
    variableToRead = lookup$variableLookupName[match(variableLookup, lookup$variable)]
    regionToRead = str_remove(REF_REGIONS$name[match(regionLookup, REF_REGIONS$id)], pattern = " County")
    
    readDataFrame1 = read_excel(path = fileToRead, sheet = "Ranked Measure Data", skip = 1)
    readDataFrame2 = read_excel(path = fileToRead, sheet = "Additional Measure Data", skip = 1)
    names(readDataFrame2) = paste0(names(readDataFrame2), "2")
    readDataFrame = inner_join(x = readDataFrame1, y = readDataFrame2, by = c("County" = "County2"))
    names(readDataFrame) = tolower(names(readDataFrame))
    
    if(variableToRead %in% names(readDataFrame)) {
      finalDataFrame$rate[i] = readDataFrame[variableToRead][[1]][match(regionToRead, readDataFrame$county)]  
    } else if(paste0(variableToRead, "2") %in% names(readDataFrame)) {
      finalDataFrame$rate[i] = readDataFrame[paste0(variableToRead, "2")][[1]][match(regionToRead, readDataFrame$county)]  
    } else {
      NULL
    }
    
  } else if(regionLookup %in% c(24017, 24031, 24033)) {
    fileToRead = marylandFilenames[yearLookup-2012]
    # sheetToRead = lookup$sheetName[match(variableLookup, lookup$variable)]
    variableToRead = lookup$variableLookupName[match(variableLookup, lookup$variable)]
    regionToRead = str_remove(REF_REGIONS$name[match(regionLookup, REF_REGIONS$id)], pattern = " County")
    
    readDataFrame1 = read_excel(path = fileToRead, sheet = "Ranked Measure Data", skip = 1)
    readDataFrame2 = read_excel(path = fileToRead, sheet = "Additional Measure Data", skip = 1)
    names(readDataFrame2) = paste0(names(readDataFrame2), "2")
    readDataFrame = inner_join(x = readDataFrame1, y = readDataFrame2, by = c("County" = "County2"))
    names(readDataFrame) = tolower(names(readDataFrame))
    
    if(variableToRead %in% names(readDataFrame)) {
      finalDataFrame$rate[i] = readDataFrame[variableToRead][[1]][match(regionToRead, readDataFrame$county)]  
    } else if(paste0(variableToRead, "2") %in% names(readDataFrame)) {
      finalDataFrame$rate[i] = readDataFrame[paste0(variableToRead, "2")][[1]][match(regionToRead, readDataFrame$county)]  
    } else {
      NULL
    }
  } else {
    NULL
  }
  
  print(numberOfRows - i)
  
}

finalDataFrame$rate = round(finalDataFrame$rate, 1)

# timePoint2 = proc.time()
# timePoint2 - timePoint1

write.table(x = finalDataFrame, file = "masterDataFile_nonCancer_countyWard.csv",
            col.names = FALSE, row.names = FALSE, sep = ",", append = TRUE)

timePoint2 = proc.time()
timePoint2 - timePoint1
