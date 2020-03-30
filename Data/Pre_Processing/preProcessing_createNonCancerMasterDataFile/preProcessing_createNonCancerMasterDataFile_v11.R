# DOCUMENTATION: This file takes 2013-2017 data from the ACS, EPA, and Robert Wood Johnson Foundation, and processes
#   them into 1 tidy file.
# INSTRUCTIONS:
#   1) From https://planning.dc.gov/page/american-community-survey-acs-estimates, download the 5-year files for both
#      wards and districtwide from 2013 to 2017 (10 files).
#   2) From https://aqs.epa.gov/aqsweb/airdata/download_files.html, download the AQI by County files for 2013 to 2017.
#      Unzip and keep just the annual_aqi_by_county_YYYY.csv files (5 files).
#   3) From https://www.countyhealthrankings.org/app/, use the filter to download the county Excel files for VA and MD
#      for the years 2013 to 2017 (10 files).
#   4) Ensure all 25 files are in your working directory (change line 25).
#   5) Run this script.

# takes about 25 minutes
timePoint1 = proc.time()

# libraries
#####
library(dplyr)
library(httr)
library(jsonlite)
library(readxl)
#####

# dataframe set  up
#####
setwd("C:\\Users\\derek.funk\\Documents\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data")

listOfVariables = list(
  "airQualityIndex" = NA,
  "belowPovertyLevel" = NA,
  "education" = c("Less than 9th grade","Some High School","High school graduate","Some College","Associate's Degree",
                "Bachelor's Degree","Advanced Degree"),
  "employment" = c("Employed","Unemployed"),
  "ethnicity" = c("Hispanic or Latino","Not Hispanic or Latino"),
  "foreign-born" = c("Native","Foreign-Born"),
  "healthInsuranceCoverage" = c("Private Health Insurance", "Public Health Insurance", "Uninsured"),
  "housingTenure" = c("Owner-occupied", "Renter-occupied"),
  "language" = c("English Only","Language Other Than English"),
  "medianAge" = NA,
  "medianHouseholdIncome" = NA,
  "population" = NA,
  "race" = c("White","Black","Asian or Pacific Islander","Native American","Other Individual Race","Two or More Races"),
  "rentGreaterThan30PercentOfHouseholdIncome" = NA,
  "vehiclesPerHousingUnit" = c("No vehicles","1 vehicle","2 vehicles","3 or more vehicles")
)

years = 2013:2017
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

finalDataFrame = data.frame()

for(variable in names(listOfVariables)) {
  dataFrameToAppend = expand.grid(
    variable = variable,
    year = years,
    region = REF_REGIONS$id,
    category = listOfVariables[[variable]]
  )
  
  finalDataFrame = rbind(finalDataFrame, dataFrameToAppend)
}

numberOfRows = dim(finalDataFrame)[1]

finalDataFrame$count = NA
finalDataFrame$rate = NA

fileNames = list(
  "ward" = c(
    "2009-2013 ACS 5-Year Esitmates-Ward_0.xls",
    "2010-2014 ACS 5-Year Estimates-Ward_0.xlsx",
    "2011-2015 Ward.xls",
    "2012-2016 ACS 5-Year Ward.xls",
    "2013-2017 ACS 5-Year Ward.xls"
  ),
  "dc" = c(
    "2009-2013 ACS 5-Year Districtwide.xls",
    "2010-2014 ACS 5-Year Estimates-Districtwide_0.xls",
    "2011-2015 Districtwide.xls",
    "2012-2016 ACS 5 -Year Districtwide.xls",
    "2013-2017 ACS 5-Year Districtwide.xls"
  )
)

acsGroups = c("Social", "Economic", "Housing", "Demographic")
sheetNames = list(
  "ward" = list(
    "2013" = paste0("2009-13 ACS_", acsGroups),
    "2014" = c("2010-14Social_Ward", paste0("2010-14 ", acsGroups[2:4], "_Ward")),
    "2015" = paste0("2011-15 ", acsGroups, "_Ward"),
    "2016" = acsGroups,
    "2017" = c("2013-17 Social_Ward", "2013-17 Economic_Ward ", "2013-17 Housing_Ward", "2013-17 Demographic_Ward")
  ),
  "dc" = list(
    "2013" = acsGroups,
    "2014" = paste0("2010-14 ", acsGroups),
    "2015" = c(paste0("2011-15 ", acsGroups[1:3], "_Districtwide"), "2011-15Demographic_Districtwide"),
    "2016" = acsGroups,
    "2017" = acsGroups
  )
)

finalDataFrame$fileName = NA

for(i in 1:numberOfRows) {
  finalDataFrame$fileName[i] = (
    if(finalDataFrame$region[i] == 11001) {
      fileNames$dc[finalDataFrame$year[i] - 2012]
    } else if(finalDataFrame$region[i] %in% 1:8) {
      fileNames$ward[finalDataFrame$year[i] - 2012]
    } else {
      NA
    }
  )
}

finalDataFrame$sheetName = NA

for(i in 1:numberOfRows) {
  if(any(
    ! finalDataFrame$region[i] %in% c(1:8, 11001),
    finalDataFrame$variable[i] %in% c("airQualityIndex")
  )) {
    NULL
  } else {
    
    regionGroup = (
      if(finalDataFrame$region[i] <= 8) {
        "ward"
      } else {
        "dc"
      }
    )
      
    variableGroupIndex = (
      if(finalDataFrame$variable[i] %in% c("education","foreign-born","language")) {
        # social
        1
      } else if(finalDataFrame$variable[i] %in% c("belowPovertyLevel","medianHouseholdIncome","employment",
                                                  "healthInsuranceCoverage")) {
        # economic
        2
      } else if(finalDataFrame$variable[i] %in% c("housingTenure","rentGreaterThan30PercentOfHouseholdIncome",
                                                  "vehiclesPerHousingUnit")) {
        # housing
        3
      } else if(finalDataFrame$variable[i] %in% c("race","medianAge","ethnicity","population")) {
        # demographic
        4
      } else {
        # from other source besides ACS
        NULL
      }
    )
    
    finalDataFrame$sheetName[i] = sheetNames[[regionGroup]][[as.character(finalDataFrame$year[i])]][variableGroupIndex]
  }
}

