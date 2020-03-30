library(dplyr)

setwd("C:\\Users\\derek.funk\\Documents\\MSDS\\Capstone\\Cancer_Data_Visualizer\\Data\\Raw_Data")

filetoRead = "masterDataFile_cancer_countyWard.csv"

cancerData = read.csv(file = filetoRead)

cancerTypes = unique(cancerData$cancer) %>% as.character() %>% sort()

numberOfCancerTypes = length(cancerTypes)

incidenceData = cancerData %>% filter(year == 2016, region %in% 9:16, race == "All Races", rateType == "incidenceRate")
mortalityData = cancerData %>% filter(year == 2016, region %in% 9:16, race == "All Races", rateType == "mortalityRate")

incidenceLookup = list()
for(specificCancer in cancerTypes) {
  incidenceBins = c(0,
                    incidenceData %>%
                      filter(cancer == specificCancer) %>%
                      select(rate) %>%
                      quantile(probs=c(.2,.4,.6,.8), na.rm = TRUE) %>%
                      round() %>%
                      unname(),
                    Inf
  )
  
  incidenceLookup[[specificCancer]] = incidenceBins
}

mortalityLookup = list()
for(specificCancer in cancerTypes) {
  mortalityBins = c(0,
                    mortalityData %>%
                      filter(cancer == specificCancer) %>%
                      select(rate) %>%
                      quantile(probs=c(.2,.4,.6,.8), na.rm = TRUE) %>%
                      round() %>%
                      unname(),
                    Inf
  )
  
  mortalityLookup[[specificCancer]] = mortalityBins
}
