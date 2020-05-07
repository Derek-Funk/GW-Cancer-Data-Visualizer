# packages used
#####

library(dplyr) # used for data processing
library(DT) # used for rendering data tables
library(dygraphs) # used for interactive chart
library(ggplot2) # used for many charts
library(ggrepel) # ggplot add on to repel text labels
library(leaflet) # renders maps
library(scales) # used for plot label formatting
library(sf) # used to read in geojson lat/long coordinates
library(shiny) # required
library(shinyBS) # used for help button
library(shinycssloaders) # used for loading spinners
library(shinydashboard) # provides background look
library(shinyjs) # provides common JS functions
library(shinyWidgets) # provides nicer UI components
library(stringi) # used for some string replacements
library(tidyr) # used for data processing

#####

# global variables
#####

# toggle this to FALSE when deploying to prod
DEBUG_MODE = FALSE

# categories of cancer-related data
DETAILED_CANCER_STATISTICS_CATEGORIES = c("Incidence Rate", "Mortality Rate")

#categories of non-cancer related data
RISK_AND_PROTECTIVE_FACTORS_CATEGORIES = c("Socio Demographics", "Economic Resources",
                                           "Environmental Factors",
                                           "Housing & Transportation", "Health & Risk Behaviors")

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
    "GWCC Catchment Area",
    paste("Ward", 1:8),
    "District of Columbia",
    "Charles County", "Montgomery County", "Prince George's County", # MD counties
    "Arlington County", "Fairfax County", "Loudoun County", "Prince William County", # VA counties
    "City of Alexandria", "City of Fairfax", "City of Falls Church", "City of Manassas", "City of Manassas Park" # independent cities
  ),
  zoom_latitude = c(
    38.8,
    38.926,38.888,38.938,38.965,38.926,38.88,38.885,38.84,
    38.888,
    38.5,39.1,38.84,
    38.888,38.84,39.1,38.7,
    38.82,38.84,38.88,38.75,38.77
  ),
  zoom_longitude = c(
    -77.4,
    -77.03,-77.05,-77.08,-77.03,-77,-77.01,-76.95,-77.01,
    -77.05,
    -77.1,-77.2,-76.9,
    -77.11,-77.3,-77.75,-77.55,
    -77.06,-77.3,-77.2,-77.51,-77.48
  ),
  zoom_level = c(
    9,
    14,13,13,13,13,13,13,12,
    11,
    10,10,10,
    10,10,10,10,
    12,12,12,12,12
  )
)

# list of cancers as we want them to appear in dropdown
CANCERS_LIST = sort(c("All Cancers", "Brain Cancer", "Cervical Cancer", "Colorectal Cancer", "Uterine Cancer",
                    "Esophageal Cancer", "Female Breast Cancer", "Hodgkin Lymphoma", "Kaposi Sarcoma",
                    "Kidney Cancer", "Laryngeal Cancer", "Leukemia", "Liver Cancer", "Lung Cancer",
                    "Melanoma", "Mesothelioma", "Myeloma", "Non-Hodgkin Lymphoma", "Oral Cancer",
                    "Ovarian Cancer", "Pancreatic Cancer", "Stomach Cancer", "Thyroid Cancer",
                    "Bladder Cancer", "Male Breast Cancer", "Prostate Cancer", "Testicular Cancer"))

# list of regions as we want them to appear in dropdown
REGIONS_LIST_DROPDOWN_CHOICES = list(
  "GWCC Catchment Area" = 0,
  "DC" = 11001,
  "DC Wards" = c(
    "Ward 1" = 1,
    "Ward 2" = 2,
    "Ward 3" = 3,
    "Ward 4" = 4,
    "Ward 5" = 5,
    "Ward 6" = 6,
    "Ward 7" = 7,
    "Ward 8" = 8
  ),
  "VA Counties & Independent Cities" = c(
    "Arlington County" = 51013,
    "Fairfax County" = 51059,
    "Loudoun County" = 51107,
    "Prince William County" = 51153,
    "City of Alexandria" = 51510,
    "City of Fairfax" = 51600,
    "City of Falls Church" = 51610,
    "City of Manassas" = 51683,
    "City of Manassas Park" = 51685
  ),
  "MD Counties" = c(
    "Charles County" = 24017,
    "Montgomery County" = 24031,
    "Prince George's County" = 24033
  )
)