countsToSum = list(
  "ward" = list(
    "2013" = list(
      "belowPovertyLevel" = list(
        "1" = list(
          "rowIndex" = 61-1,
          "colIndex" = 4
        ),
        "2" = list(
          "rowIndex" = 61-1,
          "colIndex" = 7
        ),
        "3" = list(
          "rowIndex" = 61-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 61-1,
          "colIndex" = 13
        ),
        "5" = list(
          "rowIndex" = 61-1,
          "colIndex" = 16
        ),
        "6" = list(
          "rowIndex" = 61-1,
          "colIndex" = 19
        ),
        "7" = list(
          "rowIndex" = 61-1,
          "colIndex" = 22
        ),
        "8" = list(
          "rowIndex" = 61-1,
          "colIndex" = 25
        )
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 23
          )
        ),
        "Some High School" = list(
          "1" = list(
            "rowIndex" = 84-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 84-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 84-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 84-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 84-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 84-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 84-1,
            "colIndex" = 23
          )
        ),
        "High school graduate" = list(
          "1" = list(
            "rowIndex" = 85-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 85-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 85-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 85-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 85-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 85-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 85-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 85-1,
            "colIndex" = 23
          )
        ),
        "Some College" = list(
          "1" = list(
            "rowIndex" = 86-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 86-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 86-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 86-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 86-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 86-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 86-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 86-1,
            "colIndex" = 23
          )
        ),
        "Associate's Degree" = list(
          "1" = list(
            "rowIndex" = 87-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 87-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 87-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 87-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 87-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 87-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 87-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 87-1,
            "colIndex" = 23
          )
        ),
        "Bachelor's Degree" = list(
          "1" = list(
            "rowIndex" = 88-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 88-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 88-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 88-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 88-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 88-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 88-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 88-1,
            "colIndex" = 23
          )
        ),
        "Advanced Degree" = list(
          "1" = list(
            "rowIndex" = 89-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 89-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 89-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 89-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 89-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 89-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 89-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 89-1,
            "colIndex" = 23
          )
        )
      ),
      "employment" = list(
        "Employed" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 23
          )
        ),
        "Unemployed" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 23
          )
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 59-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 59-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 59-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 59-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 59-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 59-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 59-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 59-1,
            "colIndex" = 23
          )
        ),
        "Not Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 60-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 60-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 60-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 60-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 60-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 60-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 60-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 60-1,
            "colIndex" = 23
          )
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "1" = list(
            "rowIndex" = 119-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 119-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 119-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 119-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 119-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 119-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 119-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 119-1,
            "colIndex" = 23
          )
        ),
        "Foreign-Born" = list(
          "1" = list(
            "rowIndex" = 124-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 124-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 124-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 124-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 124-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 124-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 124-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 124-1,
            "colIndex" = 23
          )
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "1" = list(
            "rowIndex" = 9-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 9-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 9-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 9-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 9-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 9-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 9-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 9-1,
            "colIndex" = 23
          )
        ),
        "Renter-occupied" = list(
          "1" = list(
            "rowIndex" = 10-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 10-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 10-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 10-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 10-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 10-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 10-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 10-1,
            "colIndex" = 23
          )
        )
      ),
      "language" = list(
        "English Only" = list(
          "1" = list(
            "rowIndex" = 148-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 148-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 148-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 148-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 148-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 148-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 148-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 148-1,
            "colIndex" = 23
          )
        ),
        "Language Other Than English" = list(
          "1" = list(
            "rowIndex" = 149-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 149-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 149-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 149-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 149-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 149-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 149-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 149-1,
            "colIndex" = 23
          )
        )
      ),
      "medianAge" = list(
        "1" = list(
          "rowIndex" = 21-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 21-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 21-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 21-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 21-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 21-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 21-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 21-1,
          "colIndex" = 23
        )
      ),
      "medianHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 24-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 24-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 24-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 24-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 24-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 24-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 24-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 24-1,
          "colIndex" = 23
        )
      ),
      "population" = list(
        "1" = list(
          "rowIndex" = 7-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 7-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 7-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 7-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 7-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 7-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 7-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 7-1,
          "colIndex" = 23
        )
      ),
      "race" = list(
        "White" = list(
          "1" = list(
            "rowIndex" = 43-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 43-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 43-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 43-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 43-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 43-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 43-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 43-1,
            "colIndex" = 23
          )
        ),
        "Black" = list(
          "1" = list(
            "rowIndex" = 44-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 44-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 44-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 44-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 44-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 44-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 44-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 44-1,
            "colIndex" = 23
          )
        ),
        "Native American" = list(
          "1" = list(
            "rowIndex" = 45-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 45-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 45-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 45-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 45-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 45-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 45-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 45-1,
            "colIndex" = 23
          )
        ),
        "Asian or Pacific Islander" = list(
          "1" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 23
          )
        ),
        "Other Individual Race" = list(
          "1" = list(
            "rowIndex" = 48-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 48-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 48-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 48-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 48-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 48-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 48-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 48-1,
            "colIndex" = 23
          )
        ),
        "Two or More Races" = list(
          "1" = list(
            "rowIndex" = 49-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 49-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 49-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 49-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 49-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 49-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 49-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 49-1,
            "colIndex" = 23
          )
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 118-1,
          "colIndex" = 2+2
        ),
        "2" = list(
          "rowIndex" = 118-1,
          "colIndex" = 5+2
        ),
        "3" = list(
          "rowIndex" = 118-1,
          "colIndex" = 8+2
        ),
        "4" = list(
          "rowIndex" = 118-1,
          "colIndex" = 11+2
        ),
        "5" = list(
          "rowIndex" = 118-1,
          "colIndex" = 14+2
        ),
        "6" = list(
          "rowIndex" = 118-1,
          "colIndex" = 17+2
        ),
        "7" = list(
          "rowIndex" = 118-1,
          "colIndex" = 20+2
        ),
        "8" = list(
          "rowIndex" = 118-1,
          "colIndex" = 23+2
        )
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "1" = list(
            "rowIndex" = 61-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 61-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 61-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 61-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 61-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 61-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 61-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 61-1,
            "colIndex" = 23
          )
        ),
        "1 vehicle" = list(
          "1" = list(
            "rowIndex" = 62-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 62-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 62-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 62-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 62-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 62-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 62-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 62-1,
            "colIndex" = 23
          )
        ),
        "2 vehicles" = list(
          "1" = list(
            "rowIndex" = 63-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 63-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 63-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 63-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 63-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 63-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 63-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 63-1,
            "colIndex" = 23
          )
        ),
        "3 or more vehicles" = list(
          "1" = list(
            "rowIndex" = 64-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 64-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 64-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 64-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 64-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 64-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 64-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 64-1,
            "colIndex" = 23
          )
        )
      )
    ),
    "2014" = list(
      "belowPovertyLevel" = list(
        "1" = list(
          "rowIndex" = 162-1,
          "colIndex" = 4
        ),
        "2" = list(
          "rowIndex" = 162-1,
          "colIndex" = 8
        ),
        "3" = list(
          "rowIndex" = 162-1,
          "colIndex" = 12
        ),
        "4" = list(
          "rowIndex" = 162-1,
          "colIndex" = 16
        ),
        "5" = list(
          "rowIndex" = 162-1,
          "colIndex" = 20
        ),
        "6" = list(
          "rowIndex" = 162-1,
          "colIndex" = 24
        ),
        "7" = list(
          "rowIndex" = 162-1,
          "colIndex" = 28
        ),
        "8" = list(
          "rowIndex" = 162-1,
          "colIndex" = 32
        )
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 30
          )
        ),
        "Some High School" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 30
          )
        ),
        "High school graduate" = list(
          "1" = list(
            "rowIndex" = 84-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 84-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 84-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 84-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 84-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 84-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 84-1,
            "colIndex" = 30
          )
        ),
        "Some College" = list(
          "1" = list(
            "rowIndex" = 85-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 85-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 85-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 85-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 85-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 85-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 85-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 85-1,
            "colIndex" = 30
          )
        ),
        "Associate's Degree" = list(
          "1" = list(
            "rowIndex" = 86-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 86-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 86-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 86-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 86-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 86-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 86-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 86-1,
            "colIndex" = 30
          )
        ),
        "Bachelor's Degree" = list(
          "1" = list(
            "rowIndex" = 87-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 87-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 87-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 87-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 87-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 87-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 87-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 87-1,
            "colIndex" = 30
          )
        ),
        "Advanced Degree" = list(
          "1" = list(
            "rowIndex" = 88-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 88-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 88-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 88-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 88-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 88-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 88-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 88-1,
            "colIndex" = 30
          )
        )
      ),
      "employment" = list(
        "Employed" = list(
          "1" = list(
            "rowIndex" = 11-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 11-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 11-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 11-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 11-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 11-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 11-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 11-1,
            "colIndex" = 30
          )
        ),
        "Unemployed" = list(
          "1" = list(
            "rowIndex" = 12-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 12-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 12-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 12-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 12-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 12-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 12-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 12-1,
            "colIndex" = 30
          )
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 84,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 84,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 84,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 84,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 84,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 84,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 84,
            "colIndex" = 30
          )
        ),
        "Not Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 89,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 89,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 89,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 89,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 89,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 89,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 89,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 89,
            "colIndex" = 30
          )
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "1" = list(
            "rowIndex" = 122-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 122-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 122-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 122-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 122-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 122-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 122-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 122-1,
            "colIndex" = 30
          )
        ),
        "Foreign-Born" = list(
          "1" = list(
            "rowIndex" = 127-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 127-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 127-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 127-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 127-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 127-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 127-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 127-1,
            "colIndex" = 30
          )
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "1" = list(
            "rowIndex" = 125,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 125,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 125,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 125,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 125,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 125,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 125,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 125,
            "colIndex" = 30
          )
        ),
        "Public Health Insurance" = list(
          "1" = list(
            "rowIndex" = 126,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 126,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 126,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 126,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 126,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 126,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 126,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 126,
            "colIndex" = 30
          )
        ),
        "Uninsured" = list(
          "1" = list(
            "rowIndex" = 127,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 127,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 127,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 127,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 127,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 127,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 127,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 127,
            "colIndex" = 30
          )
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "1" = list(
            "rowIndex" = 62-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 62-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 62-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 62-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 62-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 62-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 62-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 62-1,
            "colIndex" = 30
          )
        ),
        "Renter-occupied" = list(
          "1" = list(
            "rowIndex" = 63-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 63-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 63-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 63-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 63-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 63-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 63-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 63-1,
            "colIndex" = 30
          )
        )
      ),
      "language" = list(
        "English Only" = list(
          "1" = list(
            "rowIndex" = 156,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 156,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 156,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 156,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 156,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 156,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 156,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 156,
            "colIndex" = 30
          )
        ),
        "Language Other Than English" = list(
          "1" = list(
            "rowIndex" = 157,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 157,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 157,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 157,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 157,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 157,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 157,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 157,
            "colIndex" = 30
          )
        )
      ),
      "medianAge" = list(
        "1" = list(
          "rowIndex" = 25-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 25-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 25-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 25-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 25-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 25-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 25-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 25-1,
          "colIndex" = 30
        )
      ),
      "medianHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 83-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 83-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 83-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 83-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 83-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 83-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 83-1,
          "colIndex" = 30
        )
      ),
      "population" = list(
        "1" = list(
          "rowIndex" = 7-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 7-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 7-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 7-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 7-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 7-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 7-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 7-1,
          "colIndex" = 30
        )
      ),
      "race" = list(
        "White" = list(
          "1" = list(
            "rowIndex" = 46-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 46-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 46-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 46-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 46-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 46-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 46-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 46-1,
            "colIndex" = 30
          )
        ),
        "Black" = list(
          "1" = list(
            "rowIndex" = 47-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 47-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 47-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 47-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 47-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 47-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 47-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 47-1,
            "colIndex" = 30
          )
        ),
        "Native American" = list(
          "1" = list(
            "rowIndex" = 48-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 48-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 48-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 48-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 48-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 48-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 48-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 48-1,
            "colIndex" = 30
          )
        ),
        "Asian or Pacific Islander" = list(
          "1" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = c(53,61)-1,
            "colIndex" = 30
          )
        ),
        "Other Individual Race" = list(
          "1" = list(
            "rowIndex" = 66-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 66-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 66-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 66-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 66-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 66-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 66-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 66-1,
            "colIndex" = 30
          )
        ),
        "Two or More Races" = list(
          "1" = list(
            "rowIndex" = 67-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 67-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 67-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 67-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 67-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 67-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 67-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 67-1,
            "colIndex" = 30
          )
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 2+2
        ),
        "2" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 6+2
        ),
        "3" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 10+2
        ),
        "4" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 14+2
        ),
        "5" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 18+2
        ),
        "6" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 22+2
        ),
        "7" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 26+2
        ),
        "8" = list(
          "rowIndex" = c(184,185)-1,
          "colIndex" = 30+2
        )
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "1" = list(
            "rowIndex" = 79-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 79-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 79-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 79-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 79-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 79-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 79-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 79-1,
            "colIndex" = 30
          )
        ),
        "1 vehicle" = list(
          "1" = list(
            "rowIndex" = 80-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 80-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 80-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 80-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 80-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 80-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 80-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 80-1,
            "colIndex" = 30
          )
        ),
        "2 vehicles" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 30
          )
        ),
        "3 or more vehicles" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 30
          )
        )
      )
    ),
    "2015" = list(
      "belowPovertyLevel" = list(
        "1" = list(
          "rowIndex" = 161-1,
          "colIndex" = 4
        ),
        "2" = list(
          "rowIndex" = 161-1,
          "colIndex" = 8
        ),
        "3" = list(
          "rowIndex" = 161-1,
          "colIndex" = 12
        ),
        "4" = list(
          "rowIndex" = 161-1,
          "colIndex" = 16
        ),
        "5" = list(
          "rowIndex" = 161-1,
          "colIndex" = 20
        ),
        "6" = list(
          "rowIndex" = 161-1,
          "colIndex" = 24
        ),
        "7" = list(
          "rowIndex" = 161-1,
          "colIndex" = 28
        ),
        "8" = list(
          "rowIndex" = 161-1,
          "colIndex" = 32
        )
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 30
          )
        ),
        "Some High School" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 30
          )
        ),
        "High school graduate" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 30
          )
        ),
        "Some College" = list(
          "1" = list(
            "rowIndex" = 84-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 84-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 84-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 84-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 84-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 84-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 84-1,
            "colIndex" = 30
          )
        ),
        "Associate's Degree" = list(
          "1" = list(
            "rowIndex" = 85-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 85-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 85-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 85-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 85-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 85-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 85-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 85-1,
            "colIndex" = 30
          )
        ),
        "Bachelor's Degree" = list(
          "1" = list(
            "rowIndex" = 86-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 86-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 86-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 86-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 86-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 86-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 86-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 86-1,
            "colIndex" = 30
          )
        ),
        "Advanced Degree" = list(
          "1" = list(
            "rowIndex" = 87-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 87-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 87-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 87-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 87-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 87-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 87-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 87-1,
            "colIndex" = 30
          )
        )
      ),
      "employment" = list(
        "Employed" = list(
          "1" = list(
            "rowIndex" = 9,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 9,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 9,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 9,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 9,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 9,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 9,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 9,
            "colIndex" = 30
          )
        ),
        "Unemployed" = list(
          "1" = list(
            "rowIndex" = 10,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 10,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 10,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 10,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 10,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 10,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 10,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 10,
            "colIndex" = 30
          )
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 83,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 83,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 83,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 83,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 83,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 83,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 83,
            "colIndex" = 30
          )
        ),
        "Not Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 88,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 88,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 88,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 88,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 88,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 88,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 88,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 88,
            "colIndex" = 30
          )
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "1" = list(
            "rowIndex" = 121-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 121-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 121-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 121-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 121-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 121-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 121-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 121-1,
            "colIndex" = 30
          )
        ),
        "Foreign-Born" = list(
          "1" = list(
            "rowIndex" = 126-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 126-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 126-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 126-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 126-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 126-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 126-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 126-1,
            "colIndex" = 30
          )
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "1" = list(
            "rowIndex" = 125-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 125-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 125-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 125-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 125-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 125-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 125-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 125-1,
            "colIndex" = 30
          )
        ),
        "Public Health Insurance" = list(
          "1" = list(
            "rowIndex" = 126-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 126-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 126-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 126-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 126-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 126-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 126-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 126-1,
            "colIndex" = 30
          )
        ),
        "Uninsured" = list(
          "1" = list(
            "rowIndex" = 127-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 127-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 127-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 127-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 127-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 127-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 127-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 127-1,
            "colIndex" = 30
          )
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "1" = list(
            "rowIndex" = 62-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 62-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 62-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 62-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 62-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 62-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 62-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 62-1,
            "colIndex" = 30
          )
        ),
        "Renter-occupied" = list(
          "1" = list(
            "rowIndex" = 63-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 63-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 63-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 63-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 63-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 63-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 63-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 63-1,
            "colIndex" = 30
          )
        )
      ),
      "language" = list(
        "English Only" = list(
          "1" = list(
            "rowIndex" = 155,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 155,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 155,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 155,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 155,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 155,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 155,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 155,
            "colIndex" = 30
          )
        ),
        "Language Other Than English" = list(
          "1" = list(
            "rowIndex" = 156,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 156,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 156,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 156,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 156,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 156,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 156,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 156,
            "colIndex" = 30
          )
        )
      ),
      "medianAge" = list(
        "1" = list(
          "rowIndex" = 24-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 24-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 24-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 24-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 24-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 24-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 24-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 24-1,
          "colIndex" = 30
        )
      ),
      "medianHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 82-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 82-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 82-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 82-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 82-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 82-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 82-1,
          "colIndex" = 30
        )
      ),
      "population" = list(
        "1" = list(
          "rowIndex" = 6-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 6-1,
          "colIndex" = 6
        ),
        "3" = list(
          "rowIndex" = 6-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 6-1,
          "colIndex" = 14
        ),
        "5" = list(
          "rowIndex" = 6-1,
          "colIndex" = 18
        ),
        "6" = list(
          "rowIndex" = 6-1,
          "colIndex" = 22
        ),
        "7" = list(
          "rowIndex" = 6-1,
          "colIndex" = 26
        ),
        "8" = list(
          "rowIndex" = 6-1,
          "colIndex" = 30
        )
      ),
      "race" = list(
        "White" = list(
          "1" = list(
            "rowIndex" = 45-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 45-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 45-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 45-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 45-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 45-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 45-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 45-1,
            "colIndex" = 30
          )
        ),
        "Black" = list(
          "1" = list(
            "rowIndex" = 46-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 46-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 46-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 46-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 46-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 46-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 46-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 46-1,
            "colIndex" = 30
          )
        ),
        "Native American" = list(
          "1" = list(
            "rowIndex" = 47-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 47-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 47-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 47-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 47-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 47-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 47-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 47-1,
            "colIndex" = 30
          )
        ),
        "Asian or Pacific Islander" = list(
          "1" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = c(52,60)-1,
            "colIndex" = 30
          )
        ),
        "Other Individual Race" = list(
          "1" = list(
            "rowIndex" = 65-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 65-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 65-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 65-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 65-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 65-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 65-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 65-1,
            "colIndex" = 30
          )
        ),
        "Two or More Races" = list(
          "1" = list(
            "rowIndex" = 66-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 66-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 66-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 66-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 66-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 66-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 66-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 66-1,
            "colIndex" = 30
          )
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 2+2
        ),
        "2" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 6+2
        ),
        "3" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 10+2
        ),
        "4" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 14+2
        ),
        "5" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 18+2
        ),
        "6" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 22+2
        ),
        "7" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 26+2
        ),
        "8" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 30+2
        )
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "1" = list(
            "rowIndex" = 79-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 79-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 79-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 79-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 79-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 79-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 79-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 79-1,
            "colIndex" = 30
          )
        ),
        "1 vehicle" = list(
          "1" = list(
            "rowIndex" = 80-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 80-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 80-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 80-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 80-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 80-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 80-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 80-1,
            "colIndex" = 30
          )
        ),
        "2 vehicles" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 30
          )
        ),
        "3 or more vehicles" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 18
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 22
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 26
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 30
          )
        )
      )
    ),
    "2016" = list(
      "belowPovertyLevel" = list(
        "1" = list(
          "rowIndex" = 61-1,
          "colIndex" = 4
        ),
        "2" = list(
          "rowIndex" = 61-1,
          "colIndex" = 7
        ),
        "3" = list(
          "rowIndex" = 61-1,
          "colIndex" = 10
        ),
        "4" = list(
          "rowIndex" = 61-1,
          "colIndex" = 13
        ),
        "5" = list(
          "rowIndex" = 61-1,
          "colIndex" = 16
        ),
        "6" = list(
          "rowIndex" = 61-1,
          "colIndex" = 19
        ),
        "7" = list(
          "rowIndex" = 61-1,
          "colIndex" = 22
        ),
        "8" = list(
          "rowIndex" = 61-1,
          "colIndex" = 25
        )
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 23
          )
        ),
        "Some High School" = list(
          "1" = list(
            "rowIndex" = 84-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 84-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 84-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 84-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 84-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 84-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 84-1,
            "colIndex" = 23
          )
        ),
        "High school graduate" = list(
          "1" = list(
            "rowIndex" = 85-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 85-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 85-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 85-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 85-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 85-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 85-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 85-1,
            "colIndex" = 23
          )
        ),
        "Some College" = list(
          "1" = list(
            "rowIndex" = 86-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 86-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 86-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 86-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 86-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 86-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 86-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 86-1,
            "colIndex" = 23
          )
        ),
        "Associate's Degree" = list(
          "1" = list(
            "rowIndex" = 87-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 87-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 87-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 87-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 87-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 87-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 87-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 87-1,
            "colIndex" = 23
          )
        ),
        "Bachelor's Degree" = list(
          "1" = list(
            "rowIndex" = 88-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 88-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 88-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 88-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 88-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 88-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 88-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 88-1,
            "colIndex" = 23
          )
        ),
        "Advanced Degree" = list(
          "1" = list(
            "rowIndex" = 89-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 89-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 89-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 89-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 89-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 89-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 89-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 89-1,
            "colIndex" = 23
          )
        )
      ),
      "employment" = list(
        "Employed" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 23
          )
        ),
        "Unemployed" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 23
          )
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 59-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 59-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 59-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 59-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 59-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 59-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 59-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 59-1,
            "colIndex" = 23
          )
        ),
        "Not Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 60-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 60-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 60-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 60-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 60-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 60-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 60-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 60-1,
            "colIndex" = 23
          )
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "1" = list(
            "rowIndex" = 119-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 119-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 119-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 119-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 119-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 119-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 119-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 119-1,
            "colIndex" = 23
          )
        ),
        "Foreign-Born" = list(
          "1" = list(
            "rowIndex" = 124-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 124-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 124-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 124-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 124-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 124-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 124-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 124-1,
            "colIndex" = 23
          )
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "1" = list(
            "rowIndex" = 145-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 145-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 145-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 145-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 145-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 145-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 145-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 145-1,
            "colIndex" = 23
          )
        ),
        "Public Health Insurance" = list(
          "1" = list(
            "rowIndex" = 144-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 144-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 144-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 144-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 144-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 144-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 144-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 144-1,
            "colIndex" = 23
          )
        ),
        "Uninsured" = list(
          "1" = list(
            "rowIndex" = 143-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 143-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 143-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 143-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 143-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 143-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 143-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 143-1,
            "colIndex" = 23
          )
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "1" = list(
            "rowIndex" = 9-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 9-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 9-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 9-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 9-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 9-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 9-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 9-1,
            "colIndex" = 23
          )
        ),
        "Renter-occupied" = list(
          "1" = list(
            "rowIndex" = 10-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 10-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 10-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 10-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 10-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 10-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 10-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 10-1,
            "colIndex" = 23
          )
        )
      ),
      "language" = list(
        "English Only" = list(
          "1" = list(
            "rowIndex" = 148-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 148-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 148-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 148-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 148-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 148-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 148-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 148-1,
            "colIndex" = 23
          )
        ),
        "Language Other Than English" = list(
          "1" = list(
            "rowIndex" = 149-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 149-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 149-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 149-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 149-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 149-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 149-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 149-1,
            "colIndex" = 23
          )
        )
      ),
      "medianAge" = list(
        "1" = list(
          "rowIndex" = 21-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 21-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 21-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 21-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 21-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 21-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 21-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 21-1,
          "colIndex" = 23
        )
      ),
      "medianHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 24-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 24-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 24-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 24-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 24-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 24-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 24-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 24-1,
          "colIndex" = 23
        )
      ),
      "population" = list(
        "1" = list(
          "rowIndex" = 7-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 7-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 7-1,
          "colIndex" = 8
        ),
        "4" = list(
          "rowIndex" = 7-1,
          "colIndex" = 11
        ),
        "5" = list(
          "rowIndex" = 7-1,
          "colIndex" = 14
        ),
        "6" = list(
          "rowIndex" = 7-1,
          "colIndex" = 17
        ),
        "7" = list(
          "rowIndex" = 7-1,
          "colIndex" = 20
        ),
        "8" = list(
          "rowIndex" = 7-1,
          "colIndex" = 23
        )
      ),
      "race" = list(
        "White" = list(
          "1" = list(
            "rowIndex" = 43-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 43-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 43-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 43-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 43-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 43-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 43-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 43-1,
            "colIndex" = 23
          )
        ),
        "Black" = list(
          "1" = list(
            "rowIndex" = 44-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 44-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 44-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 44-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 44-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 44-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 44-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 44-1,
            "colIndex" = 23
          )
        ),
        "Native American" = list(
          "1" = list(
            "rowIndex" = 45-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 45-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 45-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 45-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 45-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 45-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 45-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 45-1,
            "colIndex" = 23
          )
        ),
        "Asian or Pacific Islander" = list(
          "1" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = c(46,47)-1,
            "colIndex" = 23
          )
        ),
        "Other Individual Race" = list(
          "1" = list(
            "rowIndex" = 48-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 48-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 48-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 48-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 48-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 48-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 48-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 48-1,
            "colIndex" = 23
          )
        ),
        "Two or More Races" = list(
          "1" = list(
            "rowIndex" = 49-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 49-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 49-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 49-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 49-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 49-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 49-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 49-1,
            "colIndex" = 23
          )
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 118-1,
          "colIndex" = 2+2
        ),
        "2" = list(
          "rowIndex" = 118-1,
          "colIndex" = 5+2
        ),
        "3" = list(
          "rowIndex" = 118-1,
          "colIndex" = 8+2
        ),
        "4" = list(
          "rowIndex" = 118-1,
          "colIndex" = 11+2
        ),
        "5" = list(
          "rowIndex" = 118-1,
          "colIndex" = 14+2
        ),
        "6" = list(
          "rowIndex" = 118-1,
          "colIndex" = 17+2
        ),
        "7" = list(
          "rowIndex" = 118-1,
          "colIndex" = 20+2
        ),
        "8" = list(
          "rowIndex" = 118-1,
          "colIndex" = 23+2
        )
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "1" = list(
            "rowIndex" = 60-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 60-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 60-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 60-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 60-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 60-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 60-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 60-1,
            "colIndex" = 23
          )
        ),
        "1 vehicle" = list(
          "1" = list(
            "rowIndex" = 61-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 61-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 61-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 61-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 61-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 61-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 61-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 61-1,
            "colIndex" = 23
          )
        ),
        "2 vehicles" = list(
          "1" = list(
            "rowIndex" = 62-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 62-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 62-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 62-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 62-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 62-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 62-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 62-1,
            "colIndex" = 23
          )
        ),
        "3 or more vehicles" = list(
          "1" = list(
            "rowIndex" = 63-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 63-1,
            "colIndex" = 5
          ),
          "3" = list(
            "rowIndex" = 63-1,
            "colIndex" = 8
          ),
          "4" = list(
            "rowIndex" = 63-1,
            "colIndex" = 11
          ),
          "5" = list(
            "rowIndex" = 63-1,
            "colIndex" = 14
          ),
          "6" = list(
            "rowIndex" = 63-1,
            "colIndex" = 17
          ),
          "7" = list(
            "rowIndex" = 63-1,
            "colIndex" = 20
          ),
          "8" = list(
            "rowIndex" = 63-1,
            "colIndex" = 23
          )
        )
      )
    ),
    "2017" = list(
      "belowPovertyLevel" = list(
        "1" = list(
          "rowIndex" = 161-1,
          "colIndex" = 3
        ),
        "2" = list(
          "rowIndex" = 161-1,
          "colIndex" = 5
        ),
        "3" = list(
          "rowIndex" = 161-1,
          "colIndex" = 7
        ),
        "4" = list(
          "rowIndex" = 161-1,
          "colIndex" = 9
        ),
        "5" = list(
          "rowIndex" = 161-1,
          "colIndex" = 11
        ),
        "6" = list(
          "rowIndex" = 161-1,
          "colIndex" = 13
        ),
        "7" = list(
          "rowIndex" = 161-1,
          "colIndex" = 15
        ),
        "8" = list(
          "rowIndex" = 161-1,
          "colIndex" = 17
        )
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 16
          )
        ),
        "Some High School" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 16
          )
        ),
        "High school graduate" = list(
          "1" = list(
            "rowIndex" = 83-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 83-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 83-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 83-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 83-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 83-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 83-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 83-1,
            "colIndex" = 16
          )
        ),
        "Some College" = list(
          "1" = list(
            "rowIndex" = 84-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 84-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 84-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 84-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 84-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 84-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 84-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 84-1,
            "colIndex" = 16
          )
        ),
        "Associate's Degree" = list(
          "1" = list(
            "rowIndex" = 85-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 85-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 85-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 85-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 85-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 85-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 85-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 85-1,
            "colIndex" = 16
          )
        ),
        "Bachelor's Degree" = list(
          "1" = list(
            "rowIndex" = 86-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 86-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 86-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 86-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 86-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 86-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 86-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 86-1,
            "colIndex" = 16
          )
        ),
        "Advanced Degree" = list(
          "1" = list(
            "rowIndex" = 87-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 87-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 87-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 87-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 87-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 87-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 87-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 87-1,
            "colIndex" = 16
          )
        )
      ),
      "employment" = list(
        "Employed" = list(
          "1" = list(
            "rowIndex" = 9-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 9-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 9-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 9-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 9-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 9-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 9-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 9-1,
            "colIndex" = 16
          )
        ),
        "Unemployed" = list(
          "1" = list(
            "rowIndex" = 10-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 10-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 10-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 10-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 10-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 10-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 10-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 10-1,
            "colIndex" = 16
          )
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 88-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 88-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 88-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 88-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 88-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 88-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 88-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 88-1,
            "colIndex" = 16
          )
        ),
        "Not Hispanic or Latino" = list(
          "1" = list(
            "rowIndex" = 93-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 93-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 93-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 93-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 93-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 93-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 93-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 93-1,
            "colIndex" = 16
          )
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "1" = list(
            "rowIndex" = 121-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 121-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 121-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 121-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 121-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 121-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 121-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 121-1,
            "colIndex" = 16
          )
        ),
        "Foreign-Born" = list(
          "1" = list(
            "rowIndex" = 126-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 126-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 126-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 126-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 126-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 126-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 126-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 126-1,
            "colIndex" = 16
          )
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "1" = list(
            "rowIndex" = 125-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 125-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 125-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 125-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 125-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 125-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 125-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 125-1,
            "colIndex" = 16
          )
        ),
        "Public Health Insurance" = list(
          "1" = list(
            "rowIndex" = 126-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 126-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 126-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 126-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 126-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 126-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 126-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 126-1,
            "colIndex" = 16
          )
        ),
        "Uninsured" = list(
          "1" = list(
            "rowIndex" = 127-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 127-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 127-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 127-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 127-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 127-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 127-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 127-1,
            "colIndex" = 16
          )
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "1" = list(
            "rowIndex" = 62-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 62-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 62-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 62-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 62-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 62-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 62-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 62-1,
            "colIndex" = 16
          )
        ),
        "Renter-occupied" = list(
          "1" = list(
            "rowIndex" = 63-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 63-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 63-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 63-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 63-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 63-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 63-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 63-1,
            "colIndex" = 16
          )
        )
      ),
      "language" = list(
        "English Only" = list(
          "1" = list(
            "rowIndex" = 155-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 155-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 155-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 155-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 155-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 155-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 155-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 155-1,
            "colIndex" = 16
          )
        ),
        "Language Other Than English" = list(
          "1" = list(
            "rowIndex" = 156-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 156-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 156-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 156-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 156-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 156-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 156-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 156-1,
            "colIndex" = 16
          )
        )
      ),
      "medianAge" = list(
        "1" = list(
          "rowIndex" = 25-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 25-1,
          "colIndex" = 4
        ),
        "3" = list(
          "rowIndex" = 25-1,
          "colIndex" = 6
        ),
        "4" = list(
          "rowIndex" = 25-1,
          "colIndex" = 8
        ),
        "5" = list(
          "rowIndex" = 25-1,
          "colIndex" = 10
        ),
        "6" = list(
          "rowIndex" = 25-1,
          "colIndex" = 12
        ),
        "7" = list(
          "rowIndex" = 25-1,
          "colIndex" = 14
        ),
        "8" = list(
          "rowIndex" = 25-1,
          "colIndex" = 16
        )
      ),
      "medianHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 82-1,
          "colIndex" = 4
        ),
        "3" = list(
          "rowIndex" = 82-1,
          "colIndex" = 6
        ),
        "4" = list(
          "rowIndex" = 82-1,
          "colIndex" = 8
        ),
        "5" = list(
          "rowIndex" = 82-1,
          "colIndex" = 10
        ),
        "6" = list(
          "rowIndex" = 82-1,
          "colIndex" = 12
        ),
        "7" = list(
          "rowIndex" = 82-1,
          "colIndex" = 14
        ),
        "8" = list(
          "rowIndex" = 82-1,
          "colIndex" = 16
        )
      ),
      "population" = list(
        "1" = list(
          "rowIndex" = 6-1,
          "colIndex" = 2
        ),
        "2" = list(
          "rowIndex" = 6-1,
          "colIndex" = 4
        ),
        "3" = list(
          "rowIndex" = 6-1,
          "colIndex" = 6
        ),
        "4" = list(
          "rowIndex" = 6-1,
          "colIndex" = 8
        ),
        "5" = list(
          "rowIndex" = 6-1,
          "colIndex" = 10
        ),
        "6" = list(
          "rowIndex" = 6-1,
          "colIndex" = 12
        ),
        "7" = list(
          "rowIndex" = 6-1,
          "colIndex" = 14
        ),
        "8" = list(
          "rowIndex" = 6-1,
          "colIndex" = 16
        )
      ),
      "race" = list(
        "White" = list(
          "1" = list(
            "rowIndex" = 50-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 50-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 50-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 50-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 50-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 50-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 50-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 50-1,
            "colIndex" = 16
          )
        ),
        "Black" = list(
          "1" = list(
            "rowIndex" = 51-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 51-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 51-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 51-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 51-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 51-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 51-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 51-1,
            "colIndex" = 16
          )
        ),
        "Native American" = list(
          "1" = list(
            "rowIndex" = 52-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 52-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 52-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 52-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 52-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 52-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 52-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 52-1,
            "colIndex" = 16
          )
        ),
        "Asian or Pacific Islander" = list(
          "1" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = c(57,65)-1,
            "colIndex" = 16
          )
        ),
        "Other Individual Race" = list(
          "1" = list(
            "rowIndex" = 70-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 70-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 70-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 70-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 70-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 70-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 70-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 70-1,
            "colIndex" = 16
          )
        ),
        "Two or More Races" = list(
          "1" = list(
            "rowIndex" = 71-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 71-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 71-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 71-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 71-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 71-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 71-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 71-1,
            "colIndex" = 16
          )
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "1" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 2+1
        ),
        "2" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 4+1
        ),
        "3" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 6+1
        ),
        "4" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 8+1
        ),
        "5" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 10+1
        ),
        "6" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 12+1
        ),
        "7" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 14+1
        ),
        "8" = list(
          "rowIndex" = c(185,186)-1,
          "colIndex" = 16+1
        )
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "1" = list(
            "rowIndex" = 79-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 79-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 79-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 79-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 79-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 79-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 79-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 79-1,
            "colIndex" = 16
          )
        ),
        "1 vehicle" = list(
          "1" = list(
            "rowIndex" = 80-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 80-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 80-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 80-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 80-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 80-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 80-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 80-1,
            "colIndex" = 16
          )
        ),
        "2 vehicles" = list(
          "1" = list(
            "rowIndex" = 81-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 81-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 81-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 81-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 81-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 81-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 81-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 81-1,
            "colIndex" = 16
          )
        ),
        "3 or more vehicles" = list(
          "1" = list(
            "rowIndex" = 82-1,
            "colIndex" = 2
          ),
          "2" = list(
            "rowIndex" = 82-1,
            "colIndex" = 4
          ),
          "3" = list(
            "rowIndex" = 82-1,
            "colIndex" = 6
          ),
          "4" = list(
            "rowIndex" = 82-1,
            "colIndex" = 8
          ),
          "5" = list(
            "rowIndex" = 82-1,
            "colIndex" = 10
          ),
          "6" = list(
            "rowIndex" = 82-1,
            "colIndex" = 12
          ),
          "7" = list(
            "rowIndex" = 82-1,
            "colIndex" = 14
          ),
          "8" = list(
            "rowIndex" = 82-1,
            "colIndex" = 16
          )
        )
      )
    )
  ),
  "dc" = list(
    "2013" = list(
      "belowPovertyLevel" = list(
        "rowIndex" = 62-1,
        "colIndex" = 4
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Some High School" = list(
          "rowIndex" = 85-1,
          "colIndex" = 2
        ),
        "High school graduate" = list(
          "rowIndex" = 86-1,
          "colIndex" = 2
        ),
        "Some College" = list(
          "rowIndex" = 87-1,
          "colIndex" = 2
        ),
        "Associate's Degree" = list(
          "rowIndex" = 88-1,
          "colIndex" = 2
        ),
        "Bachelor's Degree" = list(
          "rowIndex" = 89-1,
          "colIndex" = 2
        ),
        "Advanced Degree" = list(
          "rowIndex" = 90-1,
          "colIndex" = 2
        )
      ),
      "employment" = list(
        "Employed" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        ),
        "Unemployed" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "rowIndex" = 60-1,
          "colIndex" = 2
        ),
        "Not Hispanic or Latino" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "rowIndex" = 120-1,
          "colIndex" = 2
        ),
        "Foreign-Born" = list(
          "rowIndex" = 125-1,
          "colIndex" = 2
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "rowIndex" = 10-1,
          "colIndex" = 2
        ),
        "Renter-occupied" = list(
          "rowIndex" = 11-1,
          "colIndex" = 2
        )
      ),
      "language" = list(
        "English Only" = list(
          "rowIndex" = 149-1,
          "colIndex" = 2
        ),
        "Language Other Than English" = list(
          "rowIndex" = 150-1,
          "colIndex" = 2
        )
      ),
      "medianAge" = list(
        "rowIndex" = 22-1,
        "colIndex" = 2
      ),
      "medianHouseholdIncome" = list(
        "rowIndex" = 25-1,
        "colIndex" = 2
      ),
      "population" = list(
        "rowIndex" = 8-1,
        "colIndex" = 2
      ),
      "race" = list(
        "White" = list(
          "rowIndex" = 44-1,
          "colIndex" = 2
        ),
        "Black" = list(
          "rowIndex" = 45-1,
          "colIndex" = 2
        ),
        "Native American" = list(
          "rowIndex" = 46-1,
          "colIndex" = 2
        ),
        "Asian or Pacific Islander" = list(
          "rowIndex" = c(47,48)-1,
          "colIndex" = 2
        ),
        "Other Individual Race" = list(
          "rowIndex" = 49-1,
          "colIndex" = 2
        ),
        "Two or More Races" = list(
          "rowIndex" = 50-1,
          "colIndex" = 2
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "rowIndex" = 119-1,
        "colIndex" = 2+2
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "rowIndex" = 62-1,
          "colIndex" = 2
        ),
        "1 vehicle" = list(
          "rowIndex" = 63-1,
          "colIndex" = 2
        ),
        "2 vehicles" = list(
          "rowIndex" = 64-1,
          "colIndex" = 2
        ),
        "3 or more vehicles" = list(
          "rowIndex" = 65-1,
          "colIndex" = 2
        )
      )
    ),
    "2014" = list(
      "belowPovertyLevel" = list(
        "rowIndex" = 162-1,
        "colIndex" = 4
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        ),
        "Some High School" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "High school graduate" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Some College" = list(
          "rowIndex" = 85-1,
          "colIndex" = 2
        ),
        "Associate's Degree" = list(
          "rowIndex" = 86-1,
          "colIndex" = 2
        ),
        "Bachelor's Degree" = list(
          "rowIndex" = 87-1,
          "colIndex" = 2
        ),
        "Advanced Degree" = list(
          "rowIndex" = 88-1,
          "colIndex" = 2
        )
      ),
      "employment" = list(
        "Employed" = list(
          "rowIndex" = 10-1,
          "colIndex" = 2
        ),
        "Unemployed" = list(
          "rowIndex" = 11-1,
          "colIndex" = 2
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Not Hispanic or Latino" = list(
          "rowIndex" = 89-1,
          "colIndex" = 2
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "rowIndex" = 122-1,
          "colIndex" = 2
        ),
        "Foreign-Born" = list(
          "rowIndex" = 127-1,
          "colIndex" = 2
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "rowIndex" = 125-1,
          "colIndex" = 2
        ),
        "Public Health Insurance" = list(
          "rowIndex" = 126-1,
          "colIndex" = 2
        ),
        "Uninsured" = list(
          "rowIndex" = 127-1,
          "colIndex" = 2
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "rowIndex" = 8-1,
          "colIndex" = 2
        ),
        "Renter-occupied" = list(
          "rowIndex" = 9-1,
          "colIndex" = 2
        )
      ),
      "language" = list(
        "English Only" = list(
          "rowIndex" = 156-1,
          "colIndex" = 2
        ),
        "Language Other Than English" = list(
          "rowIndex" = 157-1,
          "colIndex" = 2
        )
      ),
      "medianAge" = list(
        "rowIndex" = 25-1,
        "colIndex" = 2
      ),
      "medianHouseholdIncome" = list(
        "rowIndex" = 83-1,
        "colIndex" = 2
      ),
      "population" = list(
        "rowIndex" = 7-1,
        "colIndex" = 2
      ),
      "race" = list(
        "White" = list(
          "rowIndex" = 46-1,
          "colIndex" = 2
        ),
        "Black" = list(
          "rowIndex" = 47-1,
          "colIndex" = 2
        ),
        "Native American" = list(
          "rowIndex" = 48-1,
          "colIndex" = 2
        ),
        "Asian or Pacific Islander" = list(
          "rowIndex" = c(53,61)-1,
          "colIndex" = 2
        ),
        "Other Individual Race" = list(
          "rowIndex" = 66-1,
          "colIndex" = 2
        ),
        "Two or More Races" = list(
          "rowIndex" = 67-1,
          "colIndex" = 2
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "rowIndex" = c(184,185)-1,
        "colIndex" = 2+2
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "rowIndex" = 79-1,
          "colIndex" = 2
        ),
        "1 vehicle" = list(
          "rowIndex" = 80-1,
          "colIndex" = 2
        ),
        "2 vehicles" = list(
          "rowIndex" = 81-1,
          "colIndex" = 2
        ),
        "3 or more vehicles" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        )
      )
    ),
    "2015" = list(
      "belowPovertyLevel" = list(
        "rowIndex" = 161-1,
        "colIndex" = 4
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "rowIndex" = 81-1,
          "colIndex" = 2
        ),
        "Some High School" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        ),
        "High school graduate" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "Some College" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Associate's Degree" = list(
          "rowIndex" = 85-1,
          "colIndex" = 2
        ),
        "Bachelor's Degree" = list(
          "rowIndex" = 86-1,
          "colIndex" = 2
        ),
        "Advanced Degree" = list(
          "rowIndex" = 87-1,
          "colIndex" = 2
        )
      ),
      "employment" = list(
        "Employed" = list(
          "rowIndex" = 9-1,
          "colIndex" = 2
        ),
        "Unemployed" = list(
          "rowIndex" = 10-1,
          "colIndex" = 2
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "Not Hispanic or Latino" = list(
          "rowIndex" = 88-1,
          "colIndex" = 2
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "rowIndex" = 121-1,
          "colIndex" = 2
        ),
        "Foreign-Born" = list(
          "rowIndex" = 126-1,
          "colIndex" = 2
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "rowIndex" = 125-1,
          "colIndex" = 2
        ),
        "Public Health Insurance" = list(
          "rowIndex" = 126-1,
          "colIndex" = 2
        ),
        "Uninsured" = list(
          "rowIndex" = 127-1,
          "colIndex" = 2
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "rowIndex" = 62-1,
          "colIndex" = 2
        ),
        "Renter-occupied" = list(
          "rowIndex" = 63-1,
          "colIndex" = 2
        )
      ),
      "language" = list(
        "English Only" = list(
          "rowIndex" = 155-1,
          "colIndex" = 2
        ),
        "Language Other Than English" = list(
          "rowIndex" = 156-1,
          "colIndex" = 2
        )
      ),
      "medianAge" = list(
        "rowIndex" = 24-1,
        "colIndex" = 2
      ),
      "medianHouseholdIncome" = list(
        "rowIndex" = 82-1,
        "colIndex" = 2
      ),
      "population" = list(
        "rowIndex" = 6-1,
        "colIndex" = 2
      ),
      "race" = list(
        "White" = list(
          "rowIndex" = 45-1,
          "colIndex" = 2
        ),
        "Black" = list(
          "rowIndex" = 46-1,
          "colIndex" = 2
        ),
        "Native American" = list(
          "rowIndex" = 47-1,
          "colIndex" = 2
        ),
        "Asian or Pacific Islander" = list(
          "rowIndex" = c(52,60)-1,
          "colIndex" = 2
        ),
        "Other Individual Race" = list(
          "rowIndex" = 65-1,
          "colIndex" = 2
        ),
        "Two or More Races" = list(
          "rowIndex" = 66-1,
          "colIndex" = 2
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "rowIndex" = c(185,186)-1,
        "colIndex" = 2+2
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "rowIndex" = 79-1,
          "colIndex" = 2
        ),
        "1 vehicle" = list(
          "rowIndex" = 80-1,
          "colIndex" = 2
        ),
        "2 vehicles" = list(
          "rowIndex" = 81-1,
          "colIndex" = 2
        ),
        "3 or more vehicles" = list(
          "rowIndex" = 82-1,
          "colIndex" = 2
        )
      )
    ),
    "2016" = list(
      "belowPovertyLevel" = list(
        "rowIndex" = 62-1,
        "colIndex" = 4
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Some High School" = list(
          "rowIndex" = 85-1,
          "colIndex" = 2
        ),
        "High school graduate" = list(
          "rowIndex" = 86-1,
          "colIndex" = 2
        ),
        "Some College" = list(
          "rowIndex" = 87-1,
          "colIndex" = 2
        ),
        "Associate's Degree" = list(
          "rowIndex" = 88-1,
          "colIndex" = 2
        ),
        "Bachelor's Degree" = list(
          "rowIndex" = 89-1,
          "colIndex" = 2
        ),
        "Advanced Degree" = list(
          "rowIndex" = 90-1,
          "colIndex" = 2
        )
      ),
      "employment" = list(
        "Employed" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "Unemployed" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "rowIndex" = 60-1,
          "colIndex" = 2
        ),
        "Not Hispanic or Latino" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "rowIndex" = 60-1,
          "colIndex" = 2
        ),
        "Foreign-Born" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "rowIndex" = 146-1,
          "colIndex" = 2
        ),
        "Public Health Insurance" = list(
          "rowIndex" = 145-1,
          "colIndex" = 2
        ),
        "Uninsured" = list(
          "rowIndex" = 144-1,
          "colIndex" = 2
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "rowIndex" = 10-1,
          "colIndex" = 2
        ),
        "Renter-occupied" = list(
          "rowIndex" = 11-1,
          "colIndex" = 2
        )
      ),
      "language" = list(
        "English Only" = list(
          "rowIndex" = 149-1,
          "colIndex" = 2
        ),
        "Language Other Than English" = list(
          "rowIndex" = 150-1,
          "colIndex" = 2
        )
      ),
      "medianAge" = list(
        "rowIndex" = 22-1,
        "colIndex" = 2
      ),
      "medianHouseholdIncome" = list(
        "rowIndex" = 25-1,
        "colIndex" = 2
      ),
      "population" = list(
        "rowIndex" = 8-1,
        "colIndex" = 2
      ),
      "race" = list(
        "White" = list(
          "rowIndex" = 44-1,
          "colIndex" = 2
        ),
        "Black" = list(
          "rowIndex" = 45-1,
          "colIndex" = 2
        ),
        "Native American" = list(
          "rowIndex" = 46-1,
          "colIndex" = 2
        ),
        "Asian or Pacific Islander" = list(
          "rowIndex" = c(47,48)-1,
          "colIndex" = 2
        ),
        "Other Individual Race" = list(
          "rowIndex" = 49-1,
          "colIndex" = 2
        ),
        "Two or More Races" = list(
          "rowIndex" = 50-1,
          "colIndex" = 2
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "rowIndex" = 119-1,
        "colIndex" = 2+2
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        ),
        "1 vehicle" = list(
          "rowIndex" = 62-1,
          "colIndex" = 2
        ),
        "2 vehicles" = list(
          "rowIndex" = 63-1,
          "colIndex" = 2
        ),
        "3 or more vehicles" = list(
          "rowIndex" = 64-1,
          "colIndex" = 2
        )
      )
    ),
    "2017" = list(
      "belowPovertyLevel" = list(
        "rowIndex" = 62-1,
        "colIndex" = 3
      ),
      "education" = list(
        "Less than 9th grade" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        ),
        "Some High School" = list(
          "rowIndex" = 85-1,
          "colIndex" = 2
        ),
        "High school graduate" = list(
          "rowIndex" = 86-1,
          "colIndex" = 2
        ),
        "Some College" = list(
          "rowIndex" = 87-1,
          "colIndex" = 2
        ),
        "Associate's Degree" = list(
          "rowIndex" = 88-1,
          "colIndex" = 2
        ),
        "Bachelor's Degree" = list(
          "rowIndex" = 89-1,
          "colIndex" = 2
        ),
        "Advanced Degree" = list(
          "rowIndex" = 90-1,
          "colIndex" = 2
        )
      ),
      "employment" = list(
        "Employed" = list(
          "rowIndex" = 83-1,
          "colIndex" = 2
        ),
        "Unemployed" = list(
          "rowIndex" = 84-1,
          "colIndex" = 2
        )
      ),
      "ethnicity" = list(
        "Hispanic or Latino" = list(
          "rowIndex" = 60-1,
          "colIndex" = 2
        ),
        "Not Hispanic or Latino" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        )
      ),
      "foreign-born" = list(
        "Native" = list(
          "rowIndex" = 120-1,
          "colIndex" = 2
        ),
        "Foreign-Born" = list(
          "rowIndex" = 125-1,
          "colIndex" = 2
        )
      ),
      "healthInsuranceCoverage" = list(
        "Private Health Insurance" = list(
          "rowIndex" = 146-1,
          "colIndex" = 2
        ),
        "Public Health Insurance" = list(
          "rowIndex" = 145-1,
          "colIndex" = 2
        ),
        "Uninsured" = list(
          "rowIndex" = 144-1,
          "colIndex" = 2
        )
      ),
      "housingTenure" = list(
        "Owner-occupied" = list(
          "rowIndex" = 10-1,
          "colIndex" = 2
        ),
        "Renter-occupied" = list(
          "rowIndex" = 11-1,
          "colIndex" = 2
        )
      ),
      "language" = list(
        "English Only" = list(
          "rowIndex" = 149-1,
          "colIndex" = 2
        ),
        "Language Other Than English" = list(
          "rowIndex" = 150-1,
          "colIndex" = 2
        )
      ),
      "medianAge" = list(
        "rowIndex" = 22-1,
        "colIndex" = 2
      ),
      "medianHouseholdIncome" = list(
        "rowIndex" = 25-1,
        "colIndex" = 2
      ),
      "population" = list(
        "rowIndex" = 8-1,
        "colIndex" = 2
      ),
      "race" = list(
        "White" = list(
          "rowIndex" = 44-1,
          "colIndex" = 2
        ),
        "Black" = list(
          "rowIndex" = 45-1,
          "colIndex" = 2
        ),
        "Native American" = list(
          "rowIndex" = 46-1,
          "colIndex" = 2
        ),
        "Asian or Pacific Islander" = list(
          "rowIndex" = c(47,48)-1,
          "colIndex" = 2
        ),
        "Other Individual Race" = list(
          "rowIndex" = 49-1,
          "colIndex" = 2
        ),
        "Two or More Races" = list(
          "rowIndex" = 50-1,
          "colIndex" = 2
        )
      ),
      "rentGreaterThan30PercentOfHouseholdIncome" = list(
        "rowIndex" = 119-1,
        "colIndex" = 2+1
      ),
      "vehiclesPerHousingUnit" = list(
        "No vehicles" = list(
          "rowIndex" = 61-1,
          "colIndex" = 2
        ),
        "1 vehicle" = list(
          "rowIndex" = 62-1,
          "colIndex" = 2
        ),
        "2 vehicles" = list(
          "rowIndex" = 63-1,
          "colIndex" = 2
        ),
        "3 or more vehicles" = list(
          "rowIndex" = 64-1,
          "colIndex" = 2
        )
      )
    )
  )
)

