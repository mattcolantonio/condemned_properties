library(readr)
library(tidycensus)
library(dplyr)
library(tidyr)
library(reshape2)

parcel_data <- read.csv("/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/residential_properties_pgh.csv")
# creating list of unique census blocks
unique_census_blocks <- unique(parcel_data$census_block)
# Convert the unique census blocks to a list
census_block_list <- as.list(unique_census_blocks)

# creating a list of unique census tracts
unique_census_tracts <- unique(parcel_data$census_tract)
# Convert the unique census blocks to a list
census_tract_list <- as.list(unique_census_tracts)

census_api_key("<enter key here>")

# Set the desired year
year <- 2021

# Specify the state and county (Allegheny, Pennsylvania)
state <- "PA"
county <- "Allegheny"

# Set the geography to "tract"
geography <- "tract"

# Create a list of variables for the API call
variables <- c(
  "DP03_0005PE",  # Unemployment rate
  "DP03_0062E",  # Median HH income
  "DP04_0003PE",  # Vacant housing units (%)
  "DP04_0026PE",  # Total housing units built before 1939 (%)
  "DP04_0046PE",  # Tenure: owner-occupied (%)
  "DP04_0089E",  # Median value owner-occupied
  "DP04_0134E",  # Median gross rent
  "DP05_0001E",  # Total population
  "DP05_0037PE",  # Total population white (%)
  "DP05_0038PE"   # Total population black (%)
)

# Use your list of unique census tracts for the API call
unique_census_tracts <- unique(parcel_data$census_tract)
filtered_census_tracts <- unique_census_tracts

# Create an empty data frame to store the results
economic_data <- data.frame()

# Loop through the filtered census tracts and fetch data
for (tract in filtered_census_tracts) {
  data <- get_acs(geography = geography, variables = variables, 
                  year = year, state = state, county = county, tract = tract)
  
  economic_data <- bind_rows(economic_data, data)
}

# Now, 'economic_data' contains the requested data for the specified variables in Allegheny, PA based on your unique census tracts
# what was downloaded?
# head(economic_data, 10)

# Further formatting...
economic_data <- economic_data[, !names(economic_data) %in% c("NAME", "moe")]
# Pivot the data frame to have 'variable' values as column names
# economic_data2 <- pivot_wider(economic_data, names_from = variable, values_from = estimate)
# economic_data2 <- economic_data2 %>% unnest(everything())

# numbers <- rep(1:12, 136)
# economic_data$Numbers <- numbers

wide_data <-  reshape(economic_data, idvar = "GEOID", timevar = "variable", direction = "wide")
economic_data_pgh <- wide_data

colnames(economic_data_pgh)<- c(
  "census_tract",
  "Unemployment_Rate",
  "Median_HH_Income",
  "Vacant_Housing_Units_Percentage",
  "Total_Housing_Units_Built_Before_1939_Percentage",
  "Tenure_Owner_Occupied_Percentage",
  "Median_Value_Owner_Occupied",
  "Median_Gross_Rent",
  "Total_Population",
  "Total_Population_White_Percentage",
  "Total_Population_Black_Percentage"
)

# save the census data separately
# file_path <- "/Users/matthewcolantonio/Documents/Research/condemned_properties/economic_data_pgh.csv"
# write.csv(economic_data_pgh, file = file_path, row.names = FALSE)


# Merge the two data frames by "census_tract"
all_data <- merge(parcel_data, economic_data_pgh, by = "census_tract", all = TRUE)
parcel_and_census <- all_data
# evaluate null values
parcel_and_census %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  glimpse()
# given the size of this datset (about 120,000 rows) there are relatively few missing values
# most missing is yearbuilt
# these losses can be offset by using built before 1939 (imputing this is useless)
# or we can scratch 22,000 rows and still have close to 90,000 obs
parcel_and_census <- na.omit(parcel_and_census)
# now save this dataframe (the file path is already determined)
file_path <- "/Users/matthewcolantonio/Documents/Research/condemned_properties/parcel_and_census.csv"
write.csv(parcel_and_census, file = file_path, row.names = FALSE)