REGIONS_LIST_DROPDOWN_CHOICES_NO_WARDS = list(
  "GWCC Catchment Area" = 0,
  "DC" = 11001,
  "VA Counties & Independent Cities" = c(
    "Arlington County" = 51013,
    "Fairfax County" = 51059,
    "Loudoun County" = 51107,
    "Prince William County" = 51153,
    "City of Alexandria" = 51510,
    "City of Fairfax" = 51600,
    "City of Falls Church" = 51610,
    "City of Manassas" = 51683,
    "City of Manassas Park" = 51685
  ),
  "MD Counties" = c(
    "Charles County" = 24017,
    "Montgomery County" = 24031,
    "Prince George's County" = 24033
  )
)

# list of all variables as we want them to appear in dropdown
CANCER_MAP_VARIABLE_CHOICES = list(
  "Cancer Data" = c("Incidence Rate", "Mortality Rate"),
  "Socio Demographics" = c("Educational Attainment", "Ethnicity", "Foreign-Born", "Main Language Spoken at Home",
                           "Median Age", "Population", "Race"),
  "Economic Resources" = c("Below Poverty Level", "Health Insurance Coverage", "Median Income", "Unemployment Rate"),
  "Environmental Factors" = list(c("Air Quality Index")),
  "Housing & Transportation" = c("Housing Tenure", "Rent > 30% of Household Income", "Vehicles Per Housing Unit"),
  "Health & Risk Behaviors" = c("% Children Eligible for Free Lunch", "% Diabetic", "% Diabetic Screening",
                                "% Excessive Drinking", "HIV Prevalence", "Homicide Rate", "% Inadequate Social Support",
                                "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                "% Poor/Fair Health", "% Physically Inactive", "Premature Mortality Rate",
                                "% Single-Parent Households", "% Smoking", "Violent Crime Rate")
)

# categories for education
EDUCATION_CATEGORIES_LIST = c(
  "Less than 9th grade",
  "Some High School",
  "High school graduate",
  "Some College",
  "Associate's Degree",
  "Bachelor's Degree",
  "Advanced Degree"
)

# categories for ethnicity
ETHNICITY_CATEGORIES_LIST = c(
  "Hispanic or Latino",
  "Not Hispanic or Latino"
)

# categories for foreign-born
FOREIGN_BORN_CATEGORIES_LIST = c("Foreign-Born", "Native")

# categories for health insurance
HEALTH_INSURANCE_CATEGORIES_LIST = c("Private Health Insurance", "Public Health Insurance", "Uninsured")

# categories for housing tenure
HOUSING_TENURE_CATEGORIES_LIST = c("Owner-occupied", "Renter-occupied")

# categories for language
LANGUAGE_CATEGORIES_LIST = c("English Only", "Language Other Than English")

# categories for race
RACE_CATEGORIES_LIST = c(
  "White", "Black", "Asian or Pacific Islander", "Native American", "Other Individual Race", "Two or More Races"
)

# categories for vehicles
VEHICLES_CATEGORIES_LIST = c("No vehicles", "1 vehicle", "2 vehicles", "3 or more vehicles")

# list of messages for when user clicks on "Data Info"
DATA_INFO_MESSAGE_LIST = c(
  # 1 - Cancer data
  ' for DC, Virgina, and Maryland is obtained via data files from the Centers for Disease Control and Prevention.<br><a href=https://www.cdc.gov/cancer/uscs/dataviz/download_data.htm target="_blank">Link to Data Files</a><br><br>DC ward data was specially requested from the DC Cancer Registry. DC ward cancer rates are slightly higher than other regions due to different reporting standards.<br><br>Additional data may be unavailable due to protecting patient privacy in regions with low rates.',
  # 2 - ACS data - available for all regions
  ' is obtained from the American Community Survey (ACS) 5-Year Estimates.<br><br>ACS data for individual DC wards and at the aggregate DC level are obtained via data files from the DC Office of Planning.<br><a href=https://planning.dc.gov/page/american-community-survey-acs-estimates target="_blank">Link to Data Files</a><br><br>ACS data for VA and MD counties is obtained from the US Census Bureau\'s ACS API.<br><a href=https://api.census.gov/data.html target="_blank">Link to API Documentation</a>',
  # 3 - ACS data - available for all regions except entire GWCC Catchment Area
  ' is obtained from the American Community Survey (ACS) 5-Year Estimates.<br><br>ACS data for individual DC wards and at the aggregate DC level are obtained via data files from the DC Office of Planning.<br><a href=https://planning.dc.gov/page/american-community-survey-acs-estimates target="_blank">Link to Data Files</a><br><br>ACS data for VA and MD counties is obtained from the US Census Bureau\'s ACS API.<br><a href=https://api.census.gov/data.html target="_blank">Link to API Documentation</a><br><br>This value is unavailable for the aggregate GWCC Catchment Area.',
  # 4 - EPA data
  ' is obtained via data files from the Environmental Protection Agency.<br><a href=https://aqs.epa.gov/aqsweb/airdata/download_files.html target="_blank">Link to Data Files</a><br><br>These data are currently only available for VA and MD counties and at the DC aggregate level.',
  # 5 - County Health Rankings data
  ' is obtained via data files from the County Health Rankings & Roadmaps program.<br><a href=https://www.countyhealthrankings.org/app/ target="_blank">Link to Data Files</a><br><br>These data are currently only available for VA and MD counties. Additional data may be unavailable or repeated for specific variables and years.'
)