#####

# populating ward and dc counts from files
#####
setwd("American Community Survey")

for(i in 1:numberOfRows) {
  if(any(
    ! finalDataFrame$region[i] %in% c(1:8, 11001),
    finalDataFrame$variable[i] %in% c("airQualityIndex")
  )) {
    NULL
  } else {
    filename = finalDataFrame$fileName[i]
    sheetname = finalDataFrame$sheetName[i]
    currentFile = read_excel(path = filename, sheet = sheetname)
    
    regionLevel = (if(finalDataFrame$region[i] == 11001) {
      "dc"
    } else {
      "ward"
    })
    year = finalDataFrame$year[i] %>% as.character()
    variable = finalDataFrame$variable[i] %>% as.character()
    category = finalDataFrame$category[i] %>% as.character()
    region = finalDataFrame$region[i] %>% as.character()
    
    if(regionLevel == "ward") {
      if(variable %in% c("belowPovertyLevel","medianAge","medianHouseholdIncome","population",
                         "rentGreaterThan30PercentOfHouseholdIncome","unemploymentRate")) {
        # these are variable that don't have categories
        rowIndex = countsToSum[[regionLevel]][[year]][[variable]][[region]][["rowIndex"]]
        colIndex = countsToSum[[regionLevel]][[year]][[variable]][[region]][["colIndex"]]
      } else {
        rowIndex = countsToSum[[regionLevel]][[year]][[variable]][[category]][[region]][["rowIndex"]]
        colIndex = countsToSum[[regionLevel]][[year]][[variable]][[category]][[region]][["colIndex"]]
      }
    } else {
      if(variable %in% c("belowPovertyLevel","medianAge","medianHouseholdIncome","population",
                         "rentGreaterThan30PercentOfHouseholdIncome","unemploymentRate")) {
        # these are variable that don't have categories
        rowIndex = countsToSum[[regionLevel]][[year]][[variable]][["rowIndex"]]
        colIndex = countsToSum[[regionLevel]][[year]][[variable]][["colIndex"]]
      } else {
        rowIndex = countsToSum[[regionLevel]][[year]][[variable]][[category]][["rowIndex"]]
        colIndex = countsToSum[[regionLevel]][[year]][[variable]][[category]][["colIndex"]]
      }
    }
    
    if(any(is.null(rowIndex), is.null(colIndex))) {
      # this can happen if the variable is unavailabe for a specific year
      # e.g. healthInsuranceCoverage is unavailable for 2013, so leave it as NA
      NULL
    } else {
      temp = currentFile[rowIndex, colIndex] %>% unlist()
      temp = gsub(pattern = "-", replacement = "0", x = temp)
      finalDataFrame$count[i] = sum(
        temp %>% as.numeric()
      )
    }
    
    # loop progress
    print(numberOfRows - i)
  }
}
#####

