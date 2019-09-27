library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(lubridate)
library(scales)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)


Columns.Remover <- function(ds, percentage){
  
  
  selection <- apply(ds, 2, function(x)  (sum( !is.na(x) ) / nrow(ds)) > percentage )
  
  return(selection)
  
}

simplify <- function(df){
  df.reduced <- df %>% 
    select(-starts_with("DESCRIPTION OF RESPONDENT:"),
           -starts_with("SELECT ZONE (Other"), 
           -starts_with("SELECT ZONE SECTION (Other"),
           -`RECORD TYPE OF PROPERTY (Other (please specify)) - specify`,
           - `1.3 (Don't Know)`,
           - `1.5 (Don't Know)`,
           -`1.6.1 Do you think there is space on this plot to construct another toilet?: No - If Yes how many more? If No, why is that the case?`,
           -`1.6.2 (Other (please specify)) - specify`,
           -`1.7`,
           -`1.7.1`,
           -`2.1D`,
           -`What is the designation of the respondent?`,
           -`3.4 (Don't Know)`,
           -starts_with("3.5"),
           -starts_with("What do you want to upgrade your toilet"),
           -starts_with("What happens when the toilet gets full? (Other"),
           -ends_with("Months - Age"),
           -`3.7 (Other (please specify)) - specify`,
           -starts_with("3.7.1 ("),
           -starts_with("How did you know about the service of emptying your toilet"),
           -starts_with("How would you rate your level of satisfaction with the service you received from the emptiers?" ),
           -starts_with("3.7.3"),
           -starts_with("Was the fee you paid affordable? (" ),
           -starts_with("How often do you empty your toilet? ("),
           -starts_with("3.8"),
           -starts_with("4.1"),
           -starts_with("4.2"),
           -starts_with("4.3 SLAB"),
           -starts_with("4.3 INTERFACE ("),
           -starts_with("CONTAINMENT/SUBSTRUCTURE ("),
           -starts_with("Record the observed shape of the substructure/containment  ("),
           -starts_with("TAKE PHOTO OF"),
           -starts_with("TAKE  PHOTO OF"),
           -starts_with("4.8 (Don't Know)")
           
    )
  
  if(any(df.reduced$`Is there another toilet to observe` == "No")){
    
    index <- grep("Is there another", colnames(df.reduced)) + 1
    df.reduced <- select(df.reduced, -c(index:ncol(df.reduced)))
  }
  
  return(df.reduced)
}

grouping.columns <- function(df, column1, column2, name){
  
  res <- df
  # Remove the fields
  for (i in 1:length(names)) {
    res <- select(res, -starts_with(name[i])) 
  }
  # Uniting the columns
  for (i in 1:length(names)) {
    res <- mutate(res, !!name[i] := case_when(
      column1[[i]] == T ~ T,
      column1[[i]] != T & column2[[i]] == T ~ F,
      TRUE ~ NA))
    
  }
  
  return(res)
  
}


Fill.date <- function(area, number.people, fill.level, interview.date){
  
  days.to.fill <- Fill.time(area, number.people, fill.level)
  
  return(days.to.fill + as.Date(interview.date))
}


Fill.time <- function(area, number.people, fill.level, flow.rate = 1.28e-4){
  # Bathroom fill time preview based on:
  # Average human fecal waste per day = 0.000128 g
  # density similar to water
  
  fill.level <- case_when(fill.level == "Empty" ~ 0.0,
                          fill.level == "Almost empty" ~ 0.25,
                          fill.level == "Half-full" ~ 0.5,
                          fill.level == "Almost full" ~ 0.75,
                          fill.level == "Full" ~ 0.9,
                          TRUE ~ 0.5)
  
  days.to.fill <- ((1  - fill.level) * area) / (number.people * flow.rate)
  return( days.to.fill )
  
}

plot.time.series <- function(df, x.axis, y.axis, colour = "blue", colour.legend = "Legend: ", title = "Plot", method = geom_line, y.name = "Number of Occurences"){
  
  if(is.null(method)){
    method = geom_line
  }
  if(is.null(colour)){
    colour = "blue"
  }
  if(length(colour) == 1){
    
    plot <- ggplot(data = df, aes(x = x.axis)) + 
      method(aes(y = y.axis ), colour = colour, se = F, method = "loess") +
      labs(title= title, 
           subtitle="Need of waste management team",
           caption = "Source: WSUP",
           y=y.name,
           colour = colour.legend) + 
      theme_bw()+
      scale_x_date(labels = date_format(format = "%b %Y"),breaks = "1 month") +
      theme(axis.text.x = element_text(angle = 90, vjust=0.5),  # rotate x axis text
            panel.grid.minor = element_blank(),
            axis.title.x = element_blank(),
            legend.position = "bottom")
    
  } else {
    
    plot <- ggplot(data = df, aes(x = x.axis)) + 
      method(aes(y = y.axis , colour = colour), se = F, method = "loess") +
      labs(title="2019 Time Series", 
           subtitle="Need of waste management team", 
           caption = "Source: WSUP",
           y=y.name,
           colour = colour.legend) + 
      theme_bw()+
      scale_x_date(labels = date_format(format = "%b %Y"),breaks = "1 month") +
      theme(axis.text.x = element_text(angle = 90, vjust=0.5),  # rotate x axis text
            panel.grid.minor = element_blank(),
            axis.title.x = element_blank(),
            legend.position = "bottom") 
  }
  # instead of returning the plot, save images in a folder
  # ggsave
  return(plot)
  
}

colourTest <- function(attribute){
  if(length(levels(factor(attribute))) > 1){
    colour <- attribute
  } else{
    colour <- "Orange"
  }
  
  return(colour)
}



in_bounding_box <- function(data, lat, long, bounds) {
 data <- data %>% 
   filter(
      lat > bounds$south &
      lat < bounds$north &
      long < bounds$east & 
      long > bounds$west 
    )
  
  return(data)
}

HTML_labels<-function(attribute, text = "people / km<sup>2</sup>"){
  labels <- sprintf(
    paste("%g", text),
    attribute
  ) %>% lapply(htmltools::HTML)
  
  return(labels)
}
