ui_cancerMap = function(mapNumber) {
  column(width = 6,
    box(width = 12, collapsible = FALSE, title = paste0("Map ", mapNumber),
      fluidRow(
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_selectRegion"),
            label = "Region",
            choices = REGIONS_LIST_DROPDOWN_CHOICES_NO_WARDS,
            selected = 0
          )
        ),
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_selectVariable"),
            label = "Variable",
            choices = CANCER_MAP_VARIABLE_CHOICES,
            selected = "Incidence Rate"
          )
        ),
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_selectSubvariable"),
            label = "Cancer",
            choices = CANCERS_LIST,
            selected = "All Cancers"
          )
        )
      )
    ),
    box(width = 12, height = 565,
      fluidRow(
        column(width = 6,
          actionBttn(inputId = paste0("cancerMap", mapNumber, "_mapView"),
            label = "Map View",
            style = "fill", 
            color = "danger",
            block = TRUE
          )
        ),
        column(width = 6,
          actionBttn(inputId = paste0("cancerMap", mapNumber, "_listView"),
            label = "List View",
            style = "fill", 
            color = "danger",
            block = TRUE
          )
        )
      ),
      leafletOutput(outputId = paste0("cancerMap", mapNumber), height = 480),
      DTOutput(outputId = paste0("cancerMap", mapNumber, "_list"), height = 480),
      actionBttn(inputId = paste0("dataInfo_cancerMap", mapNumber),
                 label = "Data Info",
                 style = "minimal",
                 color = "primary",
                 size = "xs"
      )
    ),
    box(width = 12,
      uiOutput(outputId = paste0("cancerMap", mapNumber, "_result"))
    )
  )
}
