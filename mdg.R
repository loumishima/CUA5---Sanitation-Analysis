library(tidyverse)
library(ggplot2)

setwd("/Users/gather3/Documents/Madagascar/inputs")

select_columns <- function(df){
  
  name <- deparse(substitute(df))
  print(name)
  df %>% select("YEAR (CODE)","COUNTRY (CODE)", !!name := "Display Value")
  
  
}

asylum <- read_csv("asylum.csv")

difteria <- read_csv("difteria.csv")
difteria <-  select_columns(difteria)
yellow_fever <- read_csv("febre_amarela.csv")
yellow_fever <- select_columns(yellow_fever)
meningite <- read_csv("meningite.csv")
meningite <- select_columns(meningite)
plague <- read_csv("plague.csv") 
plague <- select_columns(plague)
cholera <- read_csv("cholera.csv")
cholera <- select_columns(cholera)

expense_health <- read_csv("expense_health.csv")
life_expectancy <-read_csv("life_expectancy.csv")
percentual_expenditure <- read_csv("total_expenditure.csv")

indicator_data <- read_csv("indicator_data_mg.csv")
health_page <- read_csv("health_page.csv")



diseases <- reduce(list(difteria, yellow_fever, meningite, plague, cholera),
                   function(...) full_join(..., by = c("YEAR (CODE)", "COUNTRY (CODE)")))

diseases$`YEAR (CODE)` <- as.numeric(diseases$`YEAR (CODE)`)
