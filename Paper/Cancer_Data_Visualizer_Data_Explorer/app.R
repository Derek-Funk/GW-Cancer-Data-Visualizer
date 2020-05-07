#library to deploy app: rsconnect
#command to deploy app: deployApp(appDir = "C:\\Users\\derek.funk\\Documents\\MSDS\\Capstone\\Paper\\Cancer_Data_Visualizer_Data_Explorer", account = "derek-funk")

source("global.R")

ui = dashboardPage(skin = "black",
                   # use for testing
                   header = if(DEBUG_MODE) {
                     dashboardHeader(title = "Debug")
                   } else {
                     dashboardHeader(disable = TRUE)
                   },
                   sidebar = if(DEBUG_MODE) {
                     dashboardSidebar(collapsed = TRUE,
                                      textInput(inputId = "debug1", label = "Debug 1"),
                                      actionButton(inputId = "runDebug1", label = "Run"),
                                      textInput(inputId = "debug2", label = "Debug 2"),
                                      actionButton(inputId = "runDebug2", label = "Run"),
                                      textInput(inputId = "debug3", label = "Debug 3"),
                                      actionButton(inputId = "runDebug3", label = "Run")
                     )
                   } else {
                     dashboardSidebar(disable = TRUE)
                   },
                   body = dashboardBody(useShinyjs(),
                                        tags$head(
                                          includeScript(path = "www/customJavaScript/google-analytics.js"),
                                          tags$link(rel = "stylesheet", type = "text/css", href = "www/dygraph.css")
                                        ),
                                        # this suppresses errors from showing in UI. You will still be able to see errors in console.
                                        tags$style(type="text/css", "
      .shiny-output-error {
        visibility: hidden;
      }
      
      .shiny-output-error:before {
        visibility: hidden;
      }
      
      .highlight {
        display: inline;
        background-color: #B1C7F2;
      }
    "),
            #                             absolutePanel(
            #                               top = if(DEBUG_MODE) {65} else {13},
            #                               right = 30,
            #                               actionBttn(inputId = "help",
            #                                          label = "Tutorial",
            #                                          icon = icon(name = "question-circle"),
            #                                          style = "jelly",
            #                                          color = "warning",
            #                                          size = "sm"
            #                               ),
            #                               bsTooltip(id = "help", title = "Click here for a walkthrough of this visualizer"),
            #                               bsModal(id = "helpModal", title = "Tutorial", trigger = "help", size = "large",
            #                                       tabBox(width = 12,
            #                                              tabPanel(title = "  1  ",
            #                                                       HTML("
            #   <h4>TAB NAVIGATION</h4><br>
            #   Click on the tabs at the top of the screen to view cancer data around the GWCC Catchment Area.<br><br>
            # "),
            #                                                       imageOutput(outputId = "gif_tabNavigation") %>%
            #                                                         withSpinner(type = 6, color = "#76B7D2")
            #                                              ),
            #                                              tabPanel(title = "  2  ",
            #                                                       HTML("
            #   <h4>CANCER MAPS</h4><br>
            #   View this tab to see both cancer data and risk and protective factors geographically.<br><br>
            #   These maps show data for just the year 2016.<br><br>
            # "),
            #                                                       imageOutput(outputId = "gif_cancerMaps") %>%
            #                                                         withSpinner(type = 6, color = "#76B7D2")
            #                                              ),
            #                                              tabPanel(title = "  3  ",
            #                                                       HTML("<h4>DETAILED CANCER STATISTICS</h4><br>
            # View this tab to see plots for just cancer data.<br><br>
            # These plots show data for the time periods 2011-2015 and 2012-2016.<br><br>
            # "),
            #                                                       imageOutput(outputId = "gif_detailedCancerStatistics") %>%
            #                                                         withSpinner(type = 6, color = "#76B7D2")
            #                                              ),
            #                                              tabPanel(title = "  4  ",
            #                                                       HTML("
            #   <h4>RISK AND PROTECTIVE FACTORS</h4><br>
            #   View this tab to see plots for just risk and protective factors.<br><br>
            #   These plots show data for the years 2013-2017.<br><br>
            # "),
            #                                                       imageOutput(outputId = "gif_riskAndProtectiveFactors") %>%
            #                                                         withSpinner(type = 6, color = "#76B7D2")
            #                                              ),
            #                                              tabPanel(title = "  5  ",
            #                                                       HTML("
            #   <h4>DATA EXPLORER</h4><br>
            #   View this tab to compare cancer data and risk and protective factors.<br><br>
            #   These plots show data for the years that are available based on variable.<br><br>
            # "),
            #                                                       imageOutput(outputId = "gif_dataExplorer") %>%
            #                                                         withSpinner(type = 6, color = "#76B7D2")
            #                                              )
            #                                       )
            #                               )
            #                             ),
                                        # tabsetPanel(id = "tabs",
                                                    # tabPanel(title = "CANCER MAPS",
                                                    #          br(),
                                                    #          fluidRow(
                                                    #            column(width = 12,
                                                    #                   materialSwitch(
                                                    #                     inputId = "cancerMap_lockRegions",
                                                    #                     label = "   Sync Regions",
                                                    #                     value = FALSE,
                                                    #                     status = "danger",
                                                    #                     right = TRUE
                                                    #                   ),
                                                    #                   materialSwitch(
                                                    #                     inputId = "cancerMap_wardGranularity",
                                                    #                     label = "Show DC Wards",
                                                    #                     value = FALSE,
                                                    #                     status = "danger",
                                                    #                     right = TRUE
                                                    #                   ),
                                                    #                   actionBttn(inputId = "whatAreDcWards",
                                                    #                              label = a("What are DC Wards?", href = "https://dccouncil.us/learn-about-wards-and-ancs/", target = "_blank"),
                                                    #                              style = "minimal",
                                                    #                              color = "primary",
                                                    #                              size = "xs"
                                                    #                   )
                                                    #            )
                                                    #          ),
                                                    #          br(),
                                                    #          fluidRow(
                                                    #            ui_cancerMap(mapNumber = 1),
                                                    #            ui_cancerMap(mapNumber = 2)
                                                    #          )
                                                    # ),
                                                    # tabPanel(title = "DETAILED CANCER STATISTICS",
                                                    #          br(),
                                                    #          fluidRow(
                                                    #            column(width = 2,
                                                    #                   box(title = tags$strong("Select Chart"), width = 12, height = 480,
                                                    #                       uiOutput(outputId = "detailedCancerStatistics_sidebar")
                                                    #                   )
                                                    #            ),
                                                    #            column(width = 4,
                                                    #                   box(title = tags$strong("Select Parameters"), width = 12,
                                                    #                       radioButtons(inputId = "detailedCancerStatistics_comparisonType",
                                                    #                                    label = "",
                                                    #                                    choices = c("View One Cancer in One Region" = 1,
                                                    #                                                "Compare Two Cancers in One Region" = 2,
                                                    #                                                "Compare Two Regions for One Cancer" = 3)
                                                    #                       ),
                                                    #                       fluidRow(
                                                    #                         column(width = 6,
                                                    #                                selectInput(inputId = "detailedCancerStatistics_selectCancer1",
                                                    #                                            label = "Cancer Type 1",
                                                    #                                            choices = CANCERS_LIST,
                                                    #                                            selected = "All Cancers"
                                                    #                                )
                                                    #                         ),
                                                    #                         column(width = 6,
                                                    #                                hidden(selectInput(inputId = "detailedCancerStatistics_selectCancer2",
                                                    #                                                   label = "Cancer Type 2",
                                                    #                                                   choices = CANCERS_LIST,
                                                    #                                                   selected = "All Cancers"
                                                    #                                ))
                                                    #                         )
                                                    #                       ),
                                                    #                       fluidRow(
                                                    #                         column(width = 6,
                                                    #                                selectInput(inputId = "detailedCancerStatistics_selectRegion1",
                                                    #                                            label = "Region 1",
                                                    #                                            choices = REGIONS_LIST_DROPDOWN_CHOICES,
                                                    #                                            selected = 11001
                                                    #                                )
                                                    #                         ),
                                                    #                         column(width = 6,
                                                    #                                hidden(selectInput(inputId = "detailedCancerStatistics_selectRegion2",
                                                    #                                                   label = "Region 2",
                                                    #                                                   choices = REGIONS_LIST_DROPDOWN_CHOICES,
                                                    #                                                   selected = 11001
                                                    #                                ))
                                                    #                         )
                                                    #                       ),
                                                    #                       checkboxGroupInput(inputId = "detailedCancerStatistics_raceEthnicity",
                                                    #                                          label = "Race & Ethnicity",
                                                    #                                          choices = c(
                                                    #                                            "Everyone" = "All Races",
                                                    #                                            "White" = "White",
                                                    #                                            "Black" = "Black",
                                                    #                                            "Asian" = "Asian",
                                                    #                                            "Hispanic" = "Hispanic"
                                                    #                                          ),
                                                    #                                          inline = TRUE,
                                                    #                                          selected = "All Races"
                                                    #                       ),
                                                    #                       tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"), #hides minor ticks in slider input
                                                    #                       radioButtons(inputId = "detailedCancerStatistics_year",
                                                    #                                    label = "Time Period",
                                                    #                                    choices = c("2011-2015" = 2015, "2012-2016" = 2016),
                                                    #                                    selected = 2016,
                                                    #                                    inline = TRUE,
                                                    #                                    width = 235
                                                    #                       ),
                                                    #                       actionBttn(inputId = "detailedCancerStatistics_updateButton",
                                                    #                                  label = "Update",
                                                    #                                  style = "material-flat",
                                                    #                                  color = "danger"
                                                    #                       )
                                                    #                   )
                                                    #            ),
                                                    #            column(width = 6,
                                                    #                   box(width = 12,
                                                    #                       column(width = 6,
                                                    #                              leafletOutput(outputId = "detailedCancerStatistics_map1", height = 450)
                                                    #                       ),
                                                    #                       column(width = 6,
                                                    #                              leafletOutput(outputId = "detailedCancerStatistics_map2", height = 450)
                                                    #                       )
                                                    #                   )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(width = 12, id = "detailedCancerStatistics_incidenceRatePlot",
                                                    #                plotOutput(outputId = "detailedCancerStatistics_incidenceRatePlot"),
                                                    #                actionBttn(inputId = "dataInfo_incidenceRatePlot",
                                                    #                           label = "Data Info",
                                                    #                           style = "minimal",
                                                    #                           color = "primary",
                                                    #                           size = "xs"
                                                    #                )
                                                    #            ),
                                                    #            box(width = 12, id = "detailedCancerStatistics_mortalityRatePlot",
                                                    #                plotOutput(outputId = "detailedCancerStatistics_mortalityRatePlot"),
                                                    #                actionBttn(inputId = "dataInfo_mortalityRatePlot",
                                                    #                           label = "Data Info",
                                                    #                           style = "minimal",
                                                    #                           color = "primary",
                                                    #                           size = "xs"
                                                    #                )
                                                    #            )
                                                    #          )
                                                    # ),
                                                    # tabPanel(title = "RISK AND PROTECTIVE FACTORS",
                                                    #          br(),
                                                    #          fluidRow(
                                                    #            column(width = 2,
                                                    #                   box(title = tags$strong("Select Chart"), width = 12, height = 420,
                                                    #                       uiOutput(outputId = "riskAndProtectiveFactors_sidebar")
                                                    #                   )
                                                    #            ),
                                                    #            column(width = 4,
                                                    #                   box(title = tags$strong("Select Parameters"), width = 12,
                                                    #                       radioButtons(inputId = "socioDemographics_compareTwoRegions",
                                                    #                                    label = "",
                                                    #                                    choices = c("View One Region" = FALSE, "Compare Two Regions" = TRUE),
                                                    #                                    inline = TRUE
                                                    #                       ), br(),
                                                    #                       fluidRow(
                                                    #                         column(width = 6,
                                                    #                                selectInput(inputId = "socioDemographics_selectRegion1",
                                                    #                                            label = "Region 1",
                                                    #                                            choices = REGIONS_LIST_DROPDOWN_CHOICES,
                                                    #                                            selected = 11001
                                                    #                                )
                                                    #                         ),
                                                    #                         column(width = 6,
                                                    #                                hidden(selectInput(inputId = "socioDemographics_selectRegion2",
                                                    #                                                   label = "Region 2",
                                                    #                                                   choices = REGIONS_LIST_DROPDOWN_CHOICES,
                                                    #                                                   selected = 11001
                                                    #                                ))
                                                    #                         )
                                                    #                       ), br(),
                                                    #                       tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"), #hides minor ticks in slider input
                                                    #                       sliderInput(inputId = "socioDemographics_year", label = "Year", min = 2013, max = 2017, value = 2017, sep = "", width = 235),
                                                    #                       br(), br(),
                                                    #                       actionBttn(inputId = "socioDemographics_updateButton",
                                                    #                                  label = "Update",
                                                    #                                  style = "material-flat",
                                                    #                                  color = "danger"
                                                    #                       )
                                                    #                   )
                                                    #            ),
                                                    #            column(width = 6,
                                                    #                   box(width = 12,
                                                    #                       column(width = 6,
                                                    #                              leafletOutput(outputId = "sociodemographics_map1", height = 400)
                                                    #                       ),
                                                    #                       column(width = 6,
                                                    #                              leafletOutput(outputId = "sociodemographics_map2", height = 400)
                                                    #                       )
                                                    #                   )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(id = "sociodemographics_plots", width = 12,
                                                    #                box(width = 12,
                                                    #                    plotOutput(outputId = "sociodemographics_racePlot") %>%
                                                    #                      withSpinner(type = 6, color = "#76B7D2"),
                                                    #                    actionBttn(inputId = "dataInfo_racePlot",
                                                    #                               label = "Data Info",
                                                    #                               style = "minimal",
                                                    #                               color = "primary",
                                                    #                               size = "xs"
                                                    #                    )
                                                    #                ),
                                                    #                box(width = 12,
                                                    #                    plotOutput(outputId = "sociodemographics_educationPlot") %>%
                                                    #                      withSpinner(type = 6, color = "#76B7D2"),
                                                    #                    actionBttn(inputId = "dataInfo_educationPlot",
                                                    #                               label = "Data Info",
                                                    #                               style = "minimal",
                                                    #                               color = "primary",
                                                    #                               size = "xs"
                                                    #                    )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "sociodemographics_ethnicityPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_ethnicityPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "sociodemographics_foreignBornPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_foreignBornPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "sociodemographics_languagePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_languagePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "sociodemographics_medianAgePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_medianAgePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "sociodemographics_populationPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_populationPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(id = "economicResources_plots", width = 12,
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "economicResources_medianIncomePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_medianIncomePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "economicResources_unemploymentRatePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_unemploymentRatePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "economicResources_healthInsuranceCoveragePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_healthInsuranceCoveragePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "economicResources_belowPovertyLevelPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_belowPovertyLevelPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(id = "environmentalFactors_plots", width = 12,
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "environmentalFactors_airQualityIndexPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_airQualityIndexPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(id = "housingAndTransportation_plots", width = 12,
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "housingAndTransportation_vehiclesPerHousingUnitPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_vehiclesPerHousingUnitPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "housingAndTransportation_housingTenurePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_housingTenurePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "housingAndTransportation_rentGreaterThan30PercentOfHouseholdIncomePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_rentGreaterThan30PercentOfHouseholdIncomePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                )
                                                    #            )
                                                    #          ),
                                                    #          fluidRow(
                                                    #            box(id = "healthAndRiskBehaviors_plots", width = 12,
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_childrenEligibleForFreeLunchPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_childrenEligibleForFreeLunchPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_diabeticPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_diabeticPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_diabeticScreeningPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_diabeticScreeningPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_excessiveDrinkingPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_excessiveDrinkingPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_hivPrevalencePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_hivPrevalencePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_homicideRatePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_homicideRatePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_inadequateSocialSupportPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_inadequateSocialSupportPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_limitedAccessToHealthyFoodsPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_limitedAccessToHealthyFoodsPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_mammographyScreeningPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_mammographyScreeningPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_obesityPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_obesityPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_physicalInactivityPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_physicalInactivityPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_poorOrFairHealthPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_poorOrFairHealthPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_prematureMortalityRatePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_prematureMortalityRatePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_singleParentHouseholdsPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_singleParentHouseholdsPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                ),
                                                    #                fluidRow(
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_smokingPlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_smokingPlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  ),
                                                    #                  box(width = 6,
                                                    #                      plotOutput(outputId = "healthAndRiskBehaviors_violentCrimeRatePlot") %>%
                                                    #                        withSpinner(type = 6, color = "#76B7D2"),
                                                    #                      actionBttn(inputId = "dataInfo_violentCrimeRatePlot",
                                                    #                                 label = "Data Info",
                                                    #                                 style = "minimal",
                                                    #                                 color = "primary",
                                                    #                                 size = "xs"
                                                    #                      )
                                                    #                  )
                                                    #                )
                                                    #            )
                                                    #          )
                                                    # ),
                                                    # tabPanel(title = "DATA EXPLORER",
                                                    fluidRow(
                                                      column(
                                                        width = 4,
                                                        box(width = 12, title = tags$strong("Select Parameters"),
                                                            fluidRow(
                                                              column(width = 6,
                                                                     selectInput(inputId = "dataExplorer_variable1",
                                                                                 label = "Variable 1",
                                                                                 choices = CANCER_MAP_VARIABLE_CHOICES,
                                                                                 selected = "Incidence Rate"
                                                                     )
                                                              ),
                                                              column(width = 6,
                                                                     selectInput(inputId = "dataExplorer_subvariable1",
                                                                                 label = "Cancer",
                                                                                 choices = CANCERS_LIST,
                                                                                 selected = "All Cancers"
                                                                     )
                                                              )
                                                            ),
                                                            # actionBttn(inputId = "dataInfo_dataExplorer1Plot",
                                                            #            label = "Data Info for Variable 1",
                                                            #            style = "minimal",
                                                            #            color = "primary",
                                                            #            size = "xs"
                                                            # ), 
                                                            br(), br(), br(),
                                                            fluidRow(
                                                              column(width = 6,
                                                                     selectInput(inputId = "dataExplorer_variable2",
                                                                                 label = "Variable 2 (optional)",
                                                                                 choices = CANCER_MAP_VARIABLE_CHOICES,
                                                                                 selected = "Incidence Rate"
                                                                     )
                                                              ),
                                                              column(width = 6,
                                                                     selectInput(inputId = "dataExplorer_subvariable2",
                                                                                 label = "Cancer",
                                                                                 choices = CANCERS_LIST,
                                                                                 selected = "All Cancers"
                                                                     )
                                                              )
                                                            ),
                                                            # actionBttn(inputId = "dataInfo_dataExplorer2Plot",
                                                            #            label = "Data Info for Variable 2",
                                                            #            style = "minimal",
                                                            #            color = "primary",
                                                            #            size = "xs"
                                                            # ), 
                                                            br(), br(), br(),
                                                            radioButtons(inputId = "dataExplorer_plotTwoVariables",
                                                                         label = "Plot Type",
                                                                         choices = c("Plot just Variable 1" = FALSE, "Plot Variables 1 & 2" = TRUE),
                                                                         inline = TRUE
                                                            )
                                                        ),
                                                        # box(id = "dataExplorer_plot2_box", width = 12,
                                                        #     column(width = 7,
                                                        #            dygraphOutput(outputId = "dataExplorer_plot2") %>%
                                                        #              withSpinner(type = 6, color = "#76B7D2")
                                                        #     )
                                                        #     ,
                                                        #     column(width = 5,
                                                        #            textOutput(outputId = "dataExplorer_plot2_legend")
                                                        #     )
                                                        # ),
                                                        box(width = 12,
                                                            sliderInput(inputId = "dataExplorer_year_cancer",
                                                                        label = "Year",
                                                                        min = 2015,
                                                                        max = 2016,
                                                                        value = 2016,
                                                                        step = 1,
                                                                        sep = "",
                                                                        animate = animationOptions(interval = 1000),
                                                                        width = "120px"
                                                            ),
                                                            sliderInput(inputId = "dataExplorer_year_nonCancer",
                                                                        label = "Year",
                                                                        min = 2013,
                                                                        max = 2017,
                                                                        value = 2017,
                                                                        step = 1,
                                                                        sep = "",
                                                                        animate = animationOptions(interval = 1000),
                                                                        width = "300px"
                                                            ),
                                                            plotOutput(outputId = "dataExplorer_plot")
                                                        )
                                                      )
                                                    )
                                                    # )
                                                    # ,
                                                    # if(DEBUG_MODE) {
                                                    #   tabPanel(title = "Developer",
                                                    #            tabsetPanel(
                                                    #              tabPanel(title = "Backlog",
                                                    #                       includeHTML("www/developer/backlog.html")
                                                    #              ),
                                                    #              tabPanel(title = "Release Notes",
                                                    #                       h2(
                                                    #                         "Current Version: ",
                                                    #                         substr(x = getwd(), start = stri_locate_last_fixed(str = getwd(), pattern = "_v")[2] + 1, nchar(getwd()))
                                                    #                       ),
                                                    #                       includeHTML("www/developer/releaseNotes.html")
                                                    #              ),
                                                    #              tabPanel(title = "Dev Notes",
                                                    #                       includeHTML("www/developer/devNotes.html")
                                                    #              ),
                                                    #              tabPanel(title = "Project Architecture",
                                                    #                       img(src = "developer/projectArchitecture.png")
                                                    #              )
                                                    #            )
                                                    #   )
                                                    # } else {
                                                    #   # empty tab that gets hidden right away
                                                    #   # without it, tab id will mistakenly show in UI
                                                    #   tabPanel(title = "")
                                                    # }
                                        # )
                   )
)






