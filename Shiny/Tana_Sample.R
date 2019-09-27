library(tidyverse)

setwd("/Users/gather3/Documents/Kanyama - Data Exploration/Kanyama Data Exploration/data")
data <- read.csv(file = "Kanyama_organized.csv", stringsAsFactors = F)


data <- data %>% select(area.m3, CONTAINMENT.SUBSTRUCTURE, people.using.toilet, Last.time.emptied) %>% 
  filter(complete.cases(.) & grepl(pattern = "(Pit latrine|Septic Tank)", x = data$CONTAINMENT.SUBSTRUCTURE) )

data <- data %>% filter(people.using.toilet < 1000)

data <- data %>% mutate(CONTAINMENT.SUBSTRUCTURE = 
                          case_when(CONTAINMENT.SUBSTRUCTURE == "Pit latrine" ~ 500,
                                    CONTAINMENT.SUBSTRUCTURE == "Septic Tank" ~ 250,
                                    TRUE ~ 1))

numeric_stats <-data %>% summarise_if(is.numeric,
                                          list("~max" = ~max(., na.rm = T),
                                               "~min" = ~min(., na.rm = T),
                                               "~mean" = ~mean(., na.rm = T),
                                               "~median" =~median(., na.rm = T),
                                               "~sd" =~sd(., na.rm = T),
                                               "~mad" =~mad(., na.rm = T),
                                               "~IQR" =~IQR(., na.rm = T)))


numeric_stats <- gather(numeric_stats, "Name" , "Stats"  )
numeric_stats <- separate(numeric_stats, Name, c("Name","Metric"), sep = "~" )
numeric_stats <- spread(numeric_stats, "Metric", "Stats")
numeric_stats <- select(numeric_stats, c("Name", "min", "max","mean", "median", "sd", "mad", "IQR"))

# Creating the probs

prob_capacity <- data %>% group_by(area.m3) %>% summarise(count = n()/nrow(data))
prob_infrastructure <- data %>% group_by(CONTAINMENT.SUBSTRUCTURE) %>% summarise(count = n()/nrow(data))
prob_people <- data %>% group_by(people.using.toilet) %>% summarise(count = n())

x1 <- sample(prob_capacity$area.m3, nrow(data), replace=TRUE, prob= as.vector(prob_capacity$count))
x2 <- rnorm(nrow(data), mean = numeric_stats$median[4], sd = numeric_stats$sd[4])
x2 <- abs(x2)
x3 <- rnorm(nrow(data), mean = numeric_stats$median[3], sd = numeric_stats$sd[3])
x3 <- abs(x3)


# Creating the new locations

bb <- read.csv("bounding_box.csv")
mean_x <- median(bb$xcoord)
mean_y <- median(bb$ycoord)
sd_x <- sd(bb$xcoord)
sd_y <- sd(bb$ycoord)

latitude <- rnorm(nrow(data), mean = mean_y, sd = sd_y)
longitude <- rnorm(nrow(data), mean = mean_x, sd = sd_x)

random_data <- data.frame(latitude, longitude, capacity = x1, people_using = x2, last_cleaned = x3)

# Add storage type conversion
random_data <- random_data %>% mutate(storage_type = 
                                        case_when(capacity == 4.5 ~ 2,
                                                  capacity == 12.5 ~ 1))

write.csv(random_data, file = "tana_sample.csv", row.names = F)


# Creating the formula

ToiletRisk <- function(perc.usage, df){
  sum.part <- sum( df$last_cleaned/(df$capacity + 1) * df$storage_type )
  return(perc.usage * sum.part/(nrow(df) + 1))
}

OpenRisk <- function(perc.usage){
  return(perc.usage * (365 / 1))
}

test_le <- c(rep(100, times = 5))  
test_cap <- c(rep(4.5, times = 5))
test_st <- c(rep(2, times = 5))
test <- data.frame(last_cleaned = test_le, capacity = test_cap, storage_type = test_st)  

# 365 = worst case, 100% in open defecation
(ToiletRisk(0.9, random_data) + OpenRisk(0.1)) * 100/365
(ToiletRisk(0.8, random_data) + OpenRisk(0.2)) * 100/365

# Testing the QGIS formula
test_le <- c(178,254,100.1)
test_cap <- c(4.5,12.5,12.5)
test_st <- c(2,1,1)
test <- data.frame(last_cleaned = test_le, capacity = test_cap, storage_type = test_st)  
ToiletRisk(0.9, test)


  
