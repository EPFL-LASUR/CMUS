#load required libraries
library(tidyverse)
library(lubridate)
library(sf)
library(lwgeom)

#load Swiss administrative boundaries data that you just downloaded
ab_path <- "/Users/Downloads/swissboundaries3d_2025-01_2056_5728/swissBOUNDARIES3D_1_5_TLM_HOHEITSGEBIET.shp"
ab <- st_read(ab_path)%>% st_zm()
glimpse(ab)
#map the municipalities boundaries to get a sense of what the dataset looks like
ggplot(data = ab) + geom_sf(aes(fill = EINWOHNERZ)) + scale_fill_viridis_c(trans = scales::pseudo_log_trans(sigma = 0.001))

#load the panel lémanique GPS tracks data that you just downloaded
gps_path <- "/Users/Documents/GPS_data/CMUS_GPS_data.shp"
gps <- st_read(gps_path)
glimpse(gps)

#map the GPS tracks to get a sense of the geographical extent of the dataset
ggplot(data = gps) + geom_sf(aes(fill = mode)) 

#plot number of trips by trip purpose
gps_no_geo <- gps %>% as.data.frame()
gps_no_geo %>% summarise(Num_trips=n(), .by = leading_st) %>% 
  arrange(-Num_trips)

#plot total trip distance by date
gps_no_geo %>% summarise(Sum_dist=sum(length_leg), .by = legs_date) %>% 
  arrange(legs_date)

#compute modal share (in number of trips and distance traveled) and median trip distance
gps_no_geo %>% group_by(mode) 
#insert missing code here

#compute average speed, trip length and duration by mode of transport
gps_no_geo %>% group_by(mode) 
#insert missing code here

#reproject GPS traces to local coordinate reference system (CRS) EPSG:2056
gps_reproj <- st_transform(gps, st_crs(ab)) 
ab_clean <- ab %>% select(NAME, EINWOHNERZ,geometry)

#spatial join between GPS traces and municipalities (ensure they have the same CRS)
gps_ab <- st_join(gps_reproj,ab_clean,join = st_intersects)

#count how many trips traverse each municipality (ensure data.frame format for dplyr)
gps_ab %>% as.data.frame() #insert missing code here

#extract endpoints from each leg, to get origins and destinations
origins <- lwgeom::st_startpoint(gps_reproj)
destinations #insert missing code here

#count how many trips start/end each municipality (ensure data.frame format for dplyr)
orig_ab <- st_join(st_sf(origins),ab_clean,join = st_intersects)
dest_ab #insert missing code here
orig_ab %>% as.data.frame() %>%group_by(NAME) %>% summarise(Num_trips = n()) %>% arrange(-Num_trips)
dest_ab #insert missing code here