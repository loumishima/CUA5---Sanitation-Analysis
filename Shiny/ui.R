library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(plotly)
library(lubridate)
library(scales)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(shinycssloaders)
source('ui_modules.R')

lorem_ipsum <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vivamus arcu felis bibendum ut tristique et egestas quis. Et odio pellentesque diam volutpat commodo sed egestas egestas fringilla. Malesuada fames ac turpis egestas integer. Nulla posuere sollicitudin aliquam ultrices sagittis orci a. Libero id faucibus nisl tincidunt eget. Mi bibendum neque egestas congue. Proin sed libero enim sed. Erat imperdiet sed euismod nisi porta lorem. Velit ut tortor pretium viverra suspendisse potenti nullam ac. Mauris vitae ultricies leo integer malesuada nunc vel. Vivamus at augue eget arcu dictum varius duis at. Eleifend mi in nulla posuere sollicitudin aliquam ultrices sagittis orci. Aenean et tortor at risus viverra adipiscing."

# User interface ----
ui <- tagList(
  tags$head(tags$script(type="text/javascript", src = "code.js")),
  navbarPage(title = "Madagascar's Sanitation Risk (CUA 5)", id = "nav", theme = "style.css",
             
             tabPanel("Sanitation Risk", value = 0,
                      leafletOutput(outputId = "risk", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    #Stats on the side
                                    h1("Sanitation Risk"),
                                    br(),
                                    p(id = "mainText", "This map visualises the level of risk based on our current risk methodology. Red squares indicate where investment is most needed to improve access to safe sanitation and reduce the risk of water contamination."),
                                    p(id = "mainText","To read more on our risk methodology, check the Technical details tab (In development)"),
                                    p(id = "mainText","To see the data sources behind our analysis, click on the tabs above."))
                                  
                                  
                      
             ),
             tabPanel("Toilet", value = 1,
                      leafletOutput(outputId = "toilets", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    h1("Toilet Location"),
                                    br(),
                                    p(id = "mainText","The toilet location data displayed here was created by Gather’s Centre for Sanitation Analytics. The data is a sample set created using data from Lusaka, Zambia. It was created to demonstrate how risk could be measured for the CUA5 once we receive the real locations of data from sanitation organisations."),
                                    p(id = "mainText", "Clicking on the toilets icons will reveala popup with some individual characteristics about them"))
                      
                        
             ),
             tabPanel("Population", value = 2,
                      
                      leafletOutput(outputId = "population", height = 700)%>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    h1("Population Density"),
                                    br(),
                                    p(id = "mainText","WorldPop (based at the University of Southampton) are the leading data source on population forecasts. We worked with their data to create population density estimates for our 1km2 analysis"),
                                    HTML('<p id = "mainText">For more information on WorldPop, please visit their <a href = "https://www.worldpop.org/"> website </a></p>'))
                      
             ),
             tabPanel("Rivers", value = 3,
                      leafletOutput(outputId = "rivers", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    h1("River Density"),
                                    br(),
                                    p(id = "mainText","We extracted data on the location of rivers in CUA5 from a dataset held by the United Nation’s Food and Agriculture Organisation. We are currently researching a more complete source, potentially in partnership with OpenStreetMap."),
                                    p(id = "mainText","The location of rivers allows us to assess the chance of flood risk and water contamination in proximity to toilets that are no working (or no toilets at all)."))
             ),
             
             tabPanel("Road", value = 4,
                      leafletOutput(outputId = "roads", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    h1("Road Density"),
                                    br(),
                                    p(id = "mainText","We extracted data on the location of roads and pathways in CUA5 from OpenStreetMap."),
                                    p(id = "mainText","The location of roads allows us to assess how easily a waste collection vehicle can access an area to empty full pit latrines or septic tanks. We need better resolution data to make differentiate roads from pedestrian pathways and alleys that are unsuitable for a vehicle."),
                                    HTML('<p id = "mainText",>For more information on OpenStreetMap, please visit their <a href="https://www.openstreetmap.org/">website</a></p>'))
             ),
             
             tabPanel("Technical Details", value = 5,
                      tags$iframe(class = 'leaflet-container', style="height:400px; width:100%; scrolling=yes", src="Appendix - Moving toward predictive, geospatial analytics for urban sanitation.pdf")),
             tabPanel("Updates", value = 6,
                      fluidRow( class = "updateTitle",
                        column(4, "Major app updates", div(style = "height:30px;"), offset = 4)
                      ),
                      fluidRow(class = "updateArea",
                        column(4, uiOutput(outputId = 'updates'), offset = 4)
                      )
                      ,
                      
                      
                  
                      useShinyjs())
             
             
             
  ))
