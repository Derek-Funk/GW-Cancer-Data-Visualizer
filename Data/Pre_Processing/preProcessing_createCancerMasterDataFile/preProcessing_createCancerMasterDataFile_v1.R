# DOCUMENTATION: This file takes the 2015-2016 county cancer files from
#   https://www.cdc.gov/cancer/uscs/dataviz/download_data.htmand processes them into one tidy file.
# INSTRUCTIONS:
#   1) Download the 2016 zipped folder from the above url. Unzip it and keep just the BYAREA_COUNTY.TXT file.
#      Rename it BYAREA_COUNTY_2016.txt
#   2) Do the same thing for 2015.
#   3) Ensure BYAREA_COUNTY_2015.txt and BYAREA_COUNTY_2016.txt are in your working directory. (change line 21)
#   4) Run this script.

# takes about 9 minutes
# timePoint1 = proc.time()

# libraries
#####
library(data.table)
library(dplyr)
#####

# dataframe set  up
#####
setwd("C:\\Users\\derek.funk\\Desktop\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data")

years = 2015:2016
regions = 1:17
regionMapping = list(
  originalNames = c("VA: Arlington County (51013) - 1980+", "VA: Fairfax County (51059) - 1980+", "VA: Loudoun County (51107)",
                    "VA: Prince William County (51153) - 1982+", "MD: Charles County (24017)", "MD: Prince Georges County (24033)",
                    "MD: Montgomery County (24031)"),
  newNames = 9:15
)
cancerCategories = list(
  # names as they are in the files
  originalNames = c("All Cancer Sites Combined", "Brain and Other Nervous System","Cervix", "Colon and Rectum",
                    "Corpus and Uterus, NOS", "Esophagus", "Female Breast", "Hodgkin Lymphoma", "Kaposi Sarcoma",
                    "Kidney and Renal Pelvis", "Larynx", "Leukemias", "Liver and Intrahepatic Bile Duct",
                    "Lung and Bronchus", "Melanomas of the Skin", "Mesothelioma", "Myeloma", "Non-Hodgkin Lymphoma",
                    "Oral Cavity and Pharynx", "Ovary", "Pancreas", "Stomach", "Thyroid", "Urinary Bladder",
                    "Male Breast", "Prostate", "Testis"),
  # names we want to show
  newNames = c("All Cancers", "Brain Cancer", "Cervical Cancer", "Colorectal Cancer", "Uterine Cancer", "Esophageal Cancer",
               "Female Breast Cancer", "Hodgkin Lymphoma", "Kaposi Sarcoma", "Kidney Cancer", "Laryngeal Cancer",
               "Leukemia", "Liver Cancer", "Lung Cancer", "Melanoma", "Mesothelioma", "Myeloma",
               "Non-Hodgkin Lymphoma", "Oral Cancer", "Ovarian Cancer", "Pancreatic Cancer",
               "Stomach Cancer", "Thyroid Cancer", "Bladder Cancer", "Male Breast Cancer", "Prostate Cancer",
               "Testicular Cancer")
)
raceCategories = list(
  originalNames = c("All Races", "American Indian/Alaska Native", "Asian/Pacific Islander", "Black", "Hispanic", "White"),
  newNames = c("All Races", "Native American", "Asian", "Black", "Hispanic", "White")
)
rateCategories = list(
  originalNames = c("Incidence", "Mortality"),
  newNames = c("incidenceRate", "mortalityRate")
)

finalDataFrame = expand.grid(
  year = years,
  region = regions,
  cancer = cancerCategories$newNames,
  race = raceCategories$newNames,
  rateType = rateCategories$newNames
)

finalDataFrame$rate = NA

numberOfRows = dim(finalDataFrame)[1]
#####

# read in cancer files
#####
colNames = c("AREA", "AGE_ADJUSTED_RATE", "EVENT_TYPE", "RACE", "SEX", "SITE", "YEAR")

data_2015 = fread(file = "BYAREA_COUNTY_2015.txt", sep = "|", select = colNames)
data_2016 = fread(file = "BYAREA_COUNTY_2016.txt", sep = "|", select = colNames)

for(i in 1:numberOfRows) {
  if(!(finalDataFrame$region[i] %in% 9:15)) {
    NULL
  } else {
    cancerFilter = cancerCategories$originalNames[match(finalDataFrame$cancer[i], cancerCategories$newNames)]
    raceFilter = raceCategories$originalNames[match(finalDataFrame$race[i], raceCategories$newNames)]
    rateFilter = rateCategories$originalNames[match(finalDataFrame$rateType[i], rateCategories$newNames)]
    sexFilter = (
      if(finalDataFrame$cancer[i] == "Female Breast Cancer") {
        "Female"
      } else if(finalDataFrame$cancer[i] == "Male Breast Cancer") {
        "Male"
      } else {
        "Male and Female"
      }
    )
    regionFilter = regionMapping$originalNames[match(finalDataFrame$region[i], regionMapping$newNames)]
    
    valueToWrite = (
      if(finalDataFrame$year[i] == 2015) {
        data_2015 %>%
          filter(AREA == regionFilter, EVENT_TYPE == rateFilter, RACE == raceFilter, SEX == sexFilter,
                 SITE == cancerFilter) %>%
          select(AGE_ADJUSTED_RATE)
      } else {
        data_2016 %>%
          filter(AREA == regionFilter, EVENT_TYPE == rateFilter, RACE == raceFilter, SEX == sexFilter,
                 SITE == cancerFilter) %>%
          select(AGE_ADJUSTED_RATE)
      }
    )[[1]]
    
    valueToWrite = (
      if(valueToWrite == "~") {
        NA
      } else {
        as.numeric(valueToWrite)
      }
    )
    
    finalDataFrame$rate[i] = valueToWrite
    
    print(numberOfRows - i)
  }
}
#####

# cleaning up last items
#####
# 1 - remove last 2 columns
# 2 - sort data
# 3 - write to file
finalDataFrame = finalDataFrame %>%
  arrange(year, region, cancer, race, rateType)

write.csv(x = finalDataFrame, file = "masterDataFile_cancer_countyWard.csv", row.names = FALSE)
#####

# timePoint2 = proc.time()
# timePoint2 - timePoint1