# Add to this list if you need more tutorials. Name must match gif file name and image output id.
LIST_OF_GIFS = c("gif_tabNavigation", "gif_cancerMaps", "gif_detailedCancerStatistics", "gif_riskAndProtectiveFactors",
                 "gif_dataExplorer")

#####

# read master cancer data file
#####
CANCER_DATA = read.csv(file = "www/data/masterDataFile_cancer_countyWard.csv",
                    col.names = c("year", "region", "cancer", "race", "rateType", "rate"))
CANCER_DATA$rate = as.numeric(as.character(CANCER_DATA$rate))
INCIDENCE_DATA = CANCER_DATA %>% filter(rateType == "incidenceRate")
MORTALITY_DATA = CANCER_DATA %>% filter(rateType == "mortalityRate")
#####

# create legend bins lookup for cancers
#####
LEGEND_BINS_LOOKUP_INCIDENCE = list()
for(specificCancer in CANCERS_LIST) {
  legendBins = c(0,
                 INCIDENCE_DATA %>%
                      filter(year == 2016, ! region %in% 0:8, race == "All Races", cancer == specificCancer) %>%
                      select(rate) %>%
                      quantile(probs=c(.2,.4,.6,.8), na.rm = TRUE) %>%
                      round() %>%
                      unique() %>%
                      unname(),
                    Inf
  )
  legendBins = legendBins[!is.na(legendBins)]
  
  LEGEND_BINS_LOOKUP_INCIDENCE[[specificCancer]] = legendBins
}

LEGEND_BINS_LOOKUP_MORTALITY = list()
for(specificCancer in CANCERS_LIST) {
  legendBins = c(0,
                 MORTALITY_DATA %>%
                      filter(year == 2016, ! region %in% 0:8, race == "All Races", cancer == specificCancer) %>%
                      select(rate) %>%
                      quantile(probs=c(.2,.4,.6,.8), na.rm = TRUE) %>%
                      round() %>%
                      unname(),
                    Inf
  ) %>% unique()
  legendBins = legendBins[!is.na(legendBins)]
  
  LEGEND_BINS_LOOKUP_MORTALITY[[specificCancer]] = legendBins
}
#####

# read master non-cancer data file
#####
NON_CANCER_DATA = read.csv(file = "www/data/masterDataFile_nonCancer_countyWard.csv",
                    col.names = c("variable", "year", "region", "category", "count", "rate"))

# ACS data - variables with categories need factoring
EDUCATION_DATA = NON_CANCER_DATA %>% filter(variable == "education")
EDUCATION_DATA$category  = factor(EDUCATION_DATA$category, levels = EDUCATION_CATEGORIES_LIST)

ETHNICITY_DATA = NON_CANCER_DATA %>% filter(variable == "ethnicity")
ETHNICITY_DATA$category = factor(ETHNICITY_DATA$category, levels = ETHNICITY_CATEGORIES_LIST)

FOREIGN_BORN_DATA = NON_CANCER_DATA %>% filter(variable == "foreign-born")
FOREIGN_BORN_DATA$category = factor(FOREIGN_BORN_DATA$category, levels = FOREIGN_BORN_CATEGORIES_LIST)

HEALTH_INSURANCE_DATA = NON_CANCER_DATA %>% filter(variable == "healthInsuranceCoverage")
HEALTH_INSURANCE_DATA$category = factor(HEALTH_INSURANCE_DATA$category, levels = HEALTH_INSURANCE_CATEGORIES_LIST)

