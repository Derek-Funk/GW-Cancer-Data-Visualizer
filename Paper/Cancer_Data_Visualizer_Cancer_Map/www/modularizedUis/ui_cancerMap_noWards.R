ui_cancerMap_noWards = function(mapNumber) {
  column(width = 6,
    box(width = 12, collapsible = FALSE,
        # title = paste0("Map ", mapNumber),
      fluidRow(
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_noWards_selectRegion"),
            label = "Region",
            choices = REGIONS_LIST_DROPDOWN_CHOICES,
            selected = 0
          )
        ),
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_noWards_selectVariable"),
            label = "Variable",
            choices = CANCER_MAP_VARIABLE_CHOICES,
            selected = "Incidence Rate"
          )
        ),
        column(width = 4,
          selectInput(inputId = paste0("cancerMap", mapNumber, "_noWards_selectSubvariable"),
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
          actionBttn(inputId = paste0("cancerMap", mapNumber, "_noWards_mapView"),
            label = "Map View",
            style = "fill", 
            color = "danger",
            block = TRUE
          )
        ),
        column(width = 6,
          actionBttn(inputId = paste0("cancerMap", mapNumber, "_noWards_listView"),
            label = "List View",
            style = "fill", 
            color = "danger",
            block = TRUE
          )
        )
      ),
      leafletOutput(outputId = paste0("cancerMap", mapNumber, "_noWards"), height = 480),
      DTOutput(outputId = paste0("cancerMap", mapNumber, "_noWards_list"), height = 480)
      # ,
      # actionBttn(inputId = paste0("dataInfo_cancerMap", mapNumber, "_noWards"),
      #            label = "Data Info",
      #            style = "minimal",
      #            color = "primary",
      #            size = "xs"
      # )
    ),
    box(width = 12,
      uiOutput(outputId = paste0("cancerMap", mapNumber, "_noWards_result"))
    )
  )
}
