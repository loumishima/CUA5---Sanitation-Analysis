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
  navbarPage(title = "Sanitation Risk for CUA5, Antananarivo, Madagascar", id = "nav", theme = "style.css",
             tabPanel('Home', value = -1,
                      fluidRow( class = "updateTitle",
                                column(4, "Geospatial model for sanitation risk", div(style = "height:30px;"), offset = 4)
                      ),
                      fluidRow(class = "updateArea",
                               column(4, uiOutput(outputId = 'home'), offset = 4)
                      )),
             tabPanel("Risk", value = 0,
                      leafletOutput(outputId = "risk", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                    width = 400, height = 600,
                                    #Stats on the side
                                    h1("Risk"),
                                    br(),
                                    p(id = "mainText", "This map visualises the risk based on our current formula and geospatial model. Red squares indicate where investment is most needed to improve access to safe sanitation and reduce the risk of water contamination."),
                                    p(id = "mainText", "To see the data sources the feed into this visualisation, explore the data sources tabs above."),
                                    p(id = "mainText", "To learn more about these contextual data sets and our risk methodology, click the Appendix tab."))
                                  
                                  
                      
             ),
             navbarMenu('Data Sources',
               tabPanel("Sanitation Data", value = 1,
                        leafletOutput(outputId = "toilets", height = 700) %>% withSpinner(type = 4),
                        absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                      draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                      width = 400, height = 600,
                                      h1("Sanitation Data"),
                                      br(),
                                      p(id = "mainText","The sanitation data displayed here was created by Gather’s Centre for Sanitation Analytics. The data is a sample that was created from a data set from an informal settlement in Lusaka, Zambia."),
                                      p(id = "mainText","The sample data set was created to demonstrate how risk can be assessed and visualised when sanitation data is analysed alongside contextual, geospatial data sets."),
                                      p(id = "mainText", "Clicking on each data point reveals a pop-up with characteristic details."))
                        
                          
               ),
               tabPanel("Population Density", value = 2,
                        
                        leafletOutput(outputId = "population", height = 700)%>% withSpinner(type = 4),
                        absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                      draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                      width = 400, height = 600,
                                      h1("Population Density"),
                                      br(),
                                      p(id = "mainText","This map visualises population density based on data from WorldPop (an initiative of the University of Southampton) who are pioneers in population forecasts. We analysed the data to estimate population density for 1km x 1km squares."),
                                      HTML('<p id = "mainText">For more information on WorldPop, please visit their <a href = "https://www.worldpop.org/"> website </a>.</p>'))
                        
               ),
               tabPanel("River Density", value = 3,
                        leafletOutput(outputId = "rivers", height = 700) %>% withSpinner(type = 4),
                        absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                      draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                      width = 400, height = 600,
                                      h1("River Density"),
                                      br(),
                                      p(id = "mainText","This map visualises river density based on data from the United Nation’s Food and Agriculture Organisation. The proximity of rivers to sanitation infrastructure allows us to assess the chance of water contamination in the event of a flood or leak."),
                                      p(id = "mainText","We plan to update the accuracy of the river data set in partnership with OpenStreetMap."),
                                      HTML('<p id = "mainText">For more information about OpenStreetMap, please visit their <a href = "https://www.openstreetmap.org"> website </a>.</p>'))
               ),
               
               tabPanel("Road Density", value = 4,
                        leafletOutput(outputId = "roads", height = 700) %>% withSpinner(type = 4),
                        absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                      draggable = F, top =140, left = "auto", right = 50, bottom = "auto",
                                      width = 400, height = 600,
                                      h1("Road Density"),
                                      br(),
                                      p(id = "mainText","This map visualises road density based on the location of roads and pathways from OpenStreetMap. The proximity of roads to sanitation infrastructure allows us to assess how easily a waste collection vehicle can access and empty a pit latrine of septic tank."),
                                      p(id = "mainText","We plan to update the accuracy of the road data in partnership with OpenStreetMap so that we can differentiate roads from pedestrian pathways that are unsuitable for vehicles."),
                                      HTML('<p id = "mainText">For more information on OpenStreetMap, please visit their <a href="https://www.openstreetmap.org/">website</a></p>'))
               )),
             
             tabPanel("Appendix", value = 5,
                      tags$iframe(class = 'leaflet-container', style="height:400px; width:100%; scrolling=yes", src="Appendix - Moving toward predictive, geospatial analytics for urban sanitation.pdf")),
             tabPanel("Site Updates", value = 6,
                      fluidRow( class = "updateTitle",
                        column(4, "Site Updates", div(style = "height:30px;"), offset = 4)
                      ),
                      fluidRow(class = "updateArea",
                        column(4, uiOutput(outputId = 'updates'), offset = 4)
                      )
                      ,
                      
                      
                  
                      useShinyjs())
             
             
             
  ))