HOUSING_TENURE_DATA = NON_CANCER_DATA %>% filter(variable == "housingTenure")
HOUSING_TENURE_DATA$category = factor(HOUSING_TENURE_DATA$category, levels = HOUSING_TENURE_CATEGORIES_LIST)

LANGUAGE_DATA = NON_CANCER_DATA %>% filter(variable == "language")
LANGUAGE_DATA$category = factor(LANGUAGE_DATA$category, levels = LANGUAGE_CATEGORIES_LIST)

RACE_DATA = NON_CANCER_DATA %>% filter(variable == "race")
RACE_DATA$category  = factor(RACE_DATA$category, levels = RACE_CATEGORIES_LIST)

VEHICLES_DATA = NON_CANCER_DATA %>% filter(variable == "vehiclesPerHousingUnit")
VEHICLES_DATA$category  = factor(VEHICLES_DATA$category, levels = VEHICLES_CATEGORIES_LIST)

# ACS data - variables without categories
BELOW_POVERTY_DATA = NON_CANCER_DATA %>% filter(variable == "belowPovertyLevel")

MEDIAN_AGE_DATA = NON_CANCER_DATA %>% filter(variable == "medianAge")

MEDIAN_INCOME_DATA = NON_CANCER_DATA %>% filter(variable == "medianHouseholdIncome")

POPULATION_DATA = NON_CANCER_DATA %>% filter(variable == "population")

RENT_GREATER_THAN_30_INCOME_DATA = NON_CANCER_DATA %>% filter(variable == "rentGreaterThan30PercentOfHouseholdIncome")

UNEMPLOYMENT_RATE_DATA = NON_CANCER_DATA %>% filter(variable == "employment", category == "Unemployed")

# Robert Wood Johnson Foundation (County Rankings) data
CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA = NON_CANCER_DATA %>% filter(variable == "childrenEligibleForFreeLunch")
DIABETIC_DATA = NON_CANCER_DATA %>% filter(variable == "diabetic")
DIABETIC_SCREENING_DATA = NON_CANCER_DATA %>% filter(variable == "diabeticScreening")
EXCESSIVE_DRINKING_DATA = NON_CANCER_DATA %>% filter(variable == "excessiveDrinking")
HIV_PREVALENCE_DATA = NON_CANCER_DATA %>% filter(variable == "hivPrevalence")
HOMICIDE_RATE_DATA = NON_CANCER_DATA %>% filter(variable == "homicideRate")
INADEQUATE_SOCIAL_SUPPORT_DATA = NON_CANCER_DATA %>% filter(variable == "inadequateSocialSupport")
LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA = NON_CANCER_DATA %>% filter(variable == "limitedAccessToHealthyFoods")
MAMMOGRAPHY_SCREENING_DATA = NON_CANCER_DATA %>% filter(variable == "mammographyScreening")
OBESITY_DATA = NON_CANCER_DATA %>% filter(variable == "obesity")
PHYSICAL_INACTIVITY_DATA = NON_CANCER_DATA %>% filter(variable == "physicalInactivity")
POOR_OR_FAIR_HEALTH_DATA = NON_CANCER_DATA %>% filter(variable == "poorOrFairHealth")
PREMATURE_MORTALITY_RATE_DATA = NON_CANCER_DATA %>% filter(variable == "prematureMortalityRate")
SINGLE_PARENT_HOUSEHOLD_DATA = NON_CANCER_DATA %>% filter(variable == "singleParentHouseholds")
SMOKING_DATA = NON_CANCER_DATA %>% filter(variable == "smoking")
VIOLENT_CRIME_RATE_DATA = NON_CANCER_DATA %>% filter(variable == "violentCrimeRate")

# EPA data
AIR_QUALITY_INDEX_DATA = NON_CANCER_DATA %>% filter(variable == "airQualityIndex")

#####

# functions
#####
source("www/modularizedUis/ui_cancerMap.R")
source("www/modularizedUis/ui_cancerMap_noWards.R")