# populating VA/MD counties and independent cities from Census Bureau API
#####
stateCountyCodes = list(
  # Charles County
  "24017" = list(
    "state" = "24",
    "county" = "017"
  ),
  # Montgomery County
  "24031" = list(
    "state" = "24",
    "county" = "031"
  ),
  # Prince George's County
  "24033" = list(
    "state" = "24",
    "county" = "033"
  ),
  # Arlington County
  "51013" = list(
    "state" = "51",
    "county" = "013"
  ),
  # Fairfax County
  "51059" = list(
    "state" = "51",
    "county" = "059"
  ),
  # Loudoun County
  "51107" = list(
    "state" = "51",
    "county" = "107"
  ),
  # Prince William County
  "51153" = list(
    "state" = "51",
    "county" = "153"
  ),
  # Alexandria
  "51510" = list(
    "state" = "51",
    "county" = "510"
  ),
  # Fairfax
  "51600" = list(
    "state" = "51",
    "county" = "600"
  ),
  # Falls Church
  "51610" = list(
    "state" = "51",
    "county" = "610"
  ),
  # Manassas
  "51683" = list(
    "state" = "51",
    "county" = "683"
  ),
  # Manassas Park
  "51685" = list(
    "state" = "51",
    "county" = "685"
  )
)

variableCodes = list(
  "belowPovertyLevel" = "DP03_0128PE",
  "education" = list(
    "Less than 9th grade" = "DP02_0059E",
    "Some High School" = "DP02_0060E",
    "High school graduate" = "DP02_0061E",
    "Some College" = "DP02_0062E",
    "Associate's Degree" = "DP02_0063E",
    "Bachelor's Degree" = "DP02_0064E",
    "Advanced Degree" = "DP02_0065E"
  ),
  "employment" = list(
    "Employed" = "DP03_0004E",
    "Unemployed" = "DP03_0005E"
  ),
  "ethnicity" = list( # use 1st value for before 2017, 2nd value for 2017
    "Hispanic or Latino" = c("DP05_0066E", "DP05_0071E"),
    "Not Hispanic or Latino" = c("DP05_0071E", "DP05_0076E")
  ),
  "foreign-born" = list(
    "Native" = "DP02_0087E",
    "Foreign-Born" = "DP02_0092E"
  ),
  "healthInsuranceCoverage" = list(
    "Private Health Insurance" = "DP03_0097E",
    "Public Health Insurance" = "DP03_0098E",
    "Uninsured" = "DP03_0099E"
  ),
  "housingTenure" = list(
    # use 1st value for 2013-2014, use 2nd value for after
    "Owner-occupied" = c("DP04_0045E", "DP04_0046E"),
    "Renter-occupied" = c("DP04_0046E", "DP04_0047E")
  ),
  "language" = list(
    "English Only" = "DP02_0111E",
    "Language Other Than English" = "DP02_0112E"
  ),
  "medianAge" = c("DP05_0017E", "DP05_0018E"), # use 1st value for before 2017, 2nd value for 2017
  "medianHouseholdIncome" = "DP03_0062E",
  "population" = "DP05_0001E",
  "race" = list( # use 1st value for before 2017, 2nd value for 2017
    "White" = c("DP05_0032E", "DP05_0037E"),
    "Black"  = c("DP05_0033E", "DP05_0038E"),
    "Native American" = c("DP05_0034E", "DP05_0039E"),
    "Asian or Pacific Islander" = c("DP05_0039E,DP05_0047E", "DP05_0044E,DP05_0052E"),
    "Other Individual Race" = c("DP05_0052E", "DP05_0057E"),
    "Two or More Races" = c("DP05_0053E", "DP05_0058E")
  ),
  "rentGreaterThan30PercentOfHouseholdIncome" = c(
    # use 1st value for 2013-2014, 2nd value for after
    "DP04_0139PE,DP04_0140PE","DP04_0141PE,DP04_0142PE"),
  "vehiclesPerHousingUnit" = list(
    "No vehicles" = "DP04_0058E",
    "1 vehicle" = "DP04_0059E",
    "2 vehicles" = "DP04_0060E",
    "3 or more vehicles" = "DP04_0061E"
  )
)

