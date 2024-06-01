library(readr)
library(geosphere)
library(sf)
library(sp)

# setwd("/Users/matthewcolantonio/Documents/Research/condemned_properties")
total_data <- read_csv("/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/parcel_and_census.csv")

condemned_parcels <- total_data[total_data$condemned == 1, c("lat", "lon")]

# Calculate distances to condemned parcels for all parcels
total_data$proximity_to_condemned <- sapply(
  1:nrow(total_data),
  function(i) {
    point <- total_data[i, c("lat", "lon")]
    if (nrow(condemned_parcels) > 0) {
      min(distVincentySphere(point, condemned_parcels))
    } else {
      # If there are no condemned parcels, set proximity to NA
      NA
    }
  }
)

# Optionally, you can set a threshold distance to determine proximity, e.g., 1000 meters
#total_data$proximity_to_condemned <- ifelse(
  #total_data$proximity_to_condemned <= 500,
  #1,
  #0
#)

# parcel_census_proximity <- total_data
# file_path <- "/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/parcel_census_proximity.csv"
# write.csv(parcel_census_proximity, file = file_path, row.names = FALSE)


# create shapefile for input in GIS software
df <- read_csv("/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/parcel_census_proximity.csv")

sf_df <- st_as_sf(df, coords = c("lon", "lat")) # create spatial dataframe
st_crs(sf_df) <- 4326 # set the CRS to WGS 84
# st_write(sf_df, "/Users/matthewcolantonio/Documents/Research/condemned_properties/saveddata/parcel_spatial.shp")