createPlot_riskAndProtectiveFactors = function(
  dataSubset1, dataSubset2, compareTwoRegions, variable, plotTitle, plotType, year, regionsIndices
) {
  switch(plotType,
    # plot type 1: race, education, health insurance coverage, vehicles per housing unit (multiple categories)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = category, y = rate)) +
          geom_bar(aes(fill = dataSubset), stat = "identity", width = 0.5, position = "dodge") +
          geom_text(
            mapping = aes(
              x = category,
              y = rate + 5,
              label = paste0(rate, "%"),
              group = dataSubset
            ),
            position = position_dodge(width = 0.5)
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_y_continuous(limits = c(0,100), breaks = 0:10 * 10,
                             labels = paste0(0:10 * 10, "%")) +
          scale_fill_discrete(
            name = "Region",
            labels = REF_REGIONS$name[regionsIndices]
          )
      } else {
        # single ward
        ggplot(data = dataSubset1, mapping = aes(x = category, y = rate, fill = dataSubset)) +
          geom_bar(stat = "identity", width = 0.5, fill = "turquoise3") +
          geom_text(
            mapping = aes(
              x = category,
              y = rate + 5,
              label = paste0(rate, "%")
            )
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_y_continuous(limits = c(0,100), breaks = 0:10 * 10, labels = paste0(0:10 * 10, "%")) +
          scale_fill_discrete(
            name = "Region",
            labels = REF_REGIONS$name[regionsIndices[1]]
          )
      }
    },
    # plot type 2: ethnicity, foreign-born, housing tenure, language (two categories)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate, fill = category)) +
          geom_bar(stat = "identity") +
          geom_text(
            mapping = aes(
              label = paste0(rate, "%"),
            ),
            position = position_stack(vjust = 0.5)
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year, fill = variable) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,100), breaks = 0:10 * 10, labels = paste0(0:10 * 10, "%"))
      } else {
        # single ward
        ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate, fill = category)) +
          geom_bar(stat = "identity", width = 0.5) +
          geom_text(
            mapping = aes(label = paste0(rate, "%"),),
            position = position_stack(vjust = 0.5)
          ) +
          xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year, fill = variable) +
          theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
          scale_y_continuous(limits = c(0,100), breaks = 0:10 * 10, labels = paste0(0:10 * 10, "%"))
      }
    },
    # plot type 3: median age (single value with no formatting, up to 45)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 20, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 20, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") + # #00C5CD
          geom_text(
            mapping = aes(y = rate+2, label = rate)
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,45)) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+2, label = rate)
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,45))
        }
      }
    },
    # plot type 4: median income (single value with dollar sign)
    {
      tickSize = 10000
      noTicks = 14
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = noTicks*tickSize/2, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = noTicks*tickSize/2, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+5000, label = dollar(rate))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,noTicks*tickSize), breaks = 0:noTicks*tickSize, labels = dollar_format()(0:noTicks*tickSize)) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+5000, label = dollar(rate))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,noTicks*tickSize), breaks = 0:noTicks*tickSize, labels = dollar_format()(0:noTicks*tickSize))
        }
      }
    },
    # plot type 5: diabetic, % excessive drinking, unemployment rate (single value with percent sign, up to 30%)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 15, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 15, size = 6)
        } else {
          NULL
        }
        
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+2, label = paste0(rate, "%"))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,30), labels = paste0(0:3*10, "%")) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+1, label = paste0(rate, "%"))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,30), labels = paste0(0:3*10, "%"))
        }
      }
    },
    # plot type 6: air quality index (single value with no formatting, up to 55)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 30, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 30, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+2, label = rate)
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,55)) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+2, label = rate)
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,55))
        }
      }
    },
    # plot type 7: below poverty level (single value with percent sign, up to 40%)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 20, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 20, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+2, label = paste0(rate, "%"))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,40), labels = paste0(0:4*10, "%")) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+1, label = paste0(rate, "%"))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,40), labels = paste0(0:4*10, "%"))
        }
      }
    },
    # plot type 8: children eligible for free lunch,
    # rent greater than 30% of household income (single value with percent sign, up to 70%)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 35, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 35, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+2, label = paste0(rate, "%"))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,70), breaks = 0:7*10, labels = paste0(0:7*10, "%")) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+2, label = paste0(rate, "%"))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,70), breaks = 0:7*10, labels = paste0(0:7*10, "%"))
        }
      }
    },
    # plot type 9: % diabetic screening (single value with percent sign, up to 100%)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 35, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 35, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+2, label = paste0(rate, "%"))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,100), breaks = 0:10*10, labels = paste0(0:10*10, "%")) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+2, label = paste0(rate, "%"))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,100), breaks = 0:10*10, labels = paste0(0:10*10, "%"))
        }
      }
    },
    # plot type 10: hiv prevalence, premature mortality rate,
    # violent crime rate (single value with no formatting, up to 1000)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 500, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 500, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+50, label = rate)
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,1000)) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+50, label = rate)
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,1000))
        }
      }
    },
    # plot type 11: population for any region but entire DMV 
    # (single value with comma formatting, up to 1.2M)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 500, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 500, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+50000, label = prettyNum(rate, big.mark = ","))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,1200000), label = comma) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+50000, label = prettyNum(rate, big.mark = ","))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,1200000), label = comma)
            # scale_y_continuous(limits = c(0,1200000), breaks = 0:12*100000, labels = 0:12*100000)
        }
      }
    },
    # plot type 12: population for just DMV (single value with comma formatting, up to 6M)
    {
      if(compareTwoRegions) {
        # compare 2 wards
        annotation_1 = if(is.na(dataSubset1$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 1, y = 500, size = 6)
        } else {
          NULL
        }
        annotation_2 = if(is.na(dataSubset2$rate)) {
          annotate(geom = "text", label = "Not available for this region", x = 2, y = 500, size = 6)
        } else {
          NULL
        }
        x = rbind(dataSubset1, dataSubset2)
        ggplot(data = x, mapping = aes(x = dataSubset, y = rate)) +
          geom_bar(stat = "identity", fill = "turquoise3") +
          geom_text(
            mapping = aes(y = rate+250000, label = prettyNum(rate, big.mark = ","))
          ) +
          xlab(label = "") +
          ylab(label = "") +
          labs(title = plotTitle, subtitle = year) +
          theme(axis.ticks.x = element_blank()) +
          scale_x_discrete(breaks = c("1","2"), labels = REF_REGIONS$name[regionsIndices]) +
          scale_y_continuous(limits = c(0,6000000), label = comma) +
          annotation_1 +
          annotation_2
      } else {
        # single ward
        if(is.na(dataSubset1$rate)) {
          ggplot() +
            annotate(geom = "text", label = paste0(plotTitle, " not available for this region"), x = 0, y = 0, size = 6) +
            theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                  panel.grid = element_blank())
        } else {
          ggplot(data = dataSubset1, mapping = aes(x = dataSubset, y = rate)) +
            geom_bar(stat = "identity", fill = "turquoise3") +
            geom_text(
              mapping = aes(y = rate+250000, label = prettyNum(rate, big.mark = ","))
            ) +
            xlab(label = REF_REGIONS$name[regionsIndices[1]]) +
            ylab(label = "") +
            labs(title = plotTitle, subtitle = year) +
            theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
            scale_y_continuous(limits = c(0,6000000), label = comma)
          # scale_y_continuous(limits = c(0,1200000), breaks = 0:12*100000, labels = 0:12*100000)
        }
      }
    }
  )
}
#####