apiKey = "6ab3340c16d514e7094fbdeff066406455377bea"

for(i in 1:numberOfRows) {
  if(any(
    finalDataFrame$region[i] %in% c(0:8,11001),
    finalDataFrame$variable[i] %in% c("airQualityIndex")
  )) {
    NULL
  } else {
    year = finalDataFrame$year[i] %>% as.character()
    variable = finalDataFrame$variable[i] %>% as.character()
    category = finalDataFrame$category[i] %>% as.character()
    region = finalDataFrame$region[i] %>% as.character()
    
    variableCode = (
      if(is.na(category)) {
        variableCodes[[variable]]
      } else {
        variableCodes[[variable]][[category]]
      }
    )
    
    # corrections for the Census Bureau making endpoint changes between years
    if(variable %in% c("housingTenure","rentGreaterThan30PercentOfHouseholdIncome")) {
      if(year <= 2014) {
        variableCode = variableCode[1]
      } else {
        variableCode = variableCode[2]
      }
    }
    if(variable %in% c("ethnicity","medianAge","race")) {
      if(year <= 2016) {
        variableCode = variableCode[1]
      } else {
        variableCode = variableCode[2]
      }
    }
    
    countyCode = stateCountyCodes[[region]][["county"]]
    stateCode = stateCountyCodes[[region]][["state"]]

    # ACS 5-Year Data Profiles    
    apiFullUrl = paste0("https://api.census.gov/data/", year, "/acs/acs5/profile?get=", variableCode,
                        "&for=county:", countyCode, "&in=state:", stateCode, "&key=", apiKey)
    formattedResponse = GET(url = apiFullUrl) %>% content("text") %>% fromJSON(flatten = TRUE)
    
    # the formatted response is always a matrix where we don't want the 1st row and the last 2 columns
    responseWidth = dim(formattedResponse)[2]
    finalDataFrame$count[i] = formattedResponse[-1,-c(responseWidth-1,responseWidth)] %>% as.numeric() %>% sum()
    
    # loop progress
    print(numberOfRows - i)
  }
}