server = function(input, output, session) {
  # Run Upon Load
  #####
  
  # hide elements
  elementsToHideUponLoad = c(
    # tab 1
    "cancerMap1_list",
    "cancerMap1_selectEducationCategory",
    "cancerMap1_selectEducationCategory",
    "cancerMap2_list",
    "cancerMap2_selectEducationCategory",
    "cancerMap2_selectEducationCategory",
    # tab 2
    "detailedCancerStatistics_map2",
    "detailedCancerStatistics_mortalityRatePlot",
    # tab 3
    "sociodemographics_map2",
    "economicResources_plots",
    "environmentalFactors_plots",
    "housingAndTransportation_plots",
    "healthAndRiskBehaviors_plots",
    # tab 4
    "dataExplorer_year_nonCancer"
  )
  
  for(x in elementsToHideUponLoad) {hide(id = x)}
  
  hideTab(inputId = "tabs", target = "")
  
  # generate tutorial gifs
  lapply(seq(LIST_OF_GIFS), function(i) {
    
    gif = LIST_OF_GIFS[i]
    
    output[[gif]]= renderImage(expr = {
      list(
        src = paste0("www/tutorial/", gif, ".gif"),
        contentType = "image/gif",
        width = 840,
        height = 400
      )
    }, deleteFile = FALSE)
    
  })
  
  #####
  
  # Cancer Maps
  #####
  
  # both cancer maps
  cancerMaps = reactiveValues(
    wardGranularity = FALSE,
    regionsLocked = FALSE,
    tooltipsActive = FALSE
  )
  
  observeEvent(eventExpr = input$cancerMap_wardGranularity, handlerExpr = {
    cancerMaps$wardGranularity = input$cancerMap_wardGranularity
    
    updateSelectInput(session = session, inputId = "cancerMap1_selectRegion", choices = if(cancerMaps$wardGranularity) {
      REGIONS_LIST_DROPDOWN_CHOICES
    } else {
      REGIONS_LIST_DROPDOWN_CHOICES_NO_WARDS
    })
    
    updateSelectInput(session = session, inputId = "cancerMap2_selectRegion", choices = if(cancerMaps$wardGranularity) {
      REGIONS_LIST_DROPDOWN_CHOICES
    } else {
      REGIONS_LIST_DROPDOWN_CHOICES_NO_WARDS
    })
    
  })
  
  observeEvent(eventExpr = input$cancerMap_lockRegions, handlerExpr = {
    cancerMaps$regionsLocked = input$cancerMap_lockRegions
    
    if(cancerMaps$regionsLocked & cancerMap1$regionName!=cancerMap2$regionName) {
      cancerMap2$regionName = REF_REGIONS$name[match(as.integer(input$cancerMap1_selectRegion), REF_REGIONS$id)]
      clickedRegionLines = GEOJSON_DMV[which(GEOJSON_DMV$name == cancerMap1$regionName),]
      
      #draw thick, gray border around region that is selected in dropdown
      leafletProxy(mapId = "cancerMap2") %>%
        addPolygons(
          data = clickedRegionLines,
          layerId = "temp",
          color = "#222",
          fill = FALSE,
          weight = 7
        )
      cancerMap2$result = updateMap2Result()
      
      updateSelectInput(
        session = session,
        inputId = "cancerMap2_selectRegion",
        selected = REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]
      )
    }
  })
  
  # just cancer map 1 (wards)
  cancerMap1 = reactiveValues(
    regionName = "GWCC Catchment Area",
    variable = "Incidence Rate",
    subVariable = "All Cancers",
    selectedCancer = "All Cancers", #this will be same as subVariable when
    #variable is either Incidence Rate or Mortality Rate
    variablePrefix = "All Cancers", # this is used in result and list view header
    labelSuffix = "", # this is used in region hover labels
    result = "NA out of 100,000",
    currentData = INCIDENCE_DATA %>%
      filter(year == 2016, cancer == "All Cancers", race == "All Races"),
    regionLabel = sprintf(
      "<strong>%s</strong><br/>%s",
      "ward 1", "Distr"
    ) %>% lapply(htmltools::HTML),
    legendTitle = HTML("Incidence Rate<br>per 100,000<br>population"),
    legendBins = c(0,259,235,369,404,Inf)
  )
  
  output$cancerMap1 = renderLeaflet(expr = {
    if(cancerMaps$wardGranularity) {
      geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
      geojsonModified$variable = cancerMap1$currentData %>% filter(! region %in% c(0,11001)) %>% select(rate)
    } else {
      geojsonModified = GEOJSON_DMV %>% filter(! region %in% 0:8)
      geojsonModified$variable = cancerMap1$currentData %>% filter(! region %in% 0:8) %>% select(rate)
    }
    geojsonModified$state = "District of Columbia"
    for(i in 1:length(geojsonModified$state)) {
      if(substr(geojsonModified$region[i], 1, 2) == 24) {
        geojsonModified$state[i] = "Maryland"
      } else if(substr(geojsonModified$region[i], 1, 2) == 51) {
        geojsonModified$state[i] = "Virginia"
      }
    }
    colorPalette = colorBin(palette = "YlOrRd", domain = geojsonModified$variable,
                            bins = cancerMap1$legendBins)
    if(cancerMap1$variable %in% c("Median Income")) {
      geojsonModified_variable_formatted = dollar(geojsonModified$variable[,1])
    } else if(cancerMap1$variable %in% c("Population")) {
      geojsonModified_variable_formatted = prettyNum(x = geojsonModified$variable[,1], big.mark = ",")
    } else {
      geojsonModified_variable_formatted = geojsonModified$variable[,1]
    }
    regionLabels = sprintf(
      "<strong>%s</strong><br/>%s%s",
      geojsonModified$name, geojsonModified_variable_formatted,
      cancerMap1$labelSuffix
    ) %>% lapply(htmltools::HTML)
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 9,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(cancerMap1$regionName,REF_REGIONS$name)],
      lng = REF_REGIONS$zoom_longitude[match(cancerMap1$regionName,REF_REGIONS$name)],
      zoom = REF_REGIONS$zoom_level[match(cancerMap1$regionName,REF_REGIONS$name)]
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = "gray",
      fillColor = ~colorPalette(variable[,1]),
      dashArray = "1",
      fillOpacity = 0.7,
      #hovering gives thick, gray border
      highlight = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE
      ),
      label = regionLabels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"
      ),
      layerId = geojsonModified$name,
      group = "click.list"
    ) %>% addLegend(
      pal = colorPalette,
      values = ~variable,
      opacity = 0.7,
      title = cancerMap1$legendTitle,
      position = "bottomleft",
      labFormat = labelFormat(suffix = cancerMap1$labelSuffix)
    )
  })
  
  output$cancerMap1_list = renderDT(expr = {
    regionsToInclude = if(cancerMaps$wardGranularity) {
      # include all regions
      match(REF_REGIONS$id, REF_REGIONS$id)
    } else {
      # exclude wards
      match((REF_REGIONS %>% filter(! id %in% 1:8) %>% select(id))$id, REF_REGIONS$id)
    }
    cancerMap1_currentData_modified = cancerMap1$currentData[regionsToInclude,] %>%
      mutate(Region = REF_REGIONS$name[regionsToInclude])
    listHeaderName = paste(cancerMap1$variablePrefix, cancerMap1$variable)
    cancerMap1_currentData_modified[[listHeaderName]] = cancerMap1_currentData_modified[["rate"]]
    
    cancerMap1_currentData_modified = cancerMap1_currentData_modified %>%
      select(Region, listHeaderName) %>%
      arrange(desc(UQS(syms(listHeaderName))))
    
    unformattedDatatable = datatable(
      data = cancerMap1_currentData_modified,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        lengthChange = FALSE,
        searching = FALSE
      )
      # ,
      # selection = list(
      #   mode = 'multiple', selected = c("Charles County"), target = 'row')
    )
    
    if(cancerMap1$variable %in% c("Population")) {
      # variables that need comma formatting
      unformattedDatatable %>%
        formatCurrency(columns = listHeaderName, currency = "", digits = 0)
    } else if(cancerMap1$variable %in% c("Median Income")) {
      # variables that need dollar formatting
      unformattedDatatable %>%
        formatCurrency(columns = listHeaderName, digits = 0)
    } else if(cancerMap1$variable %in% c("Incidence Rate", "Mortality Rate",
                                         "Median Age", "Air Quality Index")){
      # variables to leave as is
      unformattedDatatable
    } else {
      # all other variables need percent formatting
      unformattedDatatable %>%
        formatString(columns = listHeaderName, suffix = "%")
    }
    
  })
  
  output$cancerMap1_result = renderUI(expr = {
    sprintf(
      "<h4>%s %s in %s</h4><br>%s",
      if(cancerMap1$variable %in% c("Median Age", "Median Income",
                                    "Unemployment Rate", "Air Quality Index")) {
        ""
      } else {
        cancerMap1$variablePrefix  
      },
      cancerMap1$variable,
      cancerMap1$regionName,
      if(cancerMap1$variable %in% c("Population")) {
        cancerMap1$result %>% prettyNum(big.mark = ",")
      } else {
        cancerMap1$result
      }
    ) %>% lapply(htmltools::HTML)
  })
  
  updateMap1LegendBins = reactive(x = {
    if(cancerMap1$variable == "Incidence Rate") {
      # percentile splits
      LEGEND_BINS_LOOKUP_INCIDENCE[[cancerMap1$subVariable]]
    } else if(cancerMap1$variable == "Mortality Rate") {
      # percentile splits
      LEGEND_BINS_LOOKUP_MORTALITY[[cancerMap1$subVariable]]
    } else if(cancerMap1$variable == "Median Age") {
      # eyeball split
      c(0,20,30,40,50,Inf)
      # quantile(MEDIAN_AGE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap1$variable == "Median Income") {
      # eyeball split
      c(0,70000,90000,100000,110000,Inf)
      # quantile(MEDIAN_INCOME_DATA %>% select(rate), probs = c(0.2,0.4,0.6,0.8), na.rm = TRUE)
    } else if(cancerMap1$variable == "Population") {
      # eyeball split
      c(0,250000,500000,750000,1000000,Inf)
      # POPULATION_DATA$rate %>% sort()
    } else if(cancerMap1$variable == "Unemployment Rate") {
      # eyeball split
      c(0,5,10,15,20,Inf)
      # quantile(UNEMPLOYMENT_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap1$variable == "Air Quality Index") {
      # eyeball split
      c(0,30,35,40,45,Inf)
      # quantile(AIR_QUALITY_INDEX_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap1$variable == "HIV Prevalence") {
      # eyeball split
      c(0,200,400,600,800,Inf)
      # quantile(HIV_PREVALENCE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap1$variable == "Homicide Rate") {
      # eyeball split
      c(0,2,4,6,8,Inf)
      # quantile(HOMICIDE_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap1$variable == "Violent Crime Rate") {
      # eyeball split
      c(0,150,300,450,600,Inf)
      # quantile(VIOLENT_CRIME_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else {
      # even split for all variables
      c(0,20,40,60,80,100)
    }
  })
  
  updateMap1Result = reactive(x = {
    if(cancerMap1$variable %in% c("Incidence Rate", "Mortality Rate", "HIV Prevalence", "Homicide Rate",
                                  "Premature Mortality Rate", "Violent Crime Rate")) {
      x = cancerMap1$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      paste0(x, " out of 100,000")
    } else if(cancerMap1$variable %in% c("Below Poverty Level", "Educational Attainment",
                                         "Ethnicity", "Foreign-Born", "Health Insurance Coverage",
                                         "Housing Tenure", "Main Language Spoken at Home",
                                         "Race", "Rent > 30% of Household Income", "Unemployment Rate",
                                         "Vehicles Per Housing Unit", "% Children Eligible for Free Lunch",
                                         "% Diabetic", "% Diabetic Screening",
                                         "% Excessive Drinking", "% Inadequate Social Support",
                                         "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                         "% Poor/Fair Health", "% Physically Inactive",
                                         "% Single-Parent Households", "% Smoking")) {
      x = cancerMap1$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      paste0(x, "%")
    } else if(cancerMap1$variable %in% c("Median Age", "Air Quality Index", "Population")) {
      x = cancerMap1$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      x
    } else if(cancerMap1$variable %in% c("Median Income")) {
      x = cancerMap1$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      dollar(x$rate)
    } else {
      NULL
      #continue here...
    }
  })
  
  observeEvent(eventExpr = input$cancerMap1_selectRegion, handlerExpr = {
    # print(input$cancerMap1_selectRegion)
    # print(REF_REGIONS$name[match(as.integer(input$cancerMap1_selectRegion), REF_REGIONS$id)])
    cancerMap1$regionName = REF_REGIONS$name[match(as.integer(input$cancerMap1_selectRegion), REF_REGIONS$id)]
    clickedRegionLines = GEOJSON_DMV[which(GEOJSON_DMV$name == cancerMap1$regionName),]
    
    #draw thick, gray border around region that is selected in dropdown
    leafletProxy(mapId = "cancerMap1") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    cancerMap1$result = updateMap1Result()
    
    if(cancerMaps$regionsLocked) {
      cancerMap2$regionName = REF_REGIONS$name[match(as.integer(input$cancerMap1_selectRegion), REF_REGIONS$id)]
      clickedRegionLines = GEOJSON_DMV[which(GEOJSON_DMV$name == cancerMap2$regionName),]
      
      #draw thick, gray border around region that is selected in dropdown
      leafletProxy(mapId = "cancerMap2") %>%
        addPolygons(
          data = clickedRegionLines,
          layerId = "temp",
          color = "#222",
          fill = FALSE,
          weight = 7
        )
      cancerMap2$result = updateMap2Result()
      
      updateSelectInput(
        session = session,
        inputId = "cancerMap2_selectRegion",
        selected = REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]
      )
    }
  })
  
  observeEvent(eventExpr = input$cancerMap1_selectVariable, handlerExpr = {
    # update reactive
    cancerMap1$variable = input$cancerMap1_selectVariable
    
    # filter relevant data subset for this variable
    if(cancerMap1$variable == "Incidence Rate") {
      cancerMap1$currentData = INCIDENCE_DATA %>%
        filter(year == 2016, cancer == cancerMap1$subVariable, race == "All Races")
      cancerMap1$legendTitle = HTML("Incidence Rate<br>per 100,000<br>population")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = cancerMap1$selectedCancer)
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = ""
    } else if(cancerMap1$variable == "Mortality Rate") {
      cancerMap1$currentData = MORTALITY_DATA %>%
        filter(year == 2016, cancer == cancerMap1$subVariable, race == "All Races")
      cancerMap1$legendTitle = HTML("Mortality Rate<br>per 100,000<br>population")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = cancerMap1$selectedCancer)
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = ""
    } else if(cancerMap1$variable == "Educational Attainment") {
      cancerMap1$currentData = EDUCATION_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Educational<br>Attainment")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = EDUCATION_CATEGORIES_LIST,
                        selected = EDUCATION_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Ethnicity") {
      cancerMap1$currentData = ETHNICITY_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Ethnicity")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = ETHNICITY_CATEGORIES_LIST,
                        selected = ETHNICITY_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Foreign-Born") {
      cancerMap1$currentData = FOREIGN_BORN_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Foreign-Born")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = FOREIGN_BORN_CATEGORIES_LIST,
                        selected = FOREIGN_BORN_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Main Language Spoken at Home") {
      cancerMap1$currentData = LANGUAGE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Main Language Spoken at Home")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = LANGUAGE_CATEGORIES_LIST,
                        selected = LANGUAGE_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Median Age") {
      cancerMap1$currentData = MEDIAN_AGE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Median Age")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Race") {
      cancerMap1$currentData = RACE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Race")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = RACE_CATEGORIES_LIST,
                        selected = RACE_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Median Income") {
      cancerMap1$currentData = MEDIAN_INCOME_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Median Income")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Population") {
      cancerMap1$currentData = POPULATION_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Population")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Unemployment Rate") {
      cancerMap1$currentData = UNEMPLOYMENT_RATE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Unemployment Rate")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Air Quality Index") {
      cancerMap1$currentData = AIR_QUALITY_INDEX_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Air Quality Index")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Vehicles Per Housing Unit") {
      cancerMap1$currentData = VEHICLES_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Vehicles per<br>Housing Unit")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = VEHICLES_CATEGORIES_LIST,
                        selected = VEHICLES_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Health Insurance Coverage") {
      cancerMap1$currentData = HEALTH_INSURANCE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Health Insurance<br>Coverage")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = HEALTH_INSURANCE_CATEGORIES_LIST,
                        selected = HEALTH_INSURANCE_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Housing Tenure") {
      cancerMap1$currentData = HOUSING_TENURE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
      cancerMap1$legendTitle = HTML("Housing Tenure")
      updateSelectInput(session = session,
                        inputId = "cancerMap1_selectSubvariable",
                        label = "Category",
                        choices = HOUSING_TENURE_CATEGORIES_LIST,
                        selected = HOUSING_TENURE_CATEGORIES_LIST[1])
      show(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = cancerMap1$subVariable
      cancerMap1$labelSuffix = "%"
    } else if(cancerMap1$variable == "Below Poverty Level") {
      cancerMap1$currentData = BELOW_POVERTY_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Below<br>Poverty Level")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Rent > 30% of Household Income") {
      cancerMap1$currentData = RENT_GREATER_THAN_30_INCOME_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Rent > 30% of<br>Household Income")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Children Eligible for Free Lunch") {
      cancerMap1$currentData = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% of Children<br>Eligible for Free Lunch")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Diabetic") {
      cancerMap1$currentData = DIABETIC_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Diabetic")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Diabetic Screening") {
      cancerMap1$currentData = DIABETIC_SCREENING_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Diabetic Screening")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Excessive Drinking") {
      cancerMap1$currentData = EXCESSIVE_DRINKING_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Excessive<br>Drinking")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "HIV Prevalence") {
      cancerMap1$currentData = HIV_PREVALENCE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("HIV Prevalence")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Homicide Rate") {
      cancerMap1$currentData = HOMICIDE_RATE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Homicide Rate")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Inadequate Social Support") {
      cancerMap1$currentData = INADEQUATE_SOCIAL_SUPPORT_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Inadequate<br>Social Support")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Limited Access to Healthy Foods") {
      cancerMap1$currentData = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Limited Access to<br>Healthy Foods")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Mammography Screening") {
      cancerMap1$currentData = MAMMOGRAPHY_SCREENING_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Mammography<br>Screening")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Obesity") {
      cancerMap1$currentData = OBESITY_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Obesity")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Poor/Fair Health") {
      cancerMap1$currentData = POOR_OR_FAIR_HEALTH_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Poor or<br>Fair Health")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Physically Inactive") {
      cancerMap1$currentData = PHYSICAL_INACTIVITY_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Physically Inactive")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Premature Mortality Rate") {
      cancerMap1$currentData = PREMATURE_MORTALITY_RATE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Premature Mortality Rate")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Single-Parent Households") {
      cancerMap1$currentData = SINGLE_PARENT_HOUSEHOLD_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% of Households<br>with Single Parents")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "% Smoking") {
      cancerMap1$currentData = SMOKING_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("% Smoking")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = "%"
      # cancerMap1$subVariable = ""
    } else if(cancerMap1$variable == "Violent Crime Rate") {
      cancerMap1$currentData = VIOLENT_CRIME_RATE_DATA %>%
        filter(year == 2016)
      cancerMap1$legendTitle = HTML("Violent Crime Rate")
      hide(id = "cancerMap1_selectSubvariable")
      cancerMap1$variablePrefix = ""
      cancerMap1$labelSuffix = ""
      # cancerMap1$subVariable = ""
    } else {
      NULL
      # continue here...
    }
    
    # adjust legend bins based on type of cancer rate and type of cancer
    cancerMap1$legendBins = updateMap1LegendBins()
    
    #draw thick, gray border around region that is clicked on
    #this part not working
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    clickedRegionLines = geojsonModified[which(geojsonModified$name == cancerMap1$regionName),]
    leafletProxy(mapId = "cancerMap1") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    # print(clickedRegionLines)
    cancerMap1$result = updateMap1Result()
  })
  
  observeEvent(eventExpr = input$cancerMap1_selectSubvariable, handlerExpr = {
    # update reactives
    cancerMap1$subVariable = input$cancerMap1_selectSubvariable
    cancerMap1$variablePrefix = cancerMap1$subVariable
    
    # filter relevant data subset for this subvariable
    cancerMap1$currentData = if(cancerMap1$variable == "Incidence Rate") {
      cancerMap1$selectedCancer = cancerMap1$subVariable
      INCIDENCE_DATA %>%
        filter(year == 2016, cancer == cancerMap1$subVariable, race == "All Races")
    } else if(cancerMap1$variable == "Mortality Rate") {
      cancerMap1$selectedCancer = cancerMap1$subVariable
      MORTALITY_DATA %>%
        filter(year == 2016, cancer == cancerMap1$subVariable, race == "All Races")
    } else if(cancerMap1$variable == "Educational Attainment") {
      EDUCATION_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Ethnicity") {
      ETHNICITY_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Foreign-Born") {
      FOREIGN_BORN_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Main Language Spoken at Home") {
      LANGUAGE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Race") {
      RACE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Vehicles Per Housing Unit") {
      VEHICLES_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Health Insurance Coverage") {
      HEALTH_INSURANCE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else if(cancerMap1$variable == "Housing Tenure") {
      HOUSING_TENURE_DATA %>%
        filter(year == 2016, category == cancerMap1$subVariable)
    } else {
      NULL
      # continue here...
    }
    
    # adjust legend bins based on type of cancer rate and type of cancer
    cancerMap1$legendBins = updateMap1LegendBins()
    
    cancerMap1$result = updateMap1Result()
  })
  
  observeEvent(eventExpr = input$cancerMap1_mapView, handlerExpr = {
    hide(id = "cancerMap1_list")
    show(id = "cancerMap1")
  })
  
  observeEvent(eventExpr = input$cancerMap1_listView, handlerExpr = {
    hide(id = "cancerMap1")
    show(id = "cancerMap1_list")
  })
  
  observeEvent(eventExpr = input$cancerMap1_shape_click, handlerExpr = {
    # print(input$cancerMap1_shape_click$id)
    # print(input$cancerMap1_shape_click)
    # print(input$cancerMap1_shape_click$group)
    # print(clicked)
    cancerMap1$regionName = input$cancerMap1_shape_click$id
    updateSelectInput(
      session = session,
      inputId = "cancerMap1_selectRegion",
      selected = REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]
    )
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    clickedRegionLines = geojsonModified[which(geojsonModified$name == cancerMap1$regionName),]
    
    #draw thick, gray border around region that is clicked on
    leafletProxy(mapId = "cancerMap1") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    cancerMap1$result = updateMap1Result()
    # print(clickedRegionLines@data$id)
    # print(GEOJSON_DMV)
  })
  
  observeEvent(eventExpr = input$dataInfo_cancerMap1, handlerExpr = {
    messageToShow = if(cancerMap1$variable %in% c("Incidence Rate","Mortality Rate")) {
      DATA_INFO_MESSAGE_LIST[1]
    } else if(cancerMap1$variable %in% c("Air Quality Index")) {
      DATA_INFO_MESSAGE_LIST[3]
    } else if(cancerMap1$variable %in% c("% Children Eligible for Free Lunch", "% Diabetic", "% Diabetic Screening",
                                         "% Excessive Drinking", "HIV Prevalence", "Homicide Rate", "% Inadequate Social Support",
                                         "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                         "% Poor/Fair Health", "% Physically Inactive", "Premature Mortality Rate",
                                         "% Single-Parent Households", "% Smoking", "Violent Crime Rate")) {
      DATA_INFO_MESSAGE_LIST[5]
    } else {
      DATA_INFO_MESSAGE_LIST[2]
    }
    
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0(cancerMap1$variable, messageToShow) %>% lapply(htmltools::HTML)
    ))
  })
  
  # just cancer map 2
  cancerMap2 = reactiveValues(
    regionName = "GWCC Catchment Area",
    variable = "Incidence Rate",
    subVariable = "All Cancers",
    selectedCancer = "All Cancers", #this will be same as subVariable when
    #variable is either Incidence Rate or Mortality Rate
    variablePrefix = "All Cancers", # this is used in result and list view header
    labelSuffix = "", # this is used in region hover labels
    result = "NA out of 100,000",
    currentData = INCIDENCE_DATA %>%
      filter(year == 2016, cancer == "All Cancers", race == "All Races"),
    regionLabel = sprintf(
      "<strong>%s</strong><br/>%s",
      "ward 1", "Distr"
    ) %>% lapply(htmltools::HTML),
    legendTitle = HTML("Incidence Rate<br>per 100,000<br>population"),
    legendBins = c(0,259,235,369,404,Inf)
  )
  
  output$cancerMap2 = renderLeaflet(expr = {
    if(cancerMaps$wardGranularity) {
      geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
      geojsonModified$variable = cancerMap2$currentData %>% filter(! region %in% c(0,11001)) %>% select(rate)
    } else {
      geojsonModified = GEOJSON_DMV %>% filter(! region %in% 0:8)
      geojsonModified$variable = cancerMap2$currentData %>% filter(! region %in% 0:8) %>% select(rate)
    }
    geojsonModified$state = "District of Columbia"
    for(i in 1:length(geojsonModified$state)) {
      if(geojsonModified$region[i] >= 13) {
        geojsonModified$state[i] = "Maryland"
      } else if(geojsonModified$region[i] >= 9) {
        geojsonModified$state[i] = "Virginia"
      }
    }
    colorPalette = colorBin(palette = "YlOrRd", domain = geojsonModified$variable,
                            bins = cancerMap2$legendBins)
    if(cancerMap2$variable %in% c("Median Income")) {
      geojsonModified_variable_formatted = dollar(geojsonModified$variable[,1])
    } else if(cancerMap2$variable %in% c("Population")) {
      geojsonModified_variable_formatted = prettyNum(x = geojsonModified$variable[,1], big.mark = ",")
    } else {
      geojsonModified_variable_formatted = geojsonModified$variable[,1]
    }
    regionLabels = sprintf(
      "<strong>%s</strong><br/>%s%s",
      geojsonModified$name, geojsonModified_variable_formatted,
      cancerMap2$labelSuffix
    ) %>% lapply(htmltools::HTML)
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 9,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(cancerMap2$regionName,REF_REGIONS$name)],
      lng = REF_REGIONS$zoom_longitude[match(cancerMap2$regionName,REF_REGIONS$name)],
      zoom = REF_REGIONS$zoom_level[match(cancerMap2$regionName,REF_REGIONS$name)]
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = "gray",
      fillColor = ~colorPalette(variable[,1]),
      dashArray = "1",
      fillOpacity = 0.7,
      #hovering gives thick, gray border
      highlight = highlightOptions(
        weight = 5,
        color = "#666",
        dashArray = "",
        fillOpacity = 0.7,
        bringToFront = TRUE
      ),
      label = regionLabels,
      labelOptions = labelOptions(
        style = list("font-weight" = "normal", padding = "3px 8px"),
        textsize = "15px",
        direction = "auto"
      ),
      layerId = geojsonModified$name,
      group = "click.list"
    ) %>% addLegend(
      pal = colorPalette,
      values = ~variable,
      opacity = 0.7,
      title = cancerMap2$legendTitle,
      position = "bottomleft",
      labFormat = labelFormat(suffix = cancerMap2$labelSuffix)
    )
  })
  
  output$cancerMap2_list = renderDT(expr = {
    regionsToInclude = if(cancerMaps$wardGranularity) {
      # include all regions
      match(REF_REGIONS$id, REF_REGIONS$id)
    } else {
      # exclude wards
      match((REF_REGIONS %>% filter(! id %in% 1:8) %>% select(id))$id, REF_REGIONS$id)
    }
    cancerMap2_currentData_modified = cancerMap2$currentData[regionsToInclude,] %>%
      mutate(Region = REF_REGIONS$name[regionsToInclude])
    listHeaderName = paste(cancerMap2$variablePrefix, cancerMap2$variable)
    cancerMap2_currentData_modified[[listHeaderName]] = cancerMap2_currentData_modified[["rate"]]
    cancerMap2_currentData_modified = cancerMap2_currentData_modified %>%
      select(Region, listHeaderName) %>%
      arrange(desc(UQS(syms(listHeaderName))))
    
    unformattedDatatable = datatable(
      data = cancerMap2_currentData_modified,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        lengthChange = FALSE,
        searching = FALSE
      )
      # ,
      # selection = list(
      #   mode = 'multiple', selected = c("Charles County"), target = 'row')
    )
    
    if(cancerMap2$variable %in% c("Population")) {
      # variables that need comma formatting
      unformattedDatatable %>%
        formatCurrency(columns = listHeaderName, currency = "", digits = 0)
    } else if(cancerMap2$variable %in% c("Median Income")) {
      # variables that need dollar formatting
      unformattedDatatable %>%
        formatCurrency(columns = listHeaderName, digits = 0)
    } else if(cancerMap2$variable %in% c("Incidence Rate", "Mortality Rate",
                                         "Median Age", "Air Quality Index")){
      # variables to leave as is
      unformattedDatatable
    } else {
      # all other variables need percent formatting
      unformattedDatatable %>%
        formatString(columns = listHeaderName, suffix = "%")
    }
    
  })
  
  output$cancerMap2_result = renderUI(expr = {
    sprintf(
      "<h4>%s %s in %s</h4><br>%s",
      if(cancerMap2$variable %in% c("Median Age", "Median Income",
                                    "Unemployment Rate", "Air Quality Index")) {
        ""
      } else {
        cancerMap2$variablePrefix  
      },
      cancerMap2$variable,
      cancerMap2$regionName,
      if(cancerMap2$variable %in% c("Population")) {
        cancerMap2$result %>% prettyNum(big.mark = ",")
      } else {
        cancerMap2$result
      }
    ) %>% lapply(htmltools::HTML)
  })
  
  updateMap2LegendBins = reactive(x = {
    if(cancerMap2$variable == "Incidence Rate") {
      # percentile splits
      LEGEND_BINS_LOOKUP_INCIDENCE[[cancerMap2$subVariable]]
    } else if(cancerMap2$variable == "Mortality Rate") {
      # percentile splits
      LEGEND_BINS_LOOKUP_MORTALITY[[cancerMap2$subVariable]]
    } else if(cancerMap2$variable == "Median Age") {
      # eyeball split
      c(0,20,30,40,50,Inf)
      # quantile(MEDIAN_AGE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap2$variable == "Median Income") {
      # eyeball split
      c(0,70000,90000,100000,110000,Inf)
      # quantile(MEDIAN_INCOME_DATA %>% select(rate), probs = c(0.2,0.4,0.6,0.8), na.rm = TRUE)
    } else if(cancerMap2$variable == "Population") {
      # eyeball split
      c(0,250000,500000,750000,1000000,Inf)
      # POPULATION_DATA$rate %>% sort()
    } else if(cancerMap2$variable == "Unemployment Rate") {
      # eyeball split
      c(0,5,10,15,20,Inf)
      # quantile(UNEMPLOYMENT_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap2$variable == "Air Quality Index") {
      # eyeball split
      c(0,30,35,40,45,Inf)
      # quantile(AIR_QUALITY_INDEX_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap2$variable == "HIV Prevalence") {
      # eyeball split
      c(0,200,400,600,800,Inf)
      # quantile(HIV_PREVALENCE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap2$variable == "Homicide Rate") {
      # eyeball split
      c(0,2,4,6,8,Inf)
      # quantile(HOMICIDE_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else if(cancerMap2$variable == "Violent Crime Rate") {
      # eyeball split
      c(0,150,300,450,600,Inf)
      # quantile(VIOLENT_CRIME_RATE_DATA%>%select(rate),probs=c(.2,.4,.6,.8),na.rm = TRUE)
    } else {
      # even split for all variables
      c(0,20,40,60,80,100)
    }
  })
  
  updateMap2Result = reactive(x = {
    if(cancerMap2$variable %in% c("Incidence Rate", "Mortality Rate", "HIV Prevalence", "Homicide Rate",
                                  "Premature Mortality Rate", "Violent Crime Rate")) {
      x = cancerMap2$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      paste0(x, " out of 100,000")
    } else if(cancerMap2$variable %in% c("Below Poverty Level", "Educational Attainment",
                                         "Ethnicity", "Foreign-Born", "Health Insurance Coverage",
                                         "Housing Tenure", "Main Language Spoken at Home",
                                         "Race", "Rent > 30% of Household Income", "Unemployment Rate",
                                         "Vehicles Per Housing Unit", "% Children Eligible for Free Lunch",
                                         "% Diabetic", "% Diabetic Screening",
                                         "% Excessive Drinking", "% Inadequate Social Support",
                                         "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                         "% Poor/Fair Health", "% Physically Inactive",
                                         "% Single-Parent Households", "% Smoking")) {
      x = cancerMap2$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      paste0(x, "%")
    } else if(cancerMap2$variable %in% c("Median Age", "Air Quality Index", "Population")) {
      x = cancerMap2$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      x
    } else if(cancerMap2$variable %in% c("Median Income")) {
      x = cancerMap2$currentData %>%
        filter(region == REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]) %>%
        select(rate)
      dollar(x$rate)
    } else {
      NULL
      #continue here...
    }
  })
  
  observeEvent(eventExpr = input$cancerMap2_selectRegion, handlerExpr = {
    # print(input$cancerMap2_selectRegion)
    # print(REF_REGIONS$name[match(as.integer(input$cancerMap2_selectRegion), REF_REGIONS$id)])
    cancerMap2$regionName = REF_REGIONS$name[match(as.integer(input$cancerMap2_selectRegion), REF_REGIONS$id)]
    clickedRegionLines = GEOJSON_DMV[which(GEOJSON_DMV$name == cancerMap2$regionName),]
    
    #draw thick, gray border around region that is selected in dropdown
    leafletProxy(mapId = "cancerMap2") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    cancerMap2$result = updateMap2Result()
    
    if(cancerMaps$regionsLocked) {
      cancerMap1$regionName = REF_REGIONS$name[match(as.integer(input$cancerMap2_selectRegion), REF_REGIONS$id)]
      clickedRegionLines = GEOJSON_DMV[which(GEOJSON_DMV$name == cancerMap1$regionName),]
      
      #draw thick, gray border around region that is selected in dropdown
      leafletProxy(mapId = "cancerMap1") %>%
        addPolygons(
          data = clickedRegionLines,
          layerId = "temp",
          color = "#222",
          fill = FALSE,
          weight = 7
        )
      cancerMap1$result = updateMap1Result()
      
      updateSelectInput(
        session = session,
        inputId = "cancerMap1_selectRegion",
        selected = REF_REGIONS$id[match(cancerMap1$regionName, REF_REGIONS$name)]
      )
    }
  })
  
  observeEvent(eventExpr = input$cancerMap2_selectVariable, handlerExpr = {
    # update reactive
    cancerMap2$variable = input$cancerMap2_selectVariable
    
    # filter relevant data subset for this variable
    if(cancerMap2$variable == "Incidence Rate") {
      cancerMap2$currentData = INCIDENCE_DATA %>%
        filter(year == 2016, cancer == cancerMap2$subVariable, race == "All Races")
      cancerMap2$legendTitle = HTML("Incidence Rate<br>per 100,000<br>population")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = cancerMap2$selectedCancer)
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = ""
    } else if(cancerMap2$variable == "Mortality Rate") {
      cancerMap2$currentData = MORTALITY_DATA %>%
        filter(year == 2016, cancer == cancerMap2$subVariable, race == "All Races")
      cancerMap2$legendTitle = HTML("Mortality Rate<br>per 100,000<br>population")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = cancerMap2$selectedCancer)
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = ""
    } else if(cancerMap2$variable == "Educational Attainment") {
      cancerMap2$currentData = EDUCATION_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Educational<br>Attainment")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = EDUCATION_CATEGORIES_LIST,
                        selected = EDUCATION_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Ethnicity") {
      cancerMap2$currentData = ETHNICITY_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Ethnicity")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = ETHNICITY_CATEGORIES_LIST,
                        selected = ETHNICITY_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Foreign-Born") {
      cancerMap2$currentData = FOREIGN_BORN_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Foreign-Born")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = FOREIGN_BORN_CATEGORIES_LIST,
                        selected = FOREIGN_BORN_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Main Language Spoken at Home") {
      cancerMap2$currentData = LANGUAGE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Main Language Spoken at Home")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = LANGUAGE_CATEGORIES_LIST,
                        selected = LANGUAGE_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Median Age") {
      cancerMap2$currentData = MEDIAN_AGE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Median Age")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Race") {
      cancerMap2$currentData = RACE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Race")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = RACE_CATEGORIES_LIST,
                        selected = RACE_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Median Income") {
      cancerMap2$currentData = MEDIAN_INCOME_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Median Income")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Population") {
      cancerMap2$currentData = POPULATION_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Population")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Unemployment Rate") {
      cancerMap2$currentData = UNEMPLOYMENT_RATE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Unemployment Rate")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Air Quality Index") {
      cancerMap2$currentData = AIR_QUALITY_INDEX_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Air Quality Index")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Vehicles Per Housing Unit") {
      cancerMap2$currentData = VEHICLES_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Vehicles per<br>Housing Unit")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = VEHICLES_CATEGORIES_LIST,
                        selected = VEHICLES_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Health Insurance Coverage") {
      cancerMap2$currentData = HEALTH_INSURANCE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Health Insurance<br>Coverage")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = HEALTH_INSURANCE_CATEGORIES_LIST,
                        selected = HEALTH_INSURANCE_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Housing Tenure") {
      cancerMap2$currentData = HOUSING_TENURE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
      cancerMap2$legendTitle = HTML("Housing Tenure")
      updateSelectInput(session = session,
                        inputId = "cancerMap2_selectSubvariable",
                        label = "Category",
                        choices = HOUSING_TENURE_CATEGORIES_LIST,
                        selected = HOUSING_TENURE_CATEGORIES_LIST[1])
      show(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = cancerMap2$subVariable
      cancerMap2$labelSuffix = "%"
    } else if(cancerMap2$variable == "Below Poverty Level") {
      cancerMap2$currentData = BELOW_POVERTY_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Below<br>Poverty Level")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Rent > 30% of Household Income") {
      cancerMap2$currentData = RENT_GREATER_THAN_30_INCOME_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Rent > 30% of<br>Household Income")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Children Eligible for Free Lunch") {
      cancerMap2$currentData = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% of Children<br>Eligible for Free Lunch")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Diabetic") {
      cancerMap2$currentData = DIABETIC_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Diabetic")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Diabetic Screening") {
      cancerMap2$currentData = DIABETIC_SCREENING_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Diabetic Screening")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Excessive Drinking") {
      cancerMap2$currentData = EXCESSIVE_DRINKING_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Excessive<br>Drinking")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "HIV Prevalence") {
      cancerMap2$currentData = HIV_PREVALENCE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("HIV Prevalence")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Homicide Rate") {
      cancerMap2$currentData = HOMICIDE_RATE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Homicide Rate")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Inadequate Social Support") {
      cancerMap2$currentData = INADEQUATE_SOCIAL_SUPPORT_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Inadequate<br>Social Support")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Limited Access to Healthy Foods") {
      cancerMap2$currentData = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Limited Access to<br>Healthy Foods")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Mammography Screening") {
      cancerMap2$currentData = MAMMOGRAPHY_SCREENING_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Mammography<br>Screening")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Obesity") {
      cancerMap2$currentData = OBESITY_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Obesity")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Poor/Fair Health") {
      cancerMap2$currentData = POOR_OR_FAIR_HEALTH_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Poor or<br>Fair Health")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Physically Inactive") {
      cancerMap2$currentData = PHYSICAL_INACTIVITY_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Physically Inactive")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Premature Mortality Rate") {
      cancerMap2$currentData = PREMATURE_MORTALITY_RATE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Premature Mortality Rate")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Single-Parent Households") {
      cancerMap2$currentData = SINGLE_PARENT_HOUSEHOLD_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% of Households<br>with Single Parents")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "% Smoking") {
      cancerMap2$currentData = SMOKING_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("% Smoking")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = "%"
      # cancerMap2$subVariable = ""
    } else if(cancerMap2$variable == "Violent Crime Rate") {
      cancerMap2$currentData = VIOLENT_CRIME_RATE_DATA %>%
        filter(year == 2016)
      cancerMap2$legendTitle = HTML("Violent Crime Rate")
      hide(id = "cancerMap2_selectSubvariable")
      cancerMap2$variablePrefix = ""
      cancerMap2$labelSuffix = ""
      # cancerMap2$subVariable = ""
    } else {
      NULL
      # continue here...
    }
    
    # adjust legend bins based on type of cancer rate and type of cancer
    cancerMap2$legendBins = updateMap2LegendBins()
    
    #draw thick, gray border around region that is clicked on
    #this part not working
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    clickedRegionLines = geojsonModified[which(geojsonModified$name == cancerMap2$regionName),]
    leafletProxy(mapId = "cancerMap2") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    # print(clickedRegionLines)
    cancerMap2$result = updateMap2Result()
  })
  
  observeEvent(eventExpr = input$cancerMap2_selectSubvariable, handlerExpr = {
    # update reactives
    cancerMap2$subVariable = input$cancerMap2_selectSubvariable
    cancerMap2$variablePrefix = cancerMap2$subVariable
    
    # filter relevant data subset for this subvariable
    cancerMap2$currentData = if(cancerMap2$variable == "Incidence Rate") {
      cancerMap2$selectedCancer = cancerMap2$subVariable
      INCIDENCE_DATA %>%
        filter(year == 2016, cancer == cancerMap2$subVariable, race == "All Races")
    } else if(cancerMap2$variable == "Mortality Rate") {
      cancerMap2$selectedCancer = cancerMap2$subVariable
      MORTALITY_DATA %>%
        filter(year == 2016, cancer == cancerMap2$subVariable, race == "All Races")
    } else if(cancerMap2$variable == "Educational Attainment") {
      EDUCATION_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Ethnicity") {
      ETHNICITY_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Foreign-Born") {
      FOREIGN_BORN_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Main Language Spoken at Home") {
      LANGUAGE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Race") {
      RACE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Vehicles Per Housing Unit") {
      VEHICLES_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Health Insurance Coverage") {
      HEALTH_INSURANCE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else if(cancerMap2$variable == "Housing Tenure") {
      HOUSING_TENURE_DATA %>%
        filter(year == 2016, category == cancerMap2$subVariable)
    } else {
      NULL
      # continue here...
    }
    
    # adjust legend bins based on type of cancer rate and type of cancer
    cancerMap2$legendBins = updateMap2LegendBins()
    
    cancerMap2$result = updateMap2Result()
  })
  
  observeEvent(eventExpr = input$cancerMap2_mapView, handlerExpr = {
    hide(id = "cancerMap2_list")
    show(id = "cancerMap2")
  })
  
  observeEvent(eventExpr = input$cancerMap2_listView, handlerExpr = {
    hide(id = "cancerMap2")
    show(id = "cancerMap2_list")
  })
  
  observeEvent(eventExpr = input$cancerMap2_shape_click, handlerExpr = {
    # print(input$cancerMap2_shape_click$id)
    # print(input$cancerMap2_shape_click)
    # print(input$cancerMap2_shape_click$group)
    # print(clicked)
    cancerMap2$regionName = input$cancerMap2_shape_click$id
    updateSelectInput(
      session = session,
      inputId = "cancerMap2_selectRegion",
      selected = REF_REGIONS$id[match(cancerMap2$regionName, REF_REGIONS$name)]
    )
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    clickedRegionLines = geojsonModified[which(geojsonModified$name == cancerMap2$regionName),]
    
    #draw thick, gray border around region that is clicked on
    leafletProxy(mapId = "cancerMap2") %>%
      addPolygons(
        data = clickedRegionLines,
        layerId = "temp",
        color = "#222",
        fill = FALSE,
        weight = 7
      )
    cancerMap2$result = updateMap2Result()
    # print(clickedRegionLines@data$id)
    # print(GEOJSON_DMV)
  })
  
  observeEvent(eventExpr = input$dataInfo_cancerMap2, handlerExpr = {
    messageToShow = if(cancerMap2$variable %in% c("Incidence Rate","Mortality Rate")) {
      DATA_INFO_MESSAGE_LIST[1]
    } else if(cancerMap2$variable %in% c("Air Quality Index")) {
      DATA_INFO_MESSAGE_LIST[3]
    } else if(cancerMap2$variable %in% c("% Children Eligible for Free Lunch", "% Diabetic", "% Diabetic Screening",
                                         "% Excessive Drinking", "HIV Prevalence", "Homicide Rate", "% Inadequate Social Support",
                                         "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                         "% Poor/Fair Health", "% Physically Inactive", "Premature Mortality Rate",
                                         "% Single-Parent Households", "% Smoking", "Violent Crime Rate")) {
      DATA_INFO_MESSAGE_LIST[5]
    } else {
      DATA_INFO_MESSAGE_LIST[2]
    }
    
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0(cancerMap2$variable, messageToShow) %>% lapply(htmltools::HTML)
    ))
  })
  #####
  
  # Detailed Cancer Statistics - Top-Level
  #####
  detailedCancerStatistics = reactiveValues(
    comparisonType = 1,
    cancerTypes = c("All Cancers","All Cancers"),
    regions = c(11001,11001),
    raceEthnicity = c("All Races"),
    raceEthnicityCache = c("All Races"),
    year = 2016,
    mapColors = list(
      MAP_COLORS[[10]],
      MAP_COLORS[[10]]
    )
  )
  
  output$detailedCancerStatistics_sidebar = renderUI(expr = {
    lapply(seq(DETAILED_CANCER_STATISTICS_CATEGORIES), function(i) {
      fluidRow(
        actionBttn(inputId = paste0("detailedCancerStatistics", i),
                   label = DETAILED_CANCER_STATISTICS_CATEGORIES[i],
                   style = "minimal",
                   color = "success",
                   size = "md",
                   block = TRUE
        )
      )
    })
  })
  #####
  
  # Detailed Cancer Statistics - Mini-Map
  #####
  output$detailedCancerStatistics_map1 = renderLeaflet(expr = {
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 8,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)],
      lng = REF_REGIONS$zoom_longitude[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)],
      zoom = REF_REGIONS$zoom_level[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)] - 1
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = detailedCancerStatistics$mapColors[[1]],
      dashArray = "1",
      fillOpacity = 0.7
    )
  })
  
  output$detailedCancerStatistics_map2 = renderLeaflet(expr = {
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 8,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(detailedCancerStatistics$regions[2], REF_REGIONS$id)],
      lng = REF_REGIONS$zoom_longitude[match(detailedCancerStatistics$regions[2], REF_REGIONS$id)],
      zoom = REF_REGIONS$zoom_level[match(detailedCancerStatistics$regions[2], REF_REGIONS$id)] - 1
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = detailedCancerStatistics$mapColors[[2]],
      dashArray = "1",
      fillOpacity = 0.7
    )
  })
  #####
  
  # Detailed Cancer Statistics - Incidence Rate Plot
  #####
  incidenceRate = reactiveValues(
    dataSubset1 = INCIDENCE_DATA %>%
      filter(year == 2016, region == 11001, cancer == "All Cancers", race == "All Races") %>%
      mutate(dataSubset = 1),
    dataSubset2 = INCIDENCE_DATA %>%
      filter(year == 2016, region == 11001, cancer == "All Cancers", race == "All Races") %>%
      mutate(dataSubset = 2)
  )
  
  output$detailedCancerStatistics_incidenceRatePlot = renderPlot(expr = {
    if(detailedCancerStatistics$comparisonType == 1) {
      # 1 cancer, 1 region
      annotation_1 = if(is.na(incidenceRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 1, y = 350, size = 6)
      } else{
        NULL
      }
      
      ggplot(data = incidenceRate$dataSubset1, aes(x = race, y = rate)) +
        geom_bar(stat = "identity", fill = "turquoise3") +
        geom_text(
          mapping = aes(y = rate+20, label = rate)
        ) +
        labs(title = paste("Incidence Rate for", detailedCancerStatistics$cancerTypes[1]),
             subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)
        ) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        annotation_1
      
    } else if(detailedCancerStatistics$comparisonType == 2) {
      
      # 2 cancers, 1 region
      annotation_1 = if(is.na(incidenceRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this cancer type", x = 0.75, y = 350, size = 6)
      } else{
        NULL
      }
      
      annotation_2 = if(is.na(incidenceRate$dataSubset2$rate)) {
        annotate(geom = "text", label = "Not available for this cancer type", x = 1.25, y = 350, size = 6)
      } else{
        NULL
      }
      
      x = rbind(incidenceRate$dataSubset1, incidenceRate$dataSubset2)
      # x$cancer = factor(x$cancer, levels = c(toString(x$cancer[2]), toString(x$cancer[1])))
      ggplot(data = x, aes(x = race, y = rate, fill = as.factor(dataSubset))) +
        geom_bar(stat = "identity", position = "dodge") +
        geom_text(
          mapping = aes(x = race, y = rate+30, label = rate, group = dataSubset),
          position = position_dodge(width = 0.9)
        ) +
        labs(
          title = paste0("Incidence Rates for ", REF_REGIONS$name[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)]),
          subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)
        ) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        scale_fill_discrete(
          name = "Cancer",
          labels = rev(detailedCancerStatistics$cancerTypes),
          breaks = c(2,1)
        ) +
        annotation_1 +
        annotation_2
    } else {
      # 1 cancer, 2 regions
      annotation_1 = if(is.na(incidenceRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 0.75, y = 350, size = 6)
      } else{
        NULL
      }
      annotation_2 = if(is.na(incidenceRate$dataSubset2$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 1.25, y = 350, size = 6)
      } else{
        NULL
      }
      
      x = rbind(incidenceRate$dataSubset1, incidenceRate$dataSubset2)
      ggplot(data = x, aes(x = race, y = rate, fill = as.factor(dataSubset))) +
        geom_bar(stat = "identity", position = "dodge") +
        geom_text(
          mapping = aes(x = race, y = rate+30, label = rate, group = dataSubset),
          position = position_dodge(width = 0.9)
        ) +
        labs(title = paste0("Incidence Rates for ", detailedCancerStatistics$cancerTypes[1]),
             subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        scale_fill_discrete(
          name = "Region",
          labels = rev(REF_REGIONS$name[match(detailedCancerStatistics$regions, REF_REGIONS$id)]),
          breaks = c(2,1)
        ) +
        annotation_1 +
        annotation_2
    }
  })
  
  #####
  
  # Detailed Cancer Statistics - Mortality Rate Plot
  #####
  mortalityRate = reactiveValues(
    dataSubset1 = MORTALITY_DATA %>%
      filter(year == 2016, region == 11001, cancer == "All Cancers", race == "All Races") %>%
      mutate(dataSubset = 1),
    dataSubset2 = MORTALITY_DATA %>%
      filter(year == 2016, region == 11001, cancer == "All Cancers", race == "All Races") %>%
      mutate(dataSubset = 2)
  )
  
  output$detailedCancerStatistics_mortalityRatePlot = renderPlot(expr = {
    if(detailedCancerStatistics$comparisonType == 1) {
      # 1 cancer, 1 region
      annotation_1 = if(is.na(mortalityRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 1, y = 350, size = 6)
      } else{
        NULL
      }
      
      ggplot(data = mortalityRate$dataSubset1, aes(x = race, y = rate)) +
        geom_bar(stat = "identity", fill = "turquoise3") +
        geom_text(
          mapping = aes(y = rate+20, label = rate)
        ) +
        labs(title = paste("Mortality Rate for", detailedCancerStatistics$cancerTypes[1]),
             subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        annotation_1
    } else if(detailedCancerStatistics$comparisonType == 2) {
      # 2 cancers, 1 region
      annotation_1 = if(is.na(mortalityRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this cancer type", x = 0.75, y = 350, size = 6)
      } else{
        NULL
      }
      annotation_2 = if(is.na(mortalityRate$dataSubset2$rate)) {
        annotate(geom = "text", label = "Not available for this cancer type", x = 1.25, y = 350, size = 6)
      } else{
        NULL
      }
      
      x = rbind(mortalityRate$dataSubset1, mortalityRate$dataSubset2)
      ggplot(data = x, aes(x = race, y = rate, fill = as.factor(dataSubset))) +
        geom_bar(stat = "identity", position = "dodge") +
        geom_text(
          mapping = aes(x = race, y = rate+30, label = rate, group = dataSubset),
          position = position_dodge(width = 0.9)
        ) +
        labs(
          title = paste0("Mortality Rates for ", REF_REGIONS$name[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)]),
          subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)
        ) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        scale_fill_discrete(
          name = "Cancer",
          labels = detailedCancerStatistics$cancerTypes
        ) +
        annotation_1 +
        annotation_2
    } else {
      # 1 cancer, 2 regions
      annotation_1 = if(is.na(mortalityRate$dataSubset1$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 0.75, y = 350, size = 6)
      } else{
        NULL
      }
      annotation_2 = if(is.na(mortalityRate$dataSubset2$rate)) {
        annotate(geom = "text", label = "Not available for this region", x = 1.25, y = 350, size = 6)
      } else{
        NULL
      }
      
      x = rbind(mortalityRate$dataSubset1, mortalityRate$dataSubset2)
      ggplot(data = x, aes(x = race, y = rate, fill = as.factor(dataSubset))) +
        geom_bar(stat = "identity", position = "dodge") +
        geom_text(
          mapping = aes(x = race, y = rate+30, label = rate, group = dataSubset),
          position = position_dodge(width = 0.9)
        ) +
        labs(title = paste0("Mortality Rates for ", detailedCancerStatistics$cancerTypes[1]),
             subtitle = paste0(as.integer(detailedCancerStatistics$year) - 4, "-", detailedCancerStatistics$year)) +
        xlab(label = "Race & Ethnicity Group") +
        ylab(label = "Average Annual Age Adjusted Rate per 100,000") +
        coord_flip() +
        theme(axis.ticks.y = element_blank()) +
        scale_y_continuous(limits = c(0,700), breaks = 0:7*100, labels = 0:7*100) +
        scale_fill_discrete(
          name = "Region",
          labels = REF_REGIONS$name[match(detailedCancerStatistics$regions, REF_REGIONS$id)]
        ) +
        annotation_1 +
        annotation_2
    }
  })
  #####
  
  # Detailed Cancer Statistics - Observers
  #####
  observeEvent(eventExpr = input$detailedCancerStatistics1, handlerExpr = {
    hide(id = "detailedCancerStatistics_mortalityRatePlot")
    show(id = "detailedCancerStatistics_incidenceRatePlot")
  })
  
  observeEvent(eventExpr = input$detailedCancerStatistics2, handlerExpr = {
    hide(id = "detailedCancerStatistics_incidenceRatePlot")
    show(id = "detailedCancerStatistics_mortalityRatePlot")
  })
  
  observeEvent(eventExpr = input$detailedCancerStatistics_comparisonType, handlerExpr = {
    if(input$detailedCancerStatistics_comparisonType == 1) {
      hide(id = "detailedCancerStatistics_selectCancer2")
      hide(id = "detailedCancerStatistics_selectRegion2")
      hide(id = "detailedCancerStatistics_map2")
    } else if(input$detailedCancerStatistics_comparisonType == 2) {
      show(id = "detailedCancerStatistics_selectCancer2")
      hide(id = "detailedCancerStatistics_selectRegion2")
      hide(id = "detailedCancerStatistics_map2")
    } else {
      hide(id = "detailedCancerStatistics_selectCancer2")
      show(id = "detailedCancerStatistics_selectRegion2")
      show(id = "detailedCancerStatistics_map2")
    }
  })
  
  observeEvent(eventExpr = input$detailedCancerStatistics_raceEthnicity, handlerExpr = {
    if(is.null(input$detailedCancerStatistics_raceEthnicity)) {
      updateCheckboxGroupInput(session = session, inputId = "detailedCancerStatistics_raceEthnicity",
                               selected = detailedCancerStatistics$raceEthnicityCache)
    } else {
      detailedCancerStatistics$raceEthnicityCache = input$detailedCancerStatistics_raceEthnicity
    }
  }, ignoreNULL = FALSE)
  
  observeEvent(eventExpr = input$detailedCancerStatistics_updateButton, handlerExpr = {
    if(all(
      detailedCancerStatistics$comparisonType == as.integer(input$detailedCancerStatistics_comparisonType),
      detailedCancerStatistics$cancerTypes == c(
        input$detailedCancerStatistics_selectCancer1,
        input$detailedCancerStatistics_selectCancer2
      ),
      detailedCancerStatistics$regions == c(
        input$detailedCancerStatistics_selectRegion1,
        input$detailedCancerStatistics_selectRegion2
      ),
      detailedCancerStatistics$raceEthnicity == input$detailedCancerStatistics_raceEthnicity,
      detailedCancerStatistics$year == input$detailedCancerStatistics_year
    )) {
      NULL
    } else {
      detailedCancerStatistics$comparisonType = as.integer(input$detailedCancerStatistics_comparisonType)
      detailedCancerStatistics$cancerTypes = c(
        input$detailedCancerStatistics_selectCancer1,
        input$detailedCancerStatistics_selectCancer2
      )
      detailedCancerStatistics$regions = as.integer(c(
        input$detailedCancerStatistics_selectRegion1,
        input$detailedCancerStatistics_selectRegion2
      ))
      detailedCancerStatistics$raceEthnicity = input$detailedCancerStatistics_raceEthnicity
      detailedCancerStatistics$year = input$detailedCancerStatistics_year
      detailedCancerStatistics$mapColors = list(
        MAP_COLORS[[match(detailedCancerStatistics$regions[1], REF_REGIONS$id)]],
        MAP_COLORS[[match(detailedCancerStatistics$regions[2], REF_REGIONS$id)]]
      )
      
      incidenceRate$dataSubset1 = INCIDENCE_DATA %>%
        filter(
          year == detailedCancerStatistics$year,
          region == detailedCancerStatistics$regions[1],
          cancer == detailedCancerStatistics$cancerTypes[1],
          race %in% detailedCancerStatistics$raceEthnicity
        ) %>%
        mutate(dataSubset = 1)
      
      incidenceRate$dataSubset2 = INCIDENCE_DATA %>%
        filter(
          year == detailedCancerStatistics$year,
          region == detailedCancerStatistics$regions[
            if(detailedCancerStatistics$comparisonType == 3) {2} else {1}
            ],
          cancer == detailedCancerStatistics$cancerTypes[
            if(detailedCancerStatistics$comparisonType == 2) {2} else {1}
            ],
          race %in% detailedCancerStatistics$raceEthnicity
        ) %>%
        mutate(dataSubset = 2)
      
      mortalityRate$dataSubset1 = MORTALITY_DATA %>%
        filter(
          year == detailedCancerStatistics$year,
          region == detailedCancerStatistics$regions[1],
          cancer == detailedCancerStatistics$cancerTypes[1],
          race %in% detailedCancerStatistics$raceEthnicity
        ) %>%
        mutate(dataSubset = 1)
      
      mortalityRate$dataSubset2 = MORTALITY_DATA %>%
        filter(
          year == detailedCancerStatistics$year,
          region == detailedCancerStatistics$regions[
            if(detailedCancerStatistics$comparisonType == 3) {2} else {1}
            ],
          cancer == detailedCancerStatistics$cancerTypes[
            if(detailedCancerStatistics$comparisonType == 2) {2} else {1}
            ],
          race %in% detailedCancerStatistics$raceEthnicity
        ) %>%
        mutate(dataSubset = 2)
    }
  })
  
  observeEvent(eventExpr = input$dataInfo_incidenceRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Incidence Rate", DATA_INFO_MESSAGE_LIST[1]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_mortalityRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Mortality Rate", DATA_INFO_MESSAGE_LIST[1]) %>% lapply(htmltools::HTML)
    ))
  })
  #####
  
  # Risk and Protective Factors - Top-Level
  #####
  riskAndProtectiveFactors = reactiveValues(
    year = 2017,
    compareTwoRegions = FALSE,
    regions = c(11001,11001),
    mapColors = list(
      MAP_COLORS[[10]],
      MAP_COLORS[[10]]
    )
  )
  
  output$riskAndProtectiveFactors_sidebar = renderUI(expr = {
    lapply(seq(RISK_AND_PROTECTIVE_FACTORS_CATEGORIES), function(i) {
      fluidRow(
        actionBttn(inputId = paste0("riskAndProtectiveFactors", i),
                   label = RISK_AND_PROTECTIVE_FACTORS_CATEGORIES[i],
                   style = "minimal",
                   color = "success",
                   size = "md",
                   block = TRUE,
        )
      )
    })
  })
  #####
  
  # Risk and Protective Factors - Mini-Map
  #####
  output$sociodemographics_map1 = renderLeaflet(expr = {
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 8,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(riskAndProtectiveFactors$regions[1], REF_REGIONS$id)],
      lng = REF_REGIONS$zoom_longitude[match(riskAndProtectiveFactors$regions[1], REF_REGIONS$id)],
      zoom = REF_REGIONS$zoom_level[match(riskAndProtectiveFactors$regions[1], REF_REGIONS$id)] - 1
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = riskAndProtectiveFactors$mapColors[[1]],
      dashArray = "1",
      fillOpacity = 0.7
    )
  })
  
  output$sociodemographics_map2 = renderLeaflet(expr = {
    geojsonModified = GEOJSON_DMV %>% filter(! region %in% c(0,11001))
    
    leaflet(
      data = geojsonModified,
      options = leafletOptions(
        attributionControl = FALSE,
        minZoom = 8,
        maxZoom = 14
      )
    ) %>% setView(
      lat = REF_REGIONS$zoom_latitude[match(riskAndProtectiveFactors$regions[2], REF_REGIONS$id)],
      lng = REF_REGIONS$zoom_longitude[match(riskAndProtectiveFactors$regions[2], REF_REGIONS$id)],
      zoom = REF_REGIONS$zoom_level[match(riskAndProtectiveFactors$regions[2], REF_REGIONS$id)] - 1
    ) %>% addProviderTiles("MapBox",
                           options = providerTileOptions(
                             id = "mapbox.light",
                             accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')
                           )
    ) %>% addPolygons(
      weight = 2,
      opacity = 1,
      color = riskAndProtectiveFactors$mapColors[[2]],
      dashArray = "1",
      fillOpacity = 0.7
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Race Plot
  #####
  race = reactiveValues(
    dataSubset1 = RACE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = RACE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_racePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = race$dataSubset1,
      dataSubset2 = race$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      plotTitle = "Race",
      plotType = 1,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Education Plot
  #####
  education = reactiveValues(
    dataSubset1 = EDUCATION_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = EDUCATION_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_educationPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = education$dataSubset1,
      dataSubset2 = education$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      plotTitle = "Educational Attainment",
      plotType = 1,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Ethnicity Plot
  #####
  ethnicity = reactiveValues(
    dataSubset1 = ETHNICITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = ETHNICITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_ethnicityPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = ethnicity$dataSubset1,
      dataSubset2 = ethnicity$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "ethnicity",
      plotTitle = "Ethnicity",
      plotType = 2,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Foreign-Born Plot
  #####
  foreignBorn = reactiveValues(
    dataSubset1 = FOREIGN_BORN_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = FOREIGN_BORN_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_foreignBornPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = foreignBorn$dataSubset1,
      dataSubset2 = foreignBorn$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "foreignBorn",
      plotTitle = "Foreign-Born",
      plotType = 2,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Language Plot
  #####
  language = reactiveValues(
    dataSubset1 = LANGUAGE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = LANGUAGE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_languagePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = language$dataSubset1,
      dataSubset2 = language$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "language",
      plotTitle = "Main Language Spoken at Home",
      plotType = 2,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Median Age Plot
  #####
  medianAge = reactiveValues(
    dataSubset1 = MEDIAN_AGE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = MEDIAN_AGE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_medianAgePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = medianAge$dataSubset1,
      dataSubset2 = medianAge$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "medianAge",
      plotTitle = "Median Age",
      plotType = 3,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Socio Demographics - Population Plot
  #####
  population = reactiveValues(
    dataSubset1 = POPULATION_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = POPULATION_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$sociodemographics_populationPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = population$dataSubset1,
      dataSubset2 = population$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "population",
      plotTitle = "Population",
      plotType = if(riskAndProtectiveFactors$compareTwoRegions) {
        if(0 %in% riskAndProtectiveFactors$regions) {
          # if comparing 2 regions, check if DMV is one of them
          12
        } else {
          11
        }
      } else {
        if(match(riskAndProtectiveFactors$regions[1], REF_REGIONS$id) == 0) {
          # if plotting just 1 region, check if it is DMV
          12
        } else {
          11
        }
      },
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Economic Resources - Median Household Income Plot
  #####
  medianIncome = reactiveValues(
    dataSubset1 = MEDIAN_INCOME_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = MEDIAN_INCOME_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$economicResources_medianIncomePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = medianIncome$dataSubset1,
      dataSubset2 = medianIncome$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "medianIncome",
      plotTitle = "Median Income",
      plotType = 4,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Economic Resources - Unemployment Rate Plot
  #####
  unemploymentRate = reactiveValues(
    dataSubset1 = UNEMPLOYMENT_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = UNEMPLOYMENT_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$economicResources_unemploymentRatePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = unemploymentRate$dataSubset1,
      dataSubset2 = unemploymentRate$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "unemploymentRate",
      plotTitle = "Unemployment Rate",
      plotType = 5,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Economic Resources - Health Insurance Coverage Plot
  #####
  healthInsuranceCoverage = reactiveValues(
    dataSubset1 = HEALTH_INSURANCE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = HEALTH_INSURANCE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$economicResources_healthInsuranceCoveragePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = healthInsuranceCoverage$dataSubset1,
      dataSubset2 = healthInsuranceCoverage$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "healthInsuranceCoverage",
      plotTitle = "Health Insurance Coverage",
      plotType = 1,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Environmental Factors - Air Quality Index Plot
  #####
  airQualityIndex = reactiveValues(
    dataSubset1 = AIR_QUALITY_INDEX_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = AIR_QUALITY_INDEX_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$environmentalFactors_airQualityIndexPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = airQualityIndex$dataSubset1,
      dataSubset2 = airQualityIndex$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "airQualityIndex",
      plotTitle = "Air Quality Index",
      plotType = 6,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Housing & Transportation - Vehicles Per Housing Unit Plot
  #####
  vehiclesPerHousingUnit = reactiveValues(
    dataSubset1 = VEHICLES_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = VEHICLES_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$housingAndTransportation_vehiclesPerHousingUnitPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = vehiclesPerHousingUnit$dataSubset1,
      dataSubset2 = vehiclesPerHousingUnit$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      plotTitle = "Vehicles per Housing Unit",
      plotType = 1,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Economic Resources - Below Poverty Level Plot
  #####
  belowPovertyLevel = reactiveValues(
    dataSubset1 = BELOW_POVERTY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = BELOW_POVERTY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$economicResources_belowPovertyLevelPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = belowPovertyLevel$dataSubset1,
      dataSubset2 = belowPovertyLevel$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "belowPovertyLevel",
      plotTitle = "Below Poverty Level",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Housing & Transportation - Housing Tenure Plot
  #####
  housingTenure = reactiveValues(
    dataSubset1 = HOUSING_TENURE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = HOUSING_TENURE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$housingAndTransportation_housingTenurePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = housingTenure$dataSubset1,
      dataSubset2 = housingTenure$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "housingTenure",
      plotTitle = "Housing Tenure",
      plotType = 2,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Housing & Transportation - Rent Greater Than 30% of Household Income Plot
  #####
  rentGreaterThan30PercentOfHouseholdIncome = reactiveValues(
    dataSubset1 = RENT_GREATER_THAN_30_INCOME_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = RENT_GREATER_THAN_30_INCOME_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$housingAndTransportation_rentGreaterThan30PercentOfHouseholdIncomePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = rentGreaterThan30PercentOfHouseholdIncome$dataSubset1,
      dataSubset2 = rentGreaterThan30PercentOfHouseholdIncome$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "rentGreaterThan30PercentOfHouseholdIncome",
      plotTitle = "Rent Greater Than 30% of Household Income",
      plotType = 8,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - Children Eligible for Free Lunch
  #####
  childrenEligibleForFreeLunch = reactiveValues(
    dataSubset1 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_childrenEligibleForFreeLunchPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = childrenEligibleForFreeLunch$dataSubset1,
      dataSubset2 = childrenEligibleForFreeLunch$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "childrenEligibleForFreeLunch",
      plotTitle = "% of Children Eligible for Free Lunch",
      plotType = 8,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Diabetic
  #####
  diabetic = reactiveValues(
    dataSubset1 = DIABETIC_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = DIABETIC_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_diabeticPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = diabetic$dataSubset1,
      dataSubset2 = diabetic$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "diabetic",
      plotTitle = "% Diabetic",
      plotType = 5,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Diabetic Screening
  #####
  diabeticScreening = reactiveValues(
    dataSubset1 = DIABETIC_SCREENING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = DIABETIC_SCREENING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_diabeticScreeningPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = diabeticScreening$dataSubset1,
      dataSubset2 = diabeticScreening$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "diabeticScreening",
      plotTitle = "% Diabetic Screening",
      plotType = 9,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Excessive Drinking
  #####
  excessiveDrinking = reactiveValues(
    dataSubset1 = EXCESSIVE_DRINKING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = EXCESSIVE_DRINKING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_excessiveDrinkingPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = excessiveDrinking$dataSubset1,
      dataSubset2 = excessiveDrinking$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "excessiveDrinking",
      plotTitle = "% Excessive Drinking",
      plotType = 5,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - HIV Prevalence
  #####
  hivPrevalance = reactiveValues(
    dataSubset1 = HIV_PREVALENCE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = HIV_PREVALENCE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_hivPrevalencePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = hivPrevalance$dataSubset1,
      dataSubset2 = hivPrevalance$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "hivPrevalance",
      plotTitle = "HIV Prevalance",
      plotType = 10,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - Homicide Rate
  #####
  homicideRate = reactiveValues(
    dataSubset1 = HOMICIDE_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = HOMICIDE_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_homicideRatePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = homicideRate$dataSubset1,
      dataSubset2 = homicideRate$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "homicideRate",
      plotTitle = "Homicide Rate",
      plotType = 3,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Inadequate Social Support
  #####
  inadequateSocialSupport = reactiveValues(
    dataSubset1 = INADEQUATE_SOCIAL_SUPPORT_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = INADEQUATE_SOCIAL_SUPPORT_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_inadequateSocialSupportPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = inadequateSocialSupport$dataSubset1,
      dataSubset2 = inadequateSocialSupport$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "inadequateSocialSupport",
      plotTitle = "% Inadequate Social Support",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - Limited Access to Healthy Foods
  #####
  limitedAccessToHealthyFoods = reactiveValues(
    dataSubset1 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_limitedAccessToHealthyFoodsPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = limitedAccessToHealthyFoods$dataSubset1,
      dataSubset2 = limitedAccessToHealthyFoods$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "limitedAccessToHealthyFoods",
      plotTitle = "% Limited Access to Healthy Foods",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Mammography Screening
  #####
  mammographyScreening = reactiveValues(
    dataSubset1 = MAMMOGRAPHY_SCREENING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = MAMMOGRAPHY_SCREENING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_mammographyScreeningPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = mammographyScreening$dataSubset1,
      dataSubset2 = mammographyScreening$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "mammographyScreening",
      plotTitle = "% Mammography Screening",
      plotType = 8,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Obesity
  #####
  obesity = reactiveValues(
    dataSubset1 = OBESITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = OBESITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_obesityPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = obesity$dataSubset1,
      dataSubset2 = obesity$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "obesity",
      plotTitle = "% Obesity",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Physically Inactive
  #####
  physicallyInactive = reactiveValues(
    dataSubset1 = PHYSICAL_INACTIVITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = PHYSICAL_INACTIVITY_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_physicalInactivityPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = physicallyInactive$dataSubset1,
      dataSubset2 = physicallyInactive$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "physicallyInactive",
      plotTitle = "% Physically Inactive",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Poor/Fair Health
  #####
  poorOrFairHealth = reactiveValues(
    dataSubset1 = POOR_OR_FAIR_HEALTH_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = POOR_OR_FAIR_HEALTH_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_poorOrFairHealthPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = poorOrFairHealth$dataSubset1,
      dataSubset2 = poorOrFairHealth$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "poorOrFairHealth",
      plotTitle = "% of Poor or Fair Health",
      plotType = 7,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - Premature Mortality Rate
  #####
  prematureMortalityRate = reactiveValues(
    dataSubset1 = PREMATURE_MORTALITY_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = PREMATURE_MORTALITY_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_prematureMortalityRatePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = prematureMortalityRate$dataSubset1,
      dataSubset2 = prematureMortalityRate$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "prematureMortalityRate",
      plotTitle = "Premature Mortality Rate",
      plotType = 10,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Single-Parent Households
  #####
  singleParentHouseholds = reactiveValues(
    dataSubset1 = SINGLE_PARENT_HOUSEHOLD_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = SINGLE_PARENT_HOUSEHOLD_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_singleParentHouseholdsPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = singleParentHouseholds$dataSubset1,
      dataSubset2 = singleParentHouseholds$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "singleParentHouseholds",
      plotTitle = "% of Single-Parent Households",
      plotType = 8,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - % Smoking
  #####
  smoking = reactiveValues(
    dataSubset1 = SMOKING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = SMOKING_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_smokingPlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = smoking$dataSubset1,
      dataSubset2 = smoking$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "smoking",
      plotTitle = "% Smokers",
      plotType = 5,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Health & Risk Behaviors - Violent Crime Rate
  #####
  violentCrimeRate = reactiveValues(
    dataSubset1 = VIOLENT_CRIME_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "1"),
    dataSubset2 = VIOLENT_CRIME_RATE_DATA %>% filter(year == 2017, region == 11001) %>%
      mutate(dataSubset = "2")
  )
  
  output$healthAndRiskBehaviors_violentCrimeRatePlot = renderPlot(expr = {
    createPlot_riskAndProtectiveFactors(
      dataSubset1 = violentCrimeRate$dataSubset1,
      dataSubset2 = violentCrimeRate$dataSubset2,
      compareTwoRegions = riskAndProtectiveFactors$compareTwoRegions,
      variable = "violentCrimeRate",
      plotTitle = "Violent Crime Rate",
      plotType = 10,
      year = riskAndProtectiveFactors$year,
      regionsIndices = match(riskAndProtectiveFactors$regions, REF_REGIONS$id)
    )
  })
  #####
  
  # Risk and Protective Factors - Observers
  #####
  observeEvent(eventExpr = input$riskAndProtectiveFactors1, handlerExpr = {
    hide(id = "economicResources_plots")
    hide(id = "environmentalFactors_plots")
    hide(id = "housingAndTransportation_plots")
    hide(id = "healthAndRiskBehaviors_plots")
    show(id = "sociodemographics_plots")
  })
  
  observeEvent(eventExpr = input$riskAndProtectiveFactors2, handlerExpr = {
    hide(id = "sociodemographics_plots")
    hide(id = "environmentalFactors_plots")
    hide(id = "housingAndTransportation_plots")
    hide(id = "healthAndRiskBehaviors_plots")
    show(id = "economicResources_plots")
  })
  
  observeEvent(eventExpr = input$riskAndProtectiveFactors3, handlerExpr = {
    hide(id = "sociodemographics_plots")
    hide(id = "economicResources_plots")
    hide(id = "housingAndTransportation_plots")
    hide(id = "healthAndRiskBehaviors_plots")
    show(id = "environmentalFactors_plots")
  })
  
  observeEvent(eventExpr = input$riskAndProtectiveFactors4, handlerExpr = {
    hide(id = "sociodemographics_plots")
    hide(id = "economicResources_plots")
    hide(id = "environmentalFactors_plots")
    hide(id = "healthAndRiskBehaviors_plots")
    show(id = "housingAndTransportation_plots")
  })
  
  observeEvent(eventExpr = input$riskAndProtectiveFactors5, handlerExpr = {
    hide(id = "sociodemographics_plots")
    hide(id = "economicResources_plots")
    hide(id = "environmentalFactors_plots")
    hide(id = "housingAndTransportation_plots")
    show(id = "healthAndRiskBehaviors_plots")
  })
  
  observeEvent(eventExpr = input$socioDemographics_compareTwoRegions, handlerExpr = {
    if(input$socioDemographics_compareTwoRegions) {
      show(id = "socioDemographics_selectRegion2")
      show(id = "sociodemographics_map2")
    } else {
      hide(id = "socioDemographics_selectRegion2")
      hide(id = "sociodemographics_map2")
    }
  })
  
  observeEvent(eventExpr = input$socioDemographics_updateButton, handlerExpr = {
    if(all(
      riskAndProtectiveFactors$year == input$socioDemographics_year,
      riskAndProtectiveFactors$compareTwoRegions == input$socioDemographics_compareTwoRegions,
      riskAndProtectiveFactors$regions == c(input$socioDemographics_selectRegion1, input$socioDemographics_selectRegion2)
    )) {
      NULL
    } else {
      # update variables that affect both 1- and 2-region plots
      riskAndProtectiveFactors$year = input$socioDemographics_year
      riskAndProtectiveFactors$compareTwoRegions = input$socioDemographics_compareTwoRegions
      riskAndProtectiveFactors$regions = c(as.numeric(input$socioDemographics_selectRegion1), as.numeric(input$socioDemographics_selectRegion2))
      riskAndProtectiveFactors$mapColors = mapColors = list(
        MAP_COLORS[[match(riskAndProtectiveFactors$regions[1], REF_REGIONS$id)]],
        MAP_COLORS[[match(riskAndProtectiveFactors$regions[2], REF_REGIONS$id)]]
      )
      
      race$dataSubset1 = RACE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      race$dataSubset2 = RACE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      education$dataSubset1 = EDUCATION_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      education$dataSubset2 = EDUCATION_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      ethnicity$dataSubset1 = ETHNICITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      ethnicity$dataSubset2 = ETHNICITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      foreignBorn$dataSubset1 = FOREIGN_BORN_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      foreignBorn$dataSubset2 = FOREIGN_BORN_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      language$dataSubset1 = LANGUAGE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      language$dataSubset2 = LANGUAGE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      medianAge$dataSubset1 = MEDIAN_AGE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      medianAge$dataSubset2 = MEDIAN_AGE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      medianIncome$dataSubset1 = MEDIAN_INCOME_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      medianIncome$dataSubset2 = MEDIAN_INCOME_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      unemploymentRate$dataSubset1 = UNEMPLOYMENT_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      unemploymentRate$dataSubset2 = UNEMPLOYMENT_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      airQualityIndex$dataSubset1 = AIR_QUALITY_INDEX_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      airQualityIndex$dataSubset2 = AIR_QUALITY_INDEX_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      vehiclesPerHousingUnit$dataSubset1 = VEHICLES_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      vehiclesPerHousingUnit$dataSubset2 = VEHICLES_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      healthInsuranceCoverage$dataSubset1 = HEALTH_INSURANCE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      healthInsuranceCoverage$dataSubset2 = HEALTH_INSURANCE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      housingTenure$dataSubset1 = HOUSING_TENURE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      housingTenure$dataSubset2 = HOUSING_TENURE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      belowPovertyLevel$dataSubset1 = BELOW_POVERTY_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      belowPovertyLevel$dataSubset2 = BELOW_POVERTY_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      childrenEligibleForFreeLunch$dataSubset1 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      childrenEligibleForFreeLunch$dataSubset2 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      diabetic$dataSubset1 = DIABETIC_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      diabetic$dataSubset2 = DIABETIC_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      diabeticScreening$dataSubset1 = DIABETIC_SCREENING_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      diabeticScreening$dataSubset2 = DIABETIC_SCREENING_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      excessiveDrinking$dataSubset1 = EXCESSIVE_DRINKING_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      excessiveDrinking$dataSubset2 = EXCESSIVE_DRINKING_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      hivPrevalance$dataSubset1 = HIV_PREVALENCE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      hivPrevalance$dataSubset2 = HIV_PREVALENCE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      homicideRate$dataSubset1 = HOMICIDE_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      homicideRate$dataSubset2 = HOMICIDE_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      inadequateSocialSupport$dataSubset1 = INADEQUATE_SOCIAL_SUPPORT_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      inadequateSocialSupport$dataSubset2 = INADEQUATE_SOCIAL_SUPPORT_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      limitedAccessToHealthyFoods$dataSubset1 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      limitedAccessToHealthyFoods$dataSubset2 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      mammographyScreening$dataSubset1 = MAMMOGRAPHY_SCREENING_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      mammographyScreening$dataSubset2 = MAMMOGRAPHY_SCREENING_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      obesity$dataSubset1 = OBESITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      obesity$dataSubset2 = OBESITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      physicallyInactive$dataSubset1 = PHYSICAL_INACTIVITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      physicallyInactive$dataSubset2 = PHYSICAL_INACTIVITY_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      poorOrFairHealth$dataSubset1 = POOR_OR_FAIR_HEALTH_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      poorOrFairHealth$dataSubset2 = POOR_OR_FAIR_HEALTH_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      prematureMortalityRate$dataSubset1 = PREMATURE_MORTALITY_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      prematureMortalityRate$dataSubset2 = PREMATURE_MORTALITY_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      singleParentHouseholds$dataSubset1 = SINGLE_PARENT_HOUSEHOLD_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      singleParentHouseholds$dataSubset2 = SINGLE_PARENT_HOUSEHOLD_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      smoking$dataSubset1 = SMOKING_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      smoking$dataSubset2 = SMOKING_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      violentCrimeRate$dataSubset1 = VIOLENT_CRIME_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      violentCrimeRate$dataSubset2 = VIOLENT_CRIME_RATE_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
      
      population$dataSubset1 = POPULATION_DATA %>%
        filter(year == riskAndProtectiveFactors$year,
               region == riskAndProtectiveFactors$regions[1]) %>%
        mutate(dataSubset = "1")
      population$dataSubset2 = POPULATION_DATA %>%
        filter(year == riskAndProtectiveFactors$year, 
               region == riskAndProtectiveFactors$regions[2]) %>%
        mutate(dataSubset = "2")
    }
  })
  
  observeEvent(eventExpr = input$dataInfo_racePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Race", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_educationPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Educational Attainment", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_ethnicityPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Ethnicity", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_foreignBornPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Foreign-Born", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_languagePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Main Language Spoken at Home", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_medianAgePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Median Age", DATA_INFO_MESSAGE_LIST[3]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_populationPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Population", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_medianIncomePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Median Income", DATA_INFO_MESSAGE_LIST[3]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_unemploymentRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Unemployment Rate", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_healthInsuranceCoveragePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Health Insurance Coverage", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_belowPovertyLevelPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Below Poverty Level", DATA_INFO_MESSAGE_LIST[3]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_airQualityIndexPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Air Quality Index", DATA_INFO_MESSAGE_LIST[4]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_vehiclesPerHousingUnitPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Vehicles Per Housing Unit", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_housingTenurePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Housing Tenure", DATA_INFO_MESSAGE_LIST[2]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_rentGreaterThan30PercentOfHouseholdIncomePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Rent > 30% of Household Income", DATA_INFO_MESSAGE_LIST[3]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_childrenEligibleForFreeLunchPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% of Children Eligible for Free Lunch", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_diabeticPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Diabetic", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_diabeticScreeningPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Diabetic Screening", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_excessiveDrinkingPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Excessive Drinking", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_hivPrevalencePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("HIV Prevalence", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_homicideRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Homicide Rate", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_inadequateSocialSupportPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Inadequate Social Support", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_limitedAccessToHealthyFoodsPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Limited Access to Healthy Foods", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_mammographyScreeningPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Mammography Screening", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_obesityPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Obesity", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_physicalInactivityPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Physically Inactive", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_poorOrFairHealthPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% of Poor/Fair Health", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_prematureMortalityRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Premature Mortality Rate", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_singleParentHouseholdsPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Single-Parent Households", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_smokingPlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("% Smoking", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_violentCrimeRatePlot, handlerExpr = {
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0("Violent Crime Rate", DATA_INFO_MESSAGE_LIST[5]) %>% lapply(htmltools::HTML)
    ))
  })
  #####
  
  # DATA EXPLORER
  #####
  dataExplorer = reactiveValues(
    dataSubset1 = INCIDENCE_DATA %>%
      filter(cancer == "All Cancers", race == "All Races"),
    variable1 = "Incidence Rate",
    subvariable1 = "All Cancers",
    selectedCancer1 = "All Cancers",
    
    dataSubset2 = INCIDENCE_DATA %>%
      filter(cancer == "All Cancers", race == "All Races"),
    variable2 = "Incidence Rate",
    subvariable2 = "All Cancers"
  )
  
  output$dataExplorer_plot = renderPlot(expr = {
    if(input$dataExplorer_plotTwoVariables) {
      # 2 variables
      x = if(dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate")) {
        dataExplorer$dataSubset1 %>%
          filter(year == input$dataExplorer_year_cancer, !is.na(rate)) %>%
          arrange(region)
      } else {
        dataExplorer$dataSubset1 %>%
          filter(year == input$dataExplorer_year_nonCancer, !is.na(rate)) %>%
          arrange(region)
      }
      
      y = if(dataExplorer$variable2 %in% c("Incidence Rate", "Mortality Rate")) {
        dataExplorer$dataSubset2 %>%
          filter(year == input$dataExplorer_year_cancer, !is.na(rate)) %>%
          arrange(region)
      } else {
        dataExplorer$dataSubset2 %>%
          filter(year == input$dataExplorer_year_nonCancer, !is.na(rate)) %>%
          arrange(region)
      }
      names(y) = paste0(names(y), "2")
      
      if(any(dim(x)[1] == 0, dim(y)[1] == 0)) {
        ggplot() +
          annotate(geom = "text", label = "Either Variable 1 or Variable 2 is not available for this year",
                   x = 0, y = 0, size = 6) +
          theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                panel.grid = element_blank())
      } else {
        xy = inner_join(x = x, y = y, by = c("region" = "region2"))
        # print(xy)
        
        if(dataExplorer$variable1 %in% c("Incidence Rate")) {
          geomTextSpacing = 30
          geomTextSuffix = ""
          axisName = "Age Adjusted Rate per 100,000"
          axisLimits = c(300,500)
          axisBreaks = 3:5*100
          axisLabels = 3:5*100
        } else if(dataExplorer$variable1 %in% c("Mortality Rate")) {
          geomTextSpacing = 30
          geomTextSuffix = ""
          axisName = "Age Adjusted Rate per 100,000"
          axisLimits = c(0,300)
          axisBreaks = 0:3*100
          axisLabels = 0:3*100
        } else if(dataExplorer$variable1 %in% c("Median Age")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,45)
          axisBreaks = 0:5*9
          axisLabels = 0:5*9
        } else if(dataExplorer$variable1 %in% c("Median Income")) {
          geomTextSpacing = 5000
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,130000)
          axisBreaks = 0:13*10000
          axisLabels = dollar_format()(0:13*10000)
        } else if(dataExplorer$variable1 %in% c("Air Quality Index")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,55)
          axisBreaks = 0:11*5
          axisLabels = 0:11*5
        } else if(dataExplorer$variable1 %in% c("HIV Prevalence", "Violent Crime Rate")) {
          geomTextSpacing = 30
          geomTextSuffix = ""
          axisName = "Rate per 100,000"
          axisLimits = c(0,900)
          axisBreaks = 0:9*100
          axisLabels = 0:9*100
        } else if(dataExplorer$variable1 %in% c("Homicide Rate")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = "Rate per 100,000"
          axisLimits = c(0,30)
          axisBreaks = 0:5*6
          axisLabels = 0:5*6
        } else if(dataExplorer$variable1 %in% c("Premature Mortality Rate")) {
          geomTextSpacing = 15
          geomTextSuffix = ""
          axisName = "Age Adjusted Rate per 100,000"
          axisLimits = c(0,400)
          axisBreaks = 0:4*100
          axisLabels = 0:4*100
        } else {
          geomTextSpacing = 5
          geomTextSuffix = "%"
          axisName = ""
          axisLimits = c(0,100)
          axisBreaks = 0:10*10
          axisLabels = paste0(0:10*10, "%")
        }
        
        if(dataExplorer$variable2 %in% c("Incidence Rate")) {
          geomTextSpacing2 = 30
          geomTextSuffix2 = ""
          axisName2 = "Age Adjusted Rate per 100,000"
          axisLimits2 = c(300,500)
          axisBreaks2 = 3:5*100
          axisLabels2 = 3:5*100
        } else if(dataExplorer$variable2 %in% c("Mortality Rate")) {
          geomTextSpacing2 = 30
          geomTextSuffix2 = ""
          axisName2 = "Age Adjusted Rate per 100,000"
          axisLimits2 = c(0,300)
          axisBreaks2 = 0:3*100
          axisLabels2 = 0:3*100
        } else if(dataExplorer$variable2 %in% c("Median Age")) {
          geomTextSpacing2 = 2
          geomTextSuffix2 = ""
          axisName2 = ""
          axisLimits2 = c(0,45)
          axisBreaks2 = 0:5*9
          axisLabels2 = 0:5*9
        } else if(dataExplorer$variable2 %in% c("Median Income")) {
          geomTextSpacing2 = 5000
          geomTextSuffix2 = ""
          axisName2 = ""
          axisLimits2 = c(0,130000)
          axisBreaks2 = 0:13*10000
          axisLabels2 = dollar_format()(0:13*10000)
        } else if(dataExplorer$variable2 %in% c("Air Quality Index")) {
          geomTextSpacing2 = 2
          geomTextSuffix2 = ""
          axisName2 = ""
          axisLimits2 = c(0,55)
          axisBreaks2 = 0:11*5
          axisLabels2 = 0:11*5
        } else if(dataExplorer$variable2 %in% c("HIV Prevalence", "Violent Crime Rate")) {
          geomTextSpacing2 = 30
          geomTextSuffix2 = ""
          axisName2 = "Rate per 100,000"
          axisLimits2 = c(0,900)
          axisBreaks2 = 0:9*100
          axisLabels2 = 0:9*100
        } else if(dataExplorer$variable2 %in% c("Homicide Rate")) {
          geomTextSpacing2 = 2
          geomTextSuffix2 = ""
          axisName2 = "Rate per 100,000"
          axisLimits2 = c(0,30)
          axisBreaks2 = 0:5*6
          axisLabels2 = 0:5*6
        } else if(dataExplorer$variable2 %in% c("Premature Mortality Rate")) {
          geomTextSpacing2 = 15
          geomTextSuffix2 = ""
          axisName2 = "Age Adjusted Rate per 100,000"
          axisLimits2 = c(0,400)
          axisBreaks2 = 0:4*100
          axisLabels2 = 0:4*100
        } else {
          geomTextSpacing2 = 5
          geomTextSuffix2 = "%"
          axisName2 = ""
          axisLimits2 = c(0,100)
          axisBreaks2 = 0:10*10
          axisLabels2 = paste0(0:10*10, "%")
        }
        
        ggplot(data = xy, aes(x = rate, y = rate2, col = as.factor(region))) +
          geom_point(size = 8, alpha = 0.3) +
          theme(legend.position = "none") +
          geom_text_repel(mapping = aes(label = REF_REGIONS$name[match(xy$region, REF_REGIONS$id)]), size = 5, point.padding = 2, alpha = 0.7) +
          scale_x_continuous(name = "Variable 1", limits = axisLimits, breaks = axisBreaks, labels = axisLabels) +
          scale_y_continuous(name = "Variable 2", limits = axisLimits2, breaks = axisBreaks2, labels = axisLabels2)
      }
    } else {
      # 1 variable
      x = if(dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate")) {
        dataExplorer$dataSubset1 %>%
          filter(year == input$dataExplorer_year_cancer, !is.na(rate)) %>%
          arrange(rate)
      } else {
        dataExplorer$dataSubset1 %>%
          filter(year == input$dataExplorer_year_nonCancer, !is.na(rate)) %>%
          arrange(rate)
      }
      
      # attempt at gganimate
      # x = if(dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate")) {
      #   dataExplorer$dataSubset1 %>%
      #     filter(!is.na(rate)) %>%
      #     arrange(rate)
      # } else {
      #   dataExplorer$dataSubset1 %>%
      #     filter(!is.na(rate)) %>%
      #     arrange(rate)
      # }
      
      if(dim(x)[1] == 0) {
        ggplot() +
          annotate(geom = "text", label = paste0(dataExplorer$variable1, " not available for this year"),
                   x = 0, y = 0, size = 6) +
          theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
                panel.grid = element_blank())
      } else {
        
        
        
        if(dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate")) {
          geomTextSpacing = 30
          geomTextSuffix = ""
          axisName = "Age Adjusted Rate per 100,000"
          axisLimits = c(0,700)
          axisBreaks = 0:7*100
          axisLabels = 0:7*100
        } else if(dataExplorer$variable1 %in% c("Median Age")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,45)
          axisBreaks = 0:5*9
          axisLabels = 0:5*9
        } else if(dataExplorer$variable1 %in% c("Median Income")) {
          geomTextSpacing = 5000
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,130000)
          axisBreaks = 0:13*10000
          axisLabels = dollar_format()(0:13*10000)
        } else if(dataExplorer$variable1 %in% c("Air Quality Index")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = ""
          axisLimits = c(0,55)
          axisBreaks = 0:11*5
          axisLabels = 0:11*5
        } else if(dataExplorer$variable1 %in% c("HIV Prevalence", "Violent Crime Rate")) {
          geomTextSpacing = 30
          geomTextSuffix = ""
          axisName = "Rate per 100,000"
          axisLimits = c(0,900)
          axisBreaks = 0:9*100
          axisLabels = 0:9*100
        } else if(dataExplorer$variable1 %in% c("Homicide Rate")) {
          geomTextSpacing = 2
          geomTextSuffix = ""
          axisName = "Rate per 100,000"
          axisLimits = c(0,30)
          axisBreaks = 0:5*6
          axisLabels = 0:5*6
        } else if(dataExplorer$variable1 %in% c("Premature Mortality Rate")) {
          geomTextSpacing = 15
          geomTextSuffix = ""
          axisName = "Age Adjusted Rate per 100,000"
          axisLimits = c(0,400)
          axisBreaks = 0:4*100
          axisLabels = 0:4*100
        } else {
          geomTextSpacing = 5
          geomTextSuffix = "%"
          axisName = ""
          axisLimits = c(0,100)
          axisBreaks = 0:10*10
          axisLabels = paste0(0:10*10, "%")
        }
        
        ggplot(data = x, aes(x = reorder(region, rate), y = rate)) +
          geom_bar(stat = "identity", position = "dodge", fill = "turquoise3") +
          geom_text(
            mapping = aes(x = reorder(region, rate), y = rate + geomTextSpacing, label =
                            if(dataExplorer$variable1 %in% c("Median Income")) {
                              dollar(rate)
                            } else {
                              paste0(rate, geomTextSuffix)
                            }
            ),
            position = position_dodge(width = 0.9)
          ) +
          scale_x_discrete(name = "", labels = REF_REGIONS$name[match(x$region, REF_REGIONS$id)]) +
          scale_y_continuous(name = axisName, limits = axisLimits, breaks = axisBreaks, labels = axisLabels) +
          coord_flip()
      }
    }
  })
  
  output$dataExplorer_plot2 = renderDygraph(expr = {
    x = dataExplorer$dataSubset1 %>%
      filter(!is.na(rate)) %>%
      select(year, region, rate) %>%
      arrange(year, region, rate)
    
    if(dim(x)[1] == 0) {
      ggplot() +
        annotate(geom = "text", label = paste0(dataExplorer$variable1, " not available for this year"),
                 x = 0, y = 0, size = 6) +
        theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
              panel.grid = element_blank())
    } else {
      # if(dataExplorer$variable1 %in% c("Incidence Rate")) {
      #   geomTextSpacing = 30
      #   geomTextSuffix = ""
      #   axisName = "Age Adjusted Rate per 100,000"
      #   axisLimits = c(300,500)
      #   axisBreaks = 3:5*100
      #   axisLabels = 3:5*100
      # } else if(dataExplorer$variable1 %in% c("Mortality Rate")) {
      #   geomTextSpacing = 30
      #   geomTextSuffix = ""
      #   axisName = "Age Adjusted Rate per 100,000"
      #   axisLimits = c(0,300)
      #   axisBreaks = 0:3*100
      #   axisLabels = 0:3*100
      # } else if(dataExplorer$variable1 %in% c("Median Age")) {
      #   geomTextSpacing = 2
      #   geomTextSuffix = ""
      #   axisName = ""
      #   axisLimits = c(0,45)
      #   axisBreaks = 0:5*9
      #   axisLabels = 0:5*9
      # } else if(dataExplorer$variable1 %in% c("Median Income")) {
      #   geomTextSpacing = 5000
      #   geomTextSuffix = ""
      #   axisName = ""
      #   axisLimits = c(0,130000)
      #   axisBreaks = 0:13*10000
      #   axisLabels = dollar_format()(0:13*10000)
      # } else if(dataExplorer$variable1 %in% c("Air Quality Index")) {
      #   geomTextSpacing = 2
      #   geomTextSuffix = ""
      #   axisName = ""
      #   axisLimits = c(0,55)
      #   axisBreaks = 0:11*5
      #   axisLabels = 0:11*5
      # } else if(dataExplorer$variable1 %in% c("HIV Prevalence", "Violent Crime Rate")) {
      #   geomTextSpacing = 30
      #   geomTextSuffix = ""
      #   axisName = "Rate per 100,000"
      #   axisLimits = c(0,900)
      #   axisBreaks = 0:9*100
      #   axisLabels = 0:9*100
      # } else if(dataExplorer$variable1 %in% c("Homicide Rate")) {
      #   geomTextSpacing = 2
      #   geomTextSuffix = ""
      #   axisName = "Rate per 100,000"
      #   axisLimits = c(0,30)
      #   axisBreaks = 0:5*6
      #   axisLabels = 0:5*6
      # } else if(dataExplorer$variable1 %in% c("Premature Mortality Rate")) {
      #   geomTextSpacing = 15
      #   geomTextSuffix = ""
      #   axisName = "Age Adjusted Rate per 100,000"
      #   axisLimits = c(0,400)
      #   axisBreaks = 0:4*100
      #   axisLabels = 0:4*100
      # } else {
      #   geomTextSpacing = 5
      #   geomTextSuffix = "%"
      #   axisName = ""
      #   axisLimits = c(0,100)
      #   axisBreaks = 0:10*10
      #   axisLabels = paste0(0:10*10, "%")
      # }
      # 
      # firstYear = min(x$year)
      # lastYear = max(x$year)
      # 
      # ggplot(data = x, aes(x = year, y = rate, col = REF_REGIONS$name[regionsToInclude])) +
      #   geom_point() +
      #   geom_line() +
      #   scale_x_continuous(name = "Year", limits = c(firstYear, lastYear), breaks = firstYear:lastYear,
      #                    labels = as.character(firstYear:lastYear)) +
      #   scale_y_continuous(name = axisName, limits = axisLimits, breaks = axisBreaks, labels = axisLabels) +
      #   scale_color_discrete(
      #     name = "Region"
      #   )
      x = x %>%
        spread(key = region, value = rate)
      names(x) = c("Year", as.character(REF_REGIONS$name[match(as.numeric(names(x)[-1]), REF_REGIONS$id)]))
      
      plotTitle = if(dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate", "Educational Attainment", "Ethnicity",
                                                   "Foreign-Born", "Main Language Spoken at Home", "Race", 
                                                   "Health Insurance Coverage", "Housing Tenure", "Vehicles Per Housing Unit")) {
        paste(dataExplorer$subvariable1, dataExplorer$variable1, " over Time")
      } else {
        paste(dataExplorer$variable1, " over Time")
      }
      
      dygraph(data = x, main = plotTitle) %>%
        dyOptions(drawPoints = TRUE, pointSize = 3) %>%
        dyLegend(labelsSeparateLines = TRUE, labelsDiv = "dataExplorer_plot2_legend") %>%
        dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>%
        dyAxis("x", ticker="
          function(a, b, pixels, opts, dygraph, vals) {
            return Dygraph.getDateAxis(a, b, Dygraph.ANNUAL, opts, dygraph)
          }
        ", axisLabelFormatter="
          function(d) {
            return d.getFullYear();
          }       
        ")
    }
  })
  
  observeEvent(eventExpr = input$dataExplorer_variable1, handlerExpr = {
    # update reactive
    dataExplorer$variable1 = input$dataExplorer_variable1
    
    # switch sliders based on years available
    if(any(
      dataExplorer$variable1 %in% c("Incidence Rate", "Mortality Rate"),
      all(
        input$dataExplorer_plotTwoVariables,
        dataExplorer$variable2 %in% c("Incidence Rate", "Mortality Rate")  
      )
    )) {
      hide(id = "dataExplorer_year_nonCancer")
      show(id = "dataExplorer_year_cancer")
    } else {
      hide(id = "dataExplorer_year_cancer")
      show(id = "dataExplorer_year_nonCancer")
    }
    
    # filter relevant data subset for this variable
    if(dataExplorer$variable1 == "Incidence Rate") {
      dataExplorer$dataSubset1 = INCIDENCE_DATA %>%
        filter(cancer == dataExplorer$subvariable1, race == "All Races")
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = dataExplorer$selectedCancer1)
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Mortality Rate") {
      # dataExplorer$subvariable1 = "All Cancers"
      dataExplorer$dataSubset1 = MORTALITY_DATA %>%
        filter(cancer == dataExplorer$subvariable1, race == "All Races")
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = dataExplorer$selectedCancer1)
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Educational Attainment") {
      dataExplorer$dataSubset1 = EDUCATION_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = EDUCATION_CATEGORIES_LIST,
                        selected = EDUCATION_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Ethnicity") {
      dataExplorer$dataSubset1 = ETHNICITY_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = ETHNICITY_CATEGORIES_LIST,
                        selected = ETHNICITY_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Foreign-Born") {
      dataExplorer$dataSubset1 = FOREIGN_BORN_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = FOREIGN_BORN_CATEGORIES_LIST,
                        selected = FOREIGN_BORN_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Main Language Spoken at Home") {
      dataExplorer$dataSubset1 = LANGUAGE_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = LANGUAGE_CATEGORIES_LIST,
                        selected = LANGUAGE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Median Age") {
      dataExplorer$dataSubset1 = MEDIAN_AGE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Race") {
      dataExplorer$dataSubset1 = RACE_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = RACE_CATEGORIES_LIST,
                        selected = RACE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Median Income") {
      dataExplorer$dataSubset1 = MEDIAN_INCOME_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Unemployment Rate") {
      dataExplorer$dataSubset1 = UNEMPLOYMENT_RATE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Air Quality Index") {
      dataExplorer$dataSubset1 = AIR_QUALITY_INDEX_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Vehicles Per Housing Unit") {
      dataExplorer$dataSubset1 = VEHICLES_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = VEHICLES_CATEGORIES_LIST,
                        selected = VEHICLES_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Health Insurance Coverage") {
      dataExplorer$dataSubset1 = HEALTH_INSURANCE_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = HEALTH_INSURANCE_CATEGORIES_LIST,
                        selected = HEALTH_INSURANCE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Housing Tenure") {
      dataExplorer$dataSubset1 = HOUSING_TENURE_DATA %>%
        filter(category == dataExplorer$subvariable1)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable1",
                        label = "Category",
                        choices = HOUSING_TENURE_CATEGORIES_LIST,
                        selected = HOUSING_TENURE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Below Poverty Level") {
      dataExplorer$dataSubset1 = BELOW_POVERTY_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Rent > 30% of Household Income") {
      dataExplorer$dataSubset1 = RENT_GREATER_THAN_30_INCOME_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Children Eligible for Free Lunch") {
      dataExplorer$dataSubset1 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Diabetic") {
      dataExplorer$dataSubset1 = DIABETIC_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Diabetic Screening") {
      dataExplorer$dataSubset1 = DIABETIC_SCREENING_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Excessive Drinking") {
      dataExplorer$dataSubset1 = EXCESSIVE_DRINKING_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "HIV Prevalence") {
      dataExplorer$dataSubset1 = HIV_PREVALENCE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Homicide Rate") {
      dataExplorer$dataSubset1 = HOMICIDE_RATE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Inadequate Social Support") {
      dataExplorer$dataSubset1 = INADEQUATE_SOCIAL_SUPPORT_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Limited Access to Healthy Foods") {
      dataExplorer$dataSubset1 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Mammography Screening") {
      dataExplorer$dataSubset1 = MAMMOGRAPHY_SCREENING_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Obesity") {
      dataExplorer$dataSubset1 = OBESITY_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Poor/Fair Health") {
      dataExplorer$dataSubset1 = POOR_OR_FAIR_HEALTH_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Physically Inactive") {
      dataExplorer$dataSubset1 = PHYSICAL_INACTIVITY_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Premature Mortality Rate") {
      dataExplorer$dataSubset1 = PREMATURE_MORTALITY_RATE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Single-Parent Households") {
      dataExplorer$dataSubset1 = SINGLE_PARENT_HOUSEHOLD_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "% Smoking") {
      dataExplorer$dataSubset1 = SMOKING_DATA
      hide(id = "dataExplorer_subvariable1")
    } else if(dataExplorer$variable1 == "Violent Crime Rate") {
      dataExplorer$dataSubset1 = VIOLENT_CRIME_RATE_DATA
      hide(id = "dataExplorer_subvariable1")
    } else {
      NULL
      # continue here...
    }
  })
  
  observeEvent(eventExpr = input$dataExplorer_subvariable1, handlerExpr = {
    # update reactive
    dataExplorer$subvariable1 = input$dataExplorer_subvariable1
    
    # filter relevant data subset for this subvariable
    if(dataExplorer$variable1 == "Incidence Rate") {
      dataExplorer$selectedCancer1 = dataExplorer$subvariable1
      dataExplorer$dataSubset1 = INCIDENCE_DATA %>%
        filter(cancer == dataExplorer$subvariable1, race == "All Races")
    } else if(dataExplorer$variable1 == "Mortality Rate") {
      dataExplorer$selectedCancer1 = dataExplorer$subvariable1
      dataExplorer$dataSubset1 = MORTALITY_DATA %>%
        filter(cancer == dataExplorer$subvariable1, race == "All Races")
    } else if(dataExplorer$variable1 == "Educational Attainment") {
      dataExplorer$dataSubset1 = EDUCATION_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Ethnicity") {
      dataExplorer$dataSubset1 = ETHNICITY_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Foreign-Born") {
      dataExplorer$dataSubset1 = FOREIGN_BORN_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Main Language Spoken at Home") {
      dataExplorer$dataSubset1 = LANGUAGE_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Race") {
      dataExplorer$dataSubset1 = RACE_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Vehicles Per Housing Unit") {
      dataExplorer$dataSubset1 = VEHICLES_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Health Insurance Coverage") {
      dataExplorer$dataSubset1 = HEALTH_INSURANCE_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else if(dataExplorer$variable1 == "Housing Tenure") {
      dataExplorer$dataSubset1 = HOUSING_TENURE_DATA %>%
        filter(category == dataExplorer$subvariable1)
    } else {
      NULL
      # continue here...
    }
  })
  
  observeEvent(eventExpr = input$dataExplorer_variable2, handlerExpr = {
    # update reactive
    dataExplorer$variable2 = input$dataExplorer_variable2
    
    # switch sliders based on years available
    if(input$dataExplorer_plotTwoVariables) {
      # if plotting 2 variables, need to check both variables to see if slider needs to change
      if(any(
        input$dataExplorer_variable1 %in% c("Incidence Rate", "Mortality Rate"),
        input$dataExplorer_variable2 %in% c("Incidence Rate", "Mortality Rate")
      )) {
        hide(id = "dataExplorer_year_nonCancer")
        show(id = "dataExplorer_year_cancer")
      } else {
        hide(id = "dataExplorer_year_cancer")
        show(id = "dataExplorer_year_nonCancer")
      }
    } else {
      # otherwise, just check variable 1
      if(input$dataExplorer_variable1 %in% c("Incidence Rate", "Mortality Rate")) {
        hide(id = "dataExplorer_year_nonCancer")
        show(id = "dataExplorer_year_cancer")
      } else {
        hide(id = "dataExplorer_year_cancer")
        show(id = "dataExplorer_year_nonCancer")
      }
    }
    
    
    # filter relevant data subset for this variable
    if(dataExplorer$variable2 == "Incidence Rate") {
      dataExplorer$dataSubset2 = INCIDENCE_DATA %>%
        filter(cancer == dataExplorer$subvariable2, race == "All Races")
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = dataExplorer$subvariable2)
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Mortality Rate") {
      dataExplorer$dataSubset2 = MORTALITY_DATA %>%
        filter(cancer == dataExplorer$subvariable2, race == "All Races")
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Cancer",
                        choices = CANCERS_LIST,
                        selected = dataExplorer$subvariable2)
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Educational Attainment") {
      dataExplorer$dataSubset2 = EDUCATION_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = EDUCATION_CATEGORIES_LIST,
                        selected = EDUCATION_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Ethnicity") {
      dataExplorer$dataSubset2 = ETHNICITY_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = ETHNICITY_CATEGORIES_LIST,
                        selected = ETHNICITY_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Foreign-Born") {
      dataExplorer$dataSubset2 = FOREIGN_BORN_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = FOREIGN_BORN_CATEGORIES_LIST,
                        selected = FOREIGN_BORN_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Main Language Spoken at Home") {
      dataExplorer$dataSubset2 = LANGUAGE_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = LANGUAGE_CATEGORIES_LIST,
                        selected = LANGUAGE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Median Age") {
      dataExplorer$dataSubset2 = MEDIAN_AGE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Race") {
      dataExplorer$dataSubset2 = RACE_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = RACE_CATEGORIES_LIST,
                        selected = RACE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Median Income") {
      dataExplorer$dataSubset2 = MEDIAN_INCOME_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Unemployment Rate") {
      dataExplorer$dataSubset2 = UNEMPLOYMENT_RATE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Air Quality Index") {
      dataExplorer$dataSubset2 = AIR_QUALITY_INDEX_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Vehicles Per Housing Unit") {
      dataExplorer$dataSubset2 = VEHICLES_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = VEHICLES_CATEGORIES_LIST,
                        selected = VEHICLES_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Health Insurance Coverage") {
      dataExplorer$dataSubset2 = HEALTH_INSURANCE_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = HEALTH_INSURANCE_CATEGORIES_LIST,
                        selected = HEALTH_INSURANCE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Housing Tenure") {
      dataExplorer$dataSubset2 = HOUSING_TENURE_DATA %>%
        filter(category == dataExplorer$subvariable2)
      updateSelectInput(session = session,
                        inputId = "dataExplorer_subvariable2",
                        label = "Category",
                        choices = HOUSING_TENURE_CATEGORIES_LIST,
                        selected = HOUSING_TENURE_CATEGORIES_LIST[1])
      show(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Below Poverty Level") {
      dataExplorer$dataSubset2 = BELOW_POVERTY_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Rent > 30% of Household Income") {
      dataExplorer$dataSubset2 = RENT_GREATER_THAN_30_INCOME_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Children Eligible for Free Lunch") {
      dataExplorer$dataSubset2 = CHILDREN_ELIGIBLE_FOR_FREE_LUNCH_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Diabetic") {
      dataExplorer$dataSubset2 = DIABETIC_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Diabetic Screening") {
      dataExplorer$dataSubset2 = DIABETIC_SCREENING_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Excessive Drinking") {
      dataExplorer$dataSubset2 = EXCESSIVE_DRINKING_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "HIV Prevalence") {
      dataExplorer$dataSubset2 = HIV_PREVALENCE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Homicide Rate") {
      dataExplorer$dataSubset2 = HOMICIDE_RATE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Inadequate Social Support") {
      dataExplorer$dataSubset2 = INADEQUATE_SOCIAL_SUPPORT_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Limited Access to Healthy Foods") {
      dataExplorer$dataSubset2 = LIMITED_ACCESS_TO_HEALTHY_FOODS_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Mammography Screening") {
      dataExplorer$dataSubset2 = MAMMOGRAPHY_SCREENING_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Obesity") {
      dataExplorer$dataSubset2 = OBESITY_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Poor/Fair Health") {
      dataExplorer$dataSubset2 = POOR_OR_FAIR_HEALTH_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Physically Inactive") {
      dataExplorer$dataSubset2 = PHYSICAL_INACTIVITY_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Premature Mortality Rate") {
      dataExplorer$dataSubset2 = PREMATURE_MORTALITY_RATE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Single-Parent Households") {
      dataExplorer$dataSubset2 = SINGLE_PARENT_HOUSEHOLD_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "% Smoking") {
      dataExplorer$dataSubset2 = SMOKING_DATA
      hide(id = "dataExplorer_subvariable2")
    } else if(dataExplorer$variable2 == "Violent Crime Rate") {
      dataExplorer$dataSubset2 = VIOLENT_CRIME_RATE_DATA
      hide(id = "dataExplorer_subvariable2")
    } else {
      NULL
      # continue here...
    }
  })
  
  observeEvent(eventExpr = input$dataExplorer_subvariable2, handlerExpr = {
    # update reactive
    dataExplorer$subvariable2 = input$dataExplorer_subvariable2
    
    # filter relevant data subset for this subvariable
    dataExplorer$dataSubset2 = if(dataExplorer$variable2 == "Incidence Rate") {
      dataExplorer$selectedCancer2 = dataExplorer$subvariable2
      INCIDENCE_DATA %>%
        filter(cancer == dataExplorer$subvariable2, race == "All Races")
    } else if(dataExplorer$variable2 == "Mortality Rate") {
      dataExplorer$selectedCancer2 = dataExplorer$subvariable2
      MORTALITY_DATA %>%
        filter(cancer == dataExplorer$subvariable2, race == "All Races")
    } else if(dataExplorer$variable2 == "Educational Attainment") {
      EDUCATION_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Ethnicity") {
      ETHNICITY_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Foreign-Born") {
      FOREIGN_BORN_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Main Language Spoken at Home") {
      LANGUAGE_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Race") {
      RACE_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Vehicles Per Housing Unit") {
      VEHICLES_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Health Insurance Coverage") {
      HEALTH_INSURANCE_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else if(dataExplorer$variable2 == "Housing Tenure") {
      HOUSING_TENURE_DATA %>%
        filter(category == dataExplorer$subvariable2)
    } else {
      NULL
      # continue here...
    }
  })
  
  observeEvent(eventExpr = input$dataInfo_dataExplorer1Plot, handlerExpr = {
    messageToShow = if(dataExplorer$variable1 %in% c("Incidence Rate","Mortality Rate")) {
      DATA_INFO_MESSAGE_LIST[1]
    } else if(dataExplorer$variable1 %in% c("Air Quality Index")) {
      DATA_INFO_MESSAGE_LIST[4]
    } else if(dataExplorer$variable1 %in% c("% Children Eligible for Free Lunch", "% Diabetic", "% Diabetic Screening",
                                            "% Excessive Drinking", "HIV Prevalence", "Homicide Rate", "% Inadequate Social Support",
                                            "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                            "% Poor/Fair Health", "% Physically Inactive", "Premature Mortality Rate",
                                            "% Single-Parent Households", "% Smoking", "Violent Crime Rate")) {
      DATA_INFO_MESSAGE_LIST[5]
    } else {
      DATA_INFO_MESSAGE_LIST[2]
    }
    
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0(dataExplorer$variable1, messageToShow) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataInfo_dataExplorer2Plot, handlerExpr = {
    messageToShow = if(dataExplorer$variable2 %in% c("Incidence Rate","Mortality Rate")) {
      DATA_INFO_MESSAGE_LIST[1]
    } else if(dataExplorer$variable2 %in% c("Air Quality Index")) {
      DATA_INFO_MESSAGE_LIST[4]
    } else if(dataExplorer$variable2 %in% c("% Children Eligible for Free Lunch", "% Diabetic", "% Diabetic Screening",
                                            "% Excessive Drinking", "HIV Prevalence", "Homicide Rate", "% Inadequate Social Support",
                                            "% Limited Access to Healthy Foods", "% Mammography Screening", "% Obesity",
                                            "% Poor/Fair Health", "% Physically Inactive", "Premature Mortality Rate",
                                            "% Single-Parent Households", "% Smoking", "Violent Crime Rate")) {
      DATA_INFO_MESSAGE_LIST[5]
    } else {
      DATA_INFO_MESSAGE_LIST[2]
    }
    
    showModal(ui = modalDialog(
      title = "Data Info", easyClose = TRUE, fade = FALSE,
      paste0(dataExplorer$variable2, messageToShow) %>% lapply(htmltools::HTML)
    ))
  })
  
  observeEvent(eventExpr = input$dataExplorer_plotTwoVariables, handlerExpr = {
    if(input$dataExplorer_plotTwoVariables) {
      hide(id = "dataExplorer_plot2_box")
    } else {
      show(id = "dataExplorer_plot2_box")
    }
  })
  #####
  
  # Developer
  #####
  observeEvent(eventExpr = input$runDebug1, handlerExpr = {
    tryCatch(
      expr = {
        x = eval(parse(text = input$debug1))
        print(x)
      },
      error = function(e) {
        print(e)
      }
    )
  })
  
  observeEvent(eventExpr = input$runDebug2, handlerExpr = {
    tryCatch(
      expr = {
        x = eval(parse(text = input$debug2))
        print(x)
      },
      error = function(e) {
        print(e)
      }
    )
  })
  
  observeEvent(eventExpr = input$runDebug3, handlerExpr = {
    tryCatch(
      expr = {
        x = eval(parse(text = input$debug3))
        print(x)
      },
      error = function(e) {
        print(e)
      }
    )
  })
  #####
  
  # Sandbox
  #####
  
  #####
}

shinyApp(ui, server)
