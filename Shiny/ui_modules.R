library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(lubridate)
library(scales)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)

# This one is working
defaultSidebarPanel <- function(id, radio.label = "options:", radio.options, slider.label = "Select a Year",
                    date.select, dateRange.label = "Month Selection"){
  
  ns <- NS(id)
  
  
  sidebarPanel(
    
    radioButtons(ns("plot.selection"), 
                 label = radio.label,
                 radio.options),
    br(),
    
    sliderInput(ns("year.selection"),
                label = slider.label,
                value = year(Sys.Date()),
                min = min(year(date.select), na.rm = T),
                max = 2025, 
                sep = ""),
    br(),
    
    actionBttn(ns("detail"), "Enable month selection",
               size = "sm", 
               color = "primary",
               style = "jelly"
    ),
    
    br(),
    br(),
    
    dateRangeInput(ns("month.selection"),dateRange.label ,
                   min = min(date.select, na.rm = T),
                   max = "2025-12",
                   end = Sys.Date() + 250,
                   format = "M-yyyy",
                   startview = "year"
    )
  )
  
}

defaultMainPanel <- function(id, names){
  
  
  ns <- NS(id)
  print(names)
  mainPanel(
    
    tabsetPanel(type = "tabs", id = ns("tabset"),
                tabPanel("General",
                         plotOutput(outputId = names[1], height = "400px"),
                         plotOutput(outputId = names[2])),
                tabPanel("Transports",
                         plotOutput(outputId = names[3]),
                         plotOutput(outputId = names[4])
                )
                
    ),
    br()
  )
  
}
