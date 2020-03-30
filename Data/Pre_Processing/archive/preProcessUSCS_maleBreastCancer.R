library(data.table)
colNames = c("AREA", "AGE_ADJUSTED_RATE", "EVENT_TYPE", "RACE", "SEX", "SITE", "YEAR")
counties = c("VA: Arlington County (51013) - 1980+", "VA: Fairfax County (51059) - 1980+", "VA: Loudoun County (51107)",
             "VA: Prince William County (51153) - 1982+", "MD: Charles County (24017)", "MD: Prince Georges County (24033)",
             "MD: Montgomery County (24031)")
cancerCategories = list(
  originalNames = c("Male Breast"),
  newNames = c("Male Breast Cancer")
)
rateTypes = list(
  originalNames = c("Incidence", "Mortality"),
  newNames = c("incidenceRate", "mortalityRate")
)
races = list(
  originalNames = c("All Races", "American Indian/Alaska Native", "Asian/Pacific Islander", "Black", "Hispanic", "White"),
  newNames = c("All Races", "Native American", "Asian", "Black", "Hispanic", "White")
)

#below was run for each year file

x = fread(file = "BYAREA_COUNTY.txt", sep = "|", select = colNames) %>%
  filter(AREA %in% counties, SEX == "Male", SITE %in% cancerCategories$originalNames) %>%
  mutate(
    year = 2015,
    region = match(AREA, counties) + 8,
    cancer = cancerCategories$newNames[match(SITE, cancerCategories$originalNames)],
    race = races$newNames[match(RACE, races$originalNames)],
    rateType = rateTypes$newNames[match(EVENT_TYPE, rateTypes$originalNames)],
    rate = AGE_ADJUSTED_RATE
  )
x$rate[x$rate == "~"] = NA
x = x[,8:13]
x = x %>% arrange(region, cancer, race)

# y = rbind(y,x)

write.csv(x, file = "countyCancerData.csv", row.names = FALSE)
