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
setwd("/Users/gather3/Documents/Madagascar/Shiny")
source('ui_modules.R')

lorem_ipsum <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vivamus arcu felis bibendum ut tristique et egestas quis. Et odio pellentesque diam volutpat commodo sed egestas egestas fringilla. Malesuada fames ac turpis egestas integer. Nulla posuere sollicitudin aliquam ultrices sagittis orci a. Libero id faucibus nisl tincidunt eget. Mi bibendum neque egestas congue. Proin sed libero enim sed. Erat imperdiet sed euismod nisi porta lorem. Velit ut tortor pretium viverra suspendisse potenti nullam ac. Mauris vitae ultricies leo integer malesuada nunc vel. Vivamus at augue eget arcu dictum varius duis at. Eleifend mi in nulla posuere sollicitudin aliquam ultrices sagittis orci. Aenean et tortor at risus viverra adipiscing."

# User interface ----
ui <- tagList(
  tags$head(tags$script(type="text/javascript", src = "code.js")),
  navbarPage(title = "Madagascar's Sanitation Risk (CUA 5)", id = "nav", theme = "style.css",
             
             tabPanel("Sanitation Risk", value = 0,
                      leafletOutput(outputId = "risk", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = 600,
                                    #Stats on the side
                                    h1("Sanitation Risk"),
                                    p(lorem_ipsum))
                                  
                                  
                      
             ),
             tabPanel("Toilet", value = 1,
                      
                      leafletOutput(outputId = "toilets", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = 600,
                                    h1("Toilet Location"),
                                    p(lorem_ipsum))
                      
                        
             ),
             tabPanel("Population", value = 2,
                      
                      leafletOutput(outputId = "population", height = 700)%>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = 600,
                                    h1("Population Density"),
                                    p(lorem_ipsum))
                      
             ),
             tabPanel("Rivers", value = 3,
                      leafletOutput(outputId = "rivers", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = 600,
                                    h1("River Density"),
                                    p(lorem_ipsum))
             ),
             
             tabPanel("Road", value = 4,
                      leafletOutput(outputId = "roads", height = 700) %>% withSpinner(type = 4),
                      absolutePanel(id = "waste", class = "panel panel-default", fixed = TRUE,
                                    draggable = F, top =140, left = "auto", right = 20, bottom = "auto",
                                    width = 330, height = 600,
                                    h1("Road Density"),
                                    p(lorem_ipsum)),
                  
                      useShinyjs())
             
             
             
  ))
