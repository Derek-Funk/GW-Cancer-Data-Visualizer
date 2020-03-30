library(readxl)

pathToRawData = "C:/Users/derek.funk/Desktop/MSDS/Capstone/Cancer_Data_Visualizer/Data/Raw_Data/American Community Survey"
pathToWriteData = "C:/Users/derek.funk/Desktop/MSDS/Capstone/Cancer_Data_Visualizer/Data/Pre_Processing"
nameOfFile = "acs_5-yr_estimates_2013-2017.csv"
namesOfRawDataFiles = c(
  "2013-2017 ACS 5-Year Ward.xls",
  "2012-2016 ACS 5-Year Ward.xls",
  "2011-2015 Ward.xls",
  "2010-2014 ACS 5-Year Estimates-Ward_0.xls",
  "2009-2013 ACS 5-Year Esitmates-Ward_0.xls",
  "2008-2012 ACS 5-Year Ward.xls",
  "2013-2017 ACS 5-Year Districtwide.xls",
  "2012-2016 ACS 5 -Year Districtwide.xls",
  "2011-2015 Districtwide.xls",
  "2010-2014 ACS 5-Year Estimates-Districtwide_0.xls",
  "2009-2013 ACS 5-Year Districtwide.xls",
  "2008-2012 ACS 5-Year Districwide.xls"
)
dataToWrite = data.frame(stringsAsFactors = FALSE,
  variable = character(),
  year = integer(),
  ward = integer(),
  category = character(),
  count = integer()
)
snippet = read_xls(path = paste0(pathToRawData, "/", namesOfRawDataFiles[1]), sheet = 2)
match("Less than 9th grade", snippet[,1,1])
