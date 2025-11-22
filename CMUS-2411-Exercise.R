library(tidyverse)
#load the panel lémanique GPS tracks data that you had previously downloaded
gps_path <- "/Users/Documents/GPS_data/CMUS_GPS_data.shp"
gps <- st_read(gps_path)
#today, we won't need the geometry information so we can get rid of it
gps_no_geo <- gps %>% as.data.frame()
glimpse(gps_no_geo)
#load the mobitool CO2 emission factors
mobitool <- read_csv("/Users/Documents/CMUS/facteurs_mobitool_simpl.csv")
mobitool
#let's join the emission reduction factors to our GPS dataset
gps_emissions <- left_join(gps_no_geo,mobitool,by="mode")
#let's compute the emissions in kg CO2 associated with each trip
gps_emissions <- gps_emissions %>% mutate(kgCO2 = gCO2pkm * length_leg / 10^6)
#let's compute the overall emissions by date, and see when peak emissions occurred
gps_emissions%>%group_by(XXX)%>%summarise(YYY = sum(ZZZ, na.rm=TRUE))
#let's compute the overall share of emissions by mode, and see which modes represent the largest share of emissions
gps_emissions%>%group_by(XXX)%>%summarise(YYY = sum(ZZZ, na.rm=TRUE))