# geojson
#####

mapboxToken <- "pk.eyJ1IjoiZGVyZWstZnVuayIsImEiOiJjanRzd3g5am4wb2t4M3lxdXM5bzM0ZzBrIn0.FF7p0w7uLe3HeVFMNuxQaw"
GEOJSON_DMV = st_read("www/data/dmvGeojson.json") %>% st_zm()
MAP_COLORS = list(
  rep("dark gray",20), # GWCC Catchment Area
  
  # wards
  c("dark gray", rep("gray",19)),
  c("gray", "dark gray", rep("gray",18)),
  c(rep("gray",2), "dark gray", rep("gray",17)),
  c(rep("gray",3), "dark gray", rep("gray",16)),
  c(rep("gray",4), "dark gray", rep("gray",15)),
  c(rep("gray",5), "dark gray", rep("gray",14)),
  c(rep("gray",6), "dark gray", rep("gray",13)),
  c(rep("gray",7), "dark gray", rep("gray",12)),
  
  c(rep("dark gray",8), rep("gray",12)), # DC
  
  # counties/cities
  c(rep("gray",8), "dark gray", rep("gray",11)),
  c(rep("gray",9), "dark gray", rep("gray",10)),
  c(rep("gray",10), "dark gray", rep("gray",9)),
  c(rep("gray",11), "dark gray", rep("gray",8)),
  c(rep("gray",12), "dark gray", rep("gray",7)),
  c(rep("gray",13), "dark gray", rep("gray",6)),
  c(rep("gray",14), "dark gray", rep("gray",5)),
  c(rep("gray",15), "dark gray", rep("gray",4)),
  c(rep("gray",16), "dark gray", rep("gray",3)),
  c(rep("gray",17), "dark gray", rep("gray",2)),
  c(rep("gray",18), "dark gray", "gray"),
  c(rep("gray",19), "dark gray")
  
)

#####