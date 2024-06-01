library(readxl)
library(tidyverse)
library(dplyr)

all_vars_df <- readxl::read_xlsx("/Users/matthewcolantonio/Documents/Research/condemned_properties/all_vars_parcel.xlsx")
all_vars_df <- all_vars_df[,-c(1, 21:26, 28:32)] # remove extra columns from vector union
# dummy for slope > 25%
FINAL_parcel_pgh <- all_vars_df %>%
  mutate(slope25 = ifelse(slope25 == "Yes", 1, 0)) %>%
  mutate(slope25 = coalesce(slope25, 0))
# some N/As were added to the end of the df, probably in the vector union process in QGIS
FINAL_parcel_pgh <- na.omit(FINAL_parcel_pgh)
# rename columns
colnames(FINAL_parcel_pgh)<- c(
  "census_tract",
  "parcel_number",
  "year_built",
  "own_type",
  "zipcode",
  "census_block",
  "sqft",
  "condemned",
  "Unemployment_Rate",
  "Median_HH_Income",
  "Vacant_Housing_Units_Percentage",
  "Total_Housing_Units_Built_Before_1939_Percentage",
  "Tenure_Owner_Occupied_Percentage",
  "Median_Value_Owner_Occupied",
  "Median_Gross_Rent",
  "Total_Population",
  "Total_Population_White_Percentage",
  "Total_Population_Black_Percentage",
  "proximity_to_condemned",
  "slope25"
)

# save as FINAL csv for analysis and modelling
file_path <- "/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/FINAL_parcel_pgh.csv"
write.csv(FINAL_parcel_pgh, file = file_path, row.names = FALSE)
