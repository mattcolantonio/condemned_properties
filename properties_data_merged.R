
rm(list = ls()) 
gc()
cat("\f")

packages <- c("readr", #open csv
              "psych", # quick summary stats for data exploration,
              "stargazer", #summary stats for sharing,
              "tidyverse", # data manipulation like selecting variables,
              "corrplot", # correlation plots
              "ggplot2", # graphing
              "ggcorrplot", # correlation plot
              "gridExtra", #overlay plots
              "data.table", # reshape for graphing 
              "car", #vif
              "prettydoc", # html output
              "visdat", # visualize missing variables
              "glmnet", # lasso/ridge
              "caret", # confusion matrix
              "MASS", #step AIC
              "plm", # fixed effects demeaned regression
              "lmtest", # test regression coefficients
              "fpp3", # Foprecasting: Principles & Practice supplement
              "tsibble", # ts 
              "tsibbledata", #ts
              "lubridate",
              "forecast"
)

for (i in 1:length(packages)) {
  if (!packages[i] %in% rownames(installed.packages())) {
    install.packages(packages[i]
                     , repos = "http://cran.rstudio.com/"
                     , dependencies = TRUE
    )
  }
  library(packages[i], character.only = TRUE)
}

rm(packages)

# Regrid data for all parcels in Allegheny County
all <- read_csv("/Users/matthewcolantonio/Documents/Research/condemned_properties/rawdata/pa_allegheny.csv")

pgh <- all[all$scity == "PITTSBURGH" & all$schooldesc == "Pittsburgh", ]

pgh2 <- pgh[, c("parcelnumb", "zoning_description", "yearbuilt", "owntype", "szip", "neighborhood", 
                "lat", "lon", "census_tract", "census_block", "sqft")]

# Data containing parcels condemned and slope data

condemned <- read_csv("/Users/matthewcolantonio/Documents/Research/condemned_properties/rawdata/condemned_pgh_102323.csv")
 

total <- merge(pgh2, condemned, by.x = "parcelnumb", by.y = "parcel_id", all = TRUE)

# - by.x specifies the column in pgh2 to use as the common identifier.
# - by.y specifies the column in condemned to use as the common identifier.
# - all = TRUE includes all rows from both data frames in the merged result.


total <- total[,c(1:5,7:11,17)]
totalr <- total[total$zoning_description == "RESIDENTIAL",] # really only interested in residential properties

# Assuming you have a data frame named 'total_data'

library(dplyr)

totalr <- totalr %>%
  mutate(condemned = ifelse(latest_inspection_result == "Fail", 1, 0)) %>%
  mutate(condemned = coalesce(condemned, 0))

residential_properties_pgh <- totalr[,c(1,3:10,12)]

# save the file with residential proeprty data/condemnation status

file_path <- "/Users/matthewcolantonio/Documents/Research/condemned_properties/residential_properties_pgh.csv"
write.csv(residential_properties_pgh, file = file_path, row.names = FALSE)


