library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(rgdal)
library(raster)
library(plotly)
library(lubridate)
library(scales)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(viridis)
library(shinycssloaders)

setwd("/Users/gather3/Documents/Madagascar/Shiny")
source('server_modules.R')
source('functions.R')

df <- read.csv("/Users/gather3/Documents/Madagascar/inputs/Risk_Toilets_Final.csv")

# CUA5
CUA5 <- readOGR("/Users/gather3/Documents/Madagascar/Shapefiles/CUA5.shp",GDAL1_integer64_policy = TRUE)
CUA5 <- spTransform(CUA5, CRS("+proj=longlat +datum=WGS84 +no_defs"))

# CUA5 Population
CUA5_Pop <- readOGR("/Users/gather3/Documents/Madagascar/Shapefiles/POP-CUA5.shp",GDAL1_integer64_policy = TRUE)
CUA5_Pop <- spTransform(CUA5_Pop, CRS("+proj=longlat +datum=WGS84 +no_defs"))

# CUA5 Roads
CUA5_Roads <- readOGR("/Users/gather3/Documents/Madagascar/Shapefiles/CUA5-Roads.shp",GDAL1_integer64_policy = FALSE)
CUA5_Roads <- spTransform(CUA5_Roads, CRS("+proj=longlat +datum=WGS84 +no_defs"))

# CUA5 Rivers
CUA5_Rivers <- readOGR("/Users/gather3/Documents/Madagascar/Shapefiles/CUA5-River.shp",GDAL1_integer64_policy = TRUE)
CUA5_Rivers <- spTransform(CUA5_Rivers, CRS("+proj=longlat +datum=WGS84 +no_defs"))

# CUA5 Risk
CUA5_Risk <- readOGR("/Users/gather3/Documents/Madagascar/Shapefiles/Final_Risk.shp",GDAL1_integer64_policy = TRUE)
CUA5_Risk<- spTransform(CUA5_Risk, CRS("+proj=longlat +datum=WGS84 +no_defs"))


# Server ----
server <- function(input, output, session) {
  # Bounding box filter (If the stats are being used)
  boundingBox <- reactive({
    if(!is.null(input$toilets_bounds)){
      Map <- in_bounding_box(df, df$latitude, df$longitude, input$toilets_bounds)
    } else {
      Map
    }
    
  })
  
  output$toilets <- renderLeaflet({
    
    icons <- awesomeIcons(
      icon = 'bath',
      iconColor = '#FFFFFF',
      library = 'fa',
      markerColor = "darkred"
    )
    leaflet(data = df) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addAwesomeMarkers(lng = ~longitude,
                       lat = ~latitude,
                       popupOptions = popupOptions(closeOnClick = T),
                
                       icon = icons) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 1, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 2 3",
                   fillColor = "Blue")
    
    
  })

  bins <- c(592, 3399, 6111, 10025, 27272, 113693)
  pal_risk <- colorBin("RdYlGn", domain = CUA5_Risk$FInal_RISK, bins = bins, na.color = "#FFFFFF00" )
  bins <- c(0, 30, 65, 104, 334, 2116)
  pal_pop <- colorBin("PuRd", domain = CUA5_Pop$Pop_Densit, bins = bins)
  bins <- c(2009, 5972, 7130, 8674, 9913, 12920)
  pal_road <- colorBin("Oranges", domain = CUA5_Pop$DN, bins = bins)
  bins <- c(0, 63, 1389, 4275)
  pal_riv <- colorBin("Blues", domain = CUA5_Pop$DN, bins = bins)
  
  
  output$risk <- renderLeaflet({
    
    leaflet(data = CUA5_Risk) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 3, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 6 2",
                   fillColor = "Blue") %>% 
      addPolygons(fillColor = ~pal_risk(FInal_RISK), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.1, fillOpacity = 0.9,
                  label = HTML_labels(CUA5_Risk$FInal_RISK),
                  highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    opacity = 0.7,
                    bringToFront = TRUE)
      ) %>%
      addLegend(title = "Risk",position = "bottomleft", values = ~FInal_RISK,
                pal = pal_risk,
                na.label = "Not Available",
                labels = c("Very low", "Low", "Medium", "High", "Very high")
      )
  })
  
  output$risk_w_pop <- renderLeaflet({
    
    leaflet(data = CUA5_Pop) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 3, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 6 2",
                   fillColor = "Blue") %>% 
      addPolygons(fillColor = ~pal_pop(Pop_Densit), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.1, fillOpacity = 0.9,
                  label = HTML_labels(CUA5_Pop$Pop_Densit),
                  highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    opacity = 0.7,
                    bringToFront = TRUE)
      ) %>%
      addLegend(title = "Population Density",position = "bottomleft", values = ~Pop_Densit,
                pal = pal_pop,
                labels = c("Very low", "Low", "Medium", "High", "Very high")
      )
  })
  
  
  output$population <- renderLeaflet({
    
    leaflet(data = CUA5_Pop) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 3, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 6 2",
                   fillColor = "Blue") %>% 
    addPolygons(fillColor = ~pal_pop(Pop_Densit), color = "#444444", weight = 1, smoothFactor = 0.5,
                opacity = 0.1, fillOpacity = 0.9,
                label = HTML_labels(CUA5_Pop$Pop_Densit),
                highlightOptions = highlightOptions(
                  weight = 5,
                  color = "#666",
                  opacity = 0.7,
                  bringToFront = TRUE)
                ) %>%
      addLegend(title = "Population Density",position = "bottomleft", values = ~Pop_Densit,
                pal = pal_pop,
                labels = c("Very low", "Low", "Medium", "High", "Very high")
                                                                 )
  })
  
  output$rivers <- renderLeaflet({
    
    leaflet(data = CUA5_Rivers) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 3, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 6 2",
                   fillColor = "Blue") %>% 
      addPolygons(fillColor = ~pal_riv(LENGTH), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.1, fillOpacity = 0.9, 
                  label = HTML_labels(CUA5_Rivers$LENGTH, "meters"),
                  highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    opacity = 0.7,
                    bringToFront = TRUE)) %>% 
      addLegend(title = "River Density",position = "bottomleft",
                values = ~LENGTH,pal = pal_riv,
                labels = c("Very low", "Low", "Medium", "High", "Very high")
                  )
  })
  
  output$roads <- renderLeaflet({
    
    leaflet(data = CUA5_Roads) %>% addProviderTiles(providers$Esri.WorldTopoMap) %>% 
      addPolylines(data = CUA5, color = "Black", weight = 3, smoothFactor = 0.5,
                   opacity = 1.0, fillOpacity = 1, dashArray ="4 6 2",
                   fillColor = "Blue") %>% 
      addPolygons(fillColor = ~pal_road(LENGTH), color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 0.1, fillOpacity = 0.9,
                  label = HTML_labels(CUA5_Roads$LENGTH/1000, "Kilometres"),
                  highlightOptions = highlightOptions(
                    weight = 5,
                    color = "#666",
                    opacity = 0.7,
                    bringToFront = TRUE)) %>% 
      addLegend(title = "Road density",position = "bottomleft",
                  values = ~LENGTH,pal = pal_road,
                  labels = c("Very low", "Low", "Medium", "High", "Very high")
                  )
  })
  
  
  
  
  
}
