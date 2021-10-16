#
# Library setup
#

suppressPackageStartupMessages(library(dplyr))
library(tidycensus)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')
options(dplyr.summarise.inform = F)

#
# Get block group populations from 2010 and 2020
#

blk_pop_2010 <- get_decennial(geography = "block",
                             state = "New York",
                             county = "Kings",
                             variables = "P001001",
                             year = 2010) %>% 
  select(GEOID, population = value)

blk_pop_2020 <- read.csv('productDownload_2021-10-16T122117/DECENNIALPL2020.P1_data_with_overlays_2021-10-16T122109.csv') %>% 
  slice(-1) %>% 
  select(GEOID = GEO_ID, population = P1_001N) %>% 
  mutate(GEOID = substr(GEOID, 10, 25), population = as.numeric(population))

#
# Get crosswalk
#

# TODO

#
# Turn blk -> blk crosswalk into bg -> bg crosswalkl using blk populations
#

# TODO