# this data frame should be empty if everything is fine so far
# finalDataFrame %>%
#   filter(is.na(count), variable != "airQualityIndex", region != 0) %>%
#   filter(!all(variable == "healthInsuranceCoverage", year == 2013, region %in% 1:8))
#####

# populating VA/MD counties and DC air quality index values from files
#####
setwd("../EPA")

lookupStateAndCountyByRegionNumber = list(
  "11001" = list(
    "State" = "District Of Columbia",
    "County" = "District of Columbia"
  ),
  "24017" = list(
    "State" = "Maryland",
    "County" = "Charles"
  ),
  "24031" = list(
    "State" = "Maryland",
    "County" = "Montgomery"
  ),
  "24033" = list(
    "State" = "Maryland",
    "County" = "Prince George's"
  ),
  "51013" = list(
    "State" = "Virginia",
    "County" = "Arlington"
  ),
  "51059" = list(
    "State" = "Virginia",
    "County" = "Fairfax"
  ),
  "51107" = list(
    "State" = "Virginia",
    "County" = "Loudoun"
  ),
  "51153" = list(
    "State" = "Virginia",
    "County" = "Prince William"
  )
)

for(i in 1:numberOfRows) {
  variableFilter = finalDataFrame$variable[i]
  regionFilter = finalDataFrame$region[i] %>% as.character()
  
  if(any(
    variableFilter != "airQualityIndex",
    ! regionFilter %in% names(lookupStateAndCountyByRegionNumber)
  )) {
    NULL
  } else {
    yearFilter = finalDataFrame$year[i]
    stateFilter = lookupStateAndCountyByRegionNumber[[regionFilter]][["State"]]
    countyFilter = lookupStateAndCountyByRegionNumber[[regionFilter]][["County"]]
    
    fileToRead = paste0("annual_aqi_by_county_", yearFilter, ".csv")
    readData = read.csv(file = fileToRead)
    x = readData %>%
      filter(State == stateFilter, County == countyFilter) %>%
      select(Median.AQI)
  
    finalDataFrame$count[i] = x[[1]]
    
    print(numberOfRows - i)
  }
}
#####

