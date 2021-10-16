#' ---
#' title: "Getting 2010 and 2020 Asian populations on the same block group geography"
#' author: "Jason Kao"
#' ---


#' Library installation and configuration.

knitr::opts_chunk$set(message = FALSE)
suppressPackageStartupMessages(library(dplyr))
library(tidycensus)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')

#' ### Disaggregation

#' First, retrieve block-level data for the total population in Brooklyn in both 2010 and 2020.

# Get 2010 data
blk_pop_2010 <- get_decennial(
  geography = "block",
  state = "New York",
  county = "Kings",
  variables = "P001001",
  year = 2010
) %>%
  select(GEOID, pop = value)

# Get 2020 data
blk_pop_2020 <- get_decennial(
  geography = "block",
  state = "New York",
  county = "Kings",
  variables = "P1_001N",
  sumfile = "pl",
  year = 2020
) %>%
  select(GEOID, pop = value)

#' Next, get the Asian Alone population from 2010 at the block group level.

bg_pop_2010_asian <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = "P003005",
  year = 2010
) %>%
  select(GEOID, pop_asian = value)

#' Allocate the 2010 block-group-level Asian population among 2010 blocks in proportion to the blocks' total populations.

blk_pop_2010_asian <- blk_pop_2010 %>%
  mutate(blk_group = substr(GEOID, 1, 12)) %>%
  group_by(blk_group) %>%
  mutate(proportion = pop / sum(pop)) %>%
  ungroup() %>%
  inner_join(bg_pop_2010_asian %>% rename(blk_group = GEOID), by = "blk_group") %>%
  mutate(pop_asian = pop_asian * proportion) %>%
  mutate(pop_asian = replace(pop_asian, is.na(pop_asian), 0)) %>%
  select(GEOID, pop_asian)

#' ### Interpolation and reaggregation

#' Read in the NHGIS 2010 block to 2020 block crosswalk.

blk_crosswalk <-
  read.csv("./nhgis_blk2010_blk2020_ge_36047.csv") %>%
  mutate(GEOID10 = as.character(GEOID10), GEOID20 = as.character(GEOID20)) %>%
  select(GEOID10, GEOID20, WEIGHT, PAREA)

#' Use the crosswalk to interpolate the Asian population from 2010 blocks to 2020 blocks. Then, sum the 2020 block-level data within each 2020 block group to get the 2010 Asian population in 2020 block groups.

bg2020_pop_2010_asian <- blk_crosswalk %>%
  inner_join(blk_pop_2010_asian %>% rename(GEOID10 = GEOID), by = "GEOID10") %>%
  mutate(pop_asian = pop_asian * WEIGHT) %>%
  select(GEOID = GEOID20, pop_asian) %>%
  mutate(blk_group = substr(GEOID, 1, 12)) %>%
  group_by(blk_group) %>%
  summarize(pop_asian = sum(pop_asian)) %>%
  rename(GEOID = blk_group)

#' Sanity check: is the total number of Asian people still the same after switching from 2010 block groups to 2020 block groups? Yes.
stopifnot(
  round(bg2020_pop_2010_asian %>% pull(pop_asian) %>% sum()) ==
    round(bg_pop_2010_asian %>% pull(pop_asian) %>% sum())
)

#' We have interpolated 2010's Asian population to 2020 block groups. Now, download the 2020 block-group-level Asian population data so we can look at the two together.

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

#' Solid.
output %>% head

#' Sanity check: did Brooklyn's Asian population grow by 43%? The output below shows what fold the population increased by in our analysis.

output %>%
  summarize(fold = sum(pop_asian_2020) / sum(pop_asian_2010, na.rm = T))

#' 1.4248. Close enough?
#' 
#' Write out the output if desired.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  output %>%
    write.csv(args[[1]], row.names = FALSE)
}

