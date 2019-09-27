library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(lubridate)
library(scales)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)


plotProcessing <- function(input, output, session, selection, datasetOne, datasetTwo, attribute = "number.of.cases"){
  
  if(selection == 0){
    result <- datasetOne
    result$date.full <- as.Date(result$date.full)
    result<- filter(result, year(result$date.full) == input$year.selection)
    
  }
  else{
    
    result<- filter(datasetTwo, 
                    datasetTwo$date.full > input$month.selection[1] & Daily.plot$date.full < input$month.selection[2] )
    
    
  }
  
  return(result)
  
  
  
  
}

sliderPlotProcessing <- function(input, output, session, result){
  
  result$date.full <- as.Date(result$date.full)
  result<- filter(result, year(result$date.full) == input$year.selection)
  
  # if(length(levels(factor(result$Transport))) == 3){
  #   colour <- result$Transport
  # }
  
  return(result)
}

dateRangePlotProcessing <- function(input, output, session, result){
  
  result$date.full <- as.Date(result$date.full )
  result<- filter(result, result$date.full > input$month.selection[1] & result$date.full < input$month.selection[2])
  
  return(result)
  
}

disableRadioOptions <- function(input, output, session, values){
  
  observe({
    if(input$tabset == 'General') {
      disable("plot.selection")
    } else {
      enable("plot.selection")
    }
  })
}
  

activateDetailedView <- function(input, output, session, values){
 
   observeEvent(input$detail,{
    values$active = !values$active
    if(values$active == T){
      updateActionButton(session, inputId = "detail", label = "Disable month selection" )
      enable(id = "month.selection")
      disable(id = "year.selection")
      
    } else {
      updateActionButton(session, inputId = "detail", label = "Enable month selection" )
      disable(id = "month.selection")
      enable(id = "year.selection")

    }
    

    
  })
}

refreshButton<- function(input, output, session, values){
  values$active = FALSE
  disable("month.selection")
  enable("year.selection")
  updateActionButton(session, inputId = "detail", label = "Enable month selection" )

}

startSettings <- function(input, output, session, values){
  
  disable("month.selection")
  updateActionButton(session, inputId = "detail", label = "Enable month selection" )
  
}
  

plotSelected <- function(input, output, session){
  
 answer <- reactiveValues()
 
 observe({answer$sel <- input$plot.selection})
  
 return(answer)
}  

  