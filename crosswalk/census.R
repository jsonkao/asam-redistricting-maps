#
# Library setup
#

suppressPackageStartupMessages(library(dplyr))
library(tidycensus)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')

#
# Get block populations from 2010 and 2020
#

blk_pop_2010 <- get_decennial(
  geography = "block",
  state = "New York",
  county = "Kings",
  variables = "P001001",
  year = 2010
) %>%
  select(GEOID, pop = value)

blk_pop_2020 <- get_decennial(
  geography = "block",
  state = "New York",
  county = "Kings",
  variables = "P1_001N",
  sumfile = "pl",
  year = 2020
) %>%
  select(GEOID, pop = value)

#
# Get block group Asian alone population from 2010
#

bg_pop_2010_asian <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = "P003005",
  year = 2010
) %>%
  select(GEOID, pop_asian = value)

#
# Get crosswalk
#

blk_crosswalk <- read.csv("crosswalk/nhgis_blk2010_blk2020_ge_36047.csv") %>%
  mutate(GEOID10 = as.character(GEOID10), GEOID20 = as.character(GEOID20)) %>%
  select(GEOID10, GEOID20, WEIGHT, PAREA)

#
# Disaggregate Asian population from 2010 block groups into 2010 blocks
#

blk_pop_2010_asian <- blk_pop_2010 %>%
  mutate(blk_group = substr(GEOID, 1, 12)) %>%
  group_by(blk_group) %>%
  mutate(proportion = pop / sum(pop)) %>%
  ungroup() %>%
  inner_join(bg_pop_2010_asian %>% rename(blk_group = GEOID), by = "blk_group") %>%
  mutate(pop_asian = pop_asian * proportion) %>%
  mutate(pop_asian = replace(pop_asian, is.na(pop_asian), 0)) %>%
  select(GEOID, pop_asian)

#
# Use NHGIS block-to-block crosswalk to interpolate Asian estimates from 2010 blocks to 2020 blocks,
# then sum the 2020 block-level estimates of 2010 Asian population within each 2020 block group.
#

bg2020_pop_2010_asian <- blk_crosswalk %>%
  inner_join(blk_pop_2010_asian %>% rename(GEOID10 = GEOID), by = "GEOID10") %>%
  mutate(pop_asian = pop_asian * WEIGHT) %>%
  select(GEOID = GEOID20, pop_asian) %>%
  mutate(blk_group = substr(GEOID, 1, 12)) %>%
  group_by(blk_group) %>%
  summarize(pop_asian = sum(pop_asian)) %>%
  rename(GEOID = blk_group)

# Sanity check: total sum is still the same after weighting? It still is.
stopifnot(
  round(bg2020_pop_2010_asian %>% pull(pop_asian) %>% sum()) == round(bg_pop_2010_asian %>% pull(pop_asian) %>% sum())
)

#
# Now we have 2010's Asian population in 2020 block groups. Join it with 2020's Asian population.
#

bg_pop_2020_asian <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = "P1_006N",
  sumfile = "pl",
  year = 2020
) %>%
  select(GEOID, pop_asian = value)

output <- inner_join(
  bg2020_pop_2010_asian,
  bg_pop_2020_asian,
  by = "GEOID",
  suffix = c("_2010", "_2020")
)

# Sanity check: did Brooklyn's Asian population grow by 43%? The output below says 1.4248. Close enough?
output %>%
  summarize(sum(pop_asian_2020) / sum(pop_asian_2010, na.rm = T))

#
# Write output
#

output %>%
  write.csv(commandArgs(trailingOnly = TRUE)[[1]], row.names = FALSE)