# calculating GWCC Catchment Area values (region 0)
#####
# sum counties, independent cities, and wards
for(i in 1:numberOfRows) {
  if(any(
    finalDataFrame$region[i] != 0,
    finalDataFrame$variable[i] %in% c("airQualityIndex","belowPovertyLevel","medianAge","medianHouseholdIncome",
                                      "rentGreaterThan30PercentOfHouseholdIncome") # skip variables that can't be summed
  )) {
    NULL
  } else {
    variableFilter = finalDataFrame$variable[i] %>% as.character()
    yearFilter = finalDataFrame$year[i]
    categoryFilter = finalDataFrame$category[i] %>% as.character()
    
    finalDataFrame$count[i] = if(variableFilter %in% c("population")) {
      # these are variables without categories that can still be summed
      finalDataFrame %>%
        filter(variable == variableFilter, year == yearFilter, ! region %in% c(0,11001)) %>%
        select(count) %>%
        sum()
    } else {
      # these are variables that have categories
      finalDataFrame %>%
        filter(variable == variableFilter, year == yearFilter, category == categoryFilter, ! region %in% c(0,11001)) %>%
        select(count) %>%
        sum()
    }
    
    print(numberOfRows - i)
  }
}
#####

# calculating rates
#####
# 1 - for variables w/categories, divide and round
# 2 - for others, same as count
for(i in 1:numberOfRows) {
  if(finalDataFrame$variable[i] %in% c("airQualityIndex","medianAge","medianHouseholdIncome","population")) {
    finalDataFrame$rate[i] = finalDataFrame$count[i]
  } else if(finalDataFrame$variable[i] %in% c("belowPovertyLevel","rentGreaterThan30PercentOfHouseholdIncome")) {
    # variables like these that get the raw percent pulled in need corrections
    if(is.na(finalDataFrame$count[i])) {
      finalDataFrame$rate[i] = finalDataFrame$count[i] %>% round(digits = 1)
    } else if(finalDataFrame$count[i] < 0.7) {
      finalDataFrame$rate[i] = finalDataFrame$count[i] * 100 %>% round(digits = 1)
    } else if(finalDataFrame$count[i] > 100) {
      finalDataFrame$rate[i] = finalDataFrame$count[i] / 100 %>% round(digits = 1)
    } else {
      finalDataFrame$rate[i] = finalDataFrame$count[i] %>% round(digits = 1)
    }
  } else {
    variableFilter = finalDataFrame$variable[i] %>% as.character()
    yearFilter = finalDataFrame$year[i]
    regionFilter = finalDataFrame$region[i]
    categoryFilter = finalDataFrame$category[i] %>% as.character()
    
    categoryTotal = finalDataFrame %>%
      filter(variable == variableFilter, year == yearFilter, region == regionFilter) %>%
      select(count) %>%
      sum()
    individualCategory = finalDataFrame %>%
      filter(variable == variableFilter, year == yearFilter, region == regionFilter, category == categoryFilter) %>%
      select(count)
    
    finalDataFrame$rate[i] = round(individualCategory / categoryTotal * 100, 1)
  }
  
  print(numberOfRows - i)
}

finalDataFrame$rate = finalDataFrame$rate %>% unlist()
#####

# cleaning up last items
#####
# 1 - remove last 2 columns
# 2 - sort data
# 3 - write to file
finalDataFrame = finalDataFrame[,-c(7,8)] %>%
  arrange(year, region, variable)

setwd("../../")

write.csv(x = finalDataFrame, file = "masterDataFile_nonCancer_countyWard.csv", row.names = FALSE)
#####

# append data from the Robert Wood Johnson Foundation
setwd("Pre_Processing\\preProcessing_createNonCancerMasterDataFile")
source(file = "countyHealthRankings/countyHealthRankings_v5.R")

timePoint2 = proc.time()
secondsElapsed = timePoint2[["elapsed"]] - timePoint1[["elapsed"]]
minutesElapsed = secondsElapsed/60
sprintf(fmt = "Run Time: %i minutes and %i seconds", trunc(minutesElapsed), round(minutesElapsed%%1 * 60, 0))