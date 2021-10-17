#' ---
#' title: "Getting 2010 and 2020 Asian populations on the same block group geography"
#' author: "Jason Kao"
#' ---


#' Library installation and configuration.

knitr::opts_chunk$set(message = FALSE)
suppressPackageStartupMessages(library(dplyr))
library(tidycensus)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')

#' ## Generating a block-group-to-block-group crosswalk
#' 
#' To be able to interpolate many block-group statistics (e.g. Asian population, White population, Black population), we first make a block-group-to-block-group crosswalk.

#' ### TITLE

#' First, retrieve block population data in Brooklyn in both 2010 and 2020.

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

#' Next, get the 2010 population data we want to interpolate at the block group level.

bg_pop_2010 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = c(asian = "P003005", total = "P001001"),
  year = 2010
) %>%
  select(blk_group = GEOID,
         group = variable,
         pop = value)

#' Allocate the 2010 block-group-level data among 2010 blocks in proportion to the blocks' total populations. Keep information about the original population so we can make a crosswalk.

blk_pop_2010_distributed <- blk_pop_2010 %>%
  mutate(blk_group = substr(GEOID, 1, 12)) %>%
  group_by(blk_group) %>%
  mutate(proportion = pop / sum(pop)) %>%
  mutate(proportion = replace(proportion, is.na(proportion), 0)) %>%
  ungroup() %>%
  select(GEOID, blk_group, proportion) %>%
  inner_join(bg_pop_2010, by = "blk_group") %>%
  mutate(pop_distributed = pop * proportion) %>%
  select(GEOID, group, pop_distributed)

#' ### Interpolation and reaggregation

#' Read in the NHGIS 2010 block to 2020 block crosswalk.

blk_crosswalk <-
  read.csv("./nhgis_blk2010_blk2020_ge_36047.csv") %>%
  mutate(GEOID10 = as.character(GEOID10), GEOID20 = as.character(GEOID20)) %>%
  select(GEOID10, GEOID20, WEIGHT, PAREA)

#' Use 2010 block-level total population data to make a block-group-to-block-group crosswalk.

bg_crosswalk <- blk_crosswalk %>%
  inner_join(blk_pop_2010 %>% rename(GEOID10 = GEOID), by = "GEOID10") %>% 
  mutate(pop_weighted = pop * WEIGHT) %>% 
  mutate(blk_group10 = substr(GEOID10, 1, 12), blk_group20 = substr(GEOID20, 1, 12)) %>% 
  group_by(blk_group10, blk_group20) %>% 
  summarize(pop_weighted = sum(pop_weighted)) %>% 
  inner_join(
    blk_pop_2010 %>% mutate(blk_group10 = substr(GEOID, 1, 12)) %>% group_by(blk_group10) %>% summarize(pop = sum(pop)),
    by = "blk_group10"
  ) %>% 
  mutate(weight = pop_weighted / pop) %>% 
  select(-pop_weighted, -pop) %>%
  ungroup()

#' Use the bg2bg crosswalk to interpolate 2010 population data from 2010 block groups into 2020 block groups.
 
bg2020_pop_2010 <- bg_crosswalk %>% 
  inner_join(bg_pop_2010 %>% rename(blk_group10 = blk_group), by = "blk_group10") %>% 
  mutate(pop_weighted = pop * weight) %>% 
  select(GEOID = blk_group20, group, pop = pop_weighted) %>% 
  group_by(GEOID, group) %>% 
  summarize(pop = sum(pop))
  
#' Use the crosswalk to interpolate the 2010 population data from 2010 blocks to 2020 blocks. Then, sum the 2020 block-level data within each 2020 block group to get the 2010 population data in 2020 block groups.

bg2020_pop_2010 <- blk_crosswalk %>%
  inner_join(blk_pop_2010_distributed %>% rename(GEOID10 = GEOID), by = "GEOID10") %>%
  mutate(pop_distributed_weighted = pop_distributed * WEIGHT) %>%
  select(GEOID10, GEOID20, group, pop_distributed, pop_distributed_weighted) %>%
  mutate(blk_group20 = substr(GEOID20, 1, 12), blk_group10 = substr(GEOID10, 1, 12)) %>%
  group_by(blk_group20, blk_group10, group) %>%
  summarize(pop_old = sum(pop_distributed), pop = sum(pop_distributed_weighted)) %>%
  rename(GEOID = blk_group20)

#' Sanity check: is the total number of Asian people still the same after switching from 2010 block groups to 2020 block groups? Yes.
stopifnot(
  round(
    bg2020_pop_2010 %>% filter(group == "asian") %>% pull(pop) %>% sum(na.rm = T)
  ) ==
    round(bg_pop_2010 %>% filter(group == "asian") %>% pull(pop) %>% sum())
)

#' We have interpolated 2010's population data to 2020 block groups. We can use this to make a crosswalk.


#' We have interpolated 2010's population data to 2020 block groups. Now, download 2020 block-group-level population data so we can look at both years together.

bg_pop_2020 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = c(total = "P1_001N", asian = "P1_006N"),
  sumfile = "pl",
  year = 2020
) %>%
  select(-NAME) %>%
  rename(group = variable, pop = value)

output <- inner_join(
  bg2020_pop_2010,
  bg_pop_2020,
  by = c("GEOID", "group"),
  suffix = c("_2010", "_2020")
)

#' Solid.
output %>% head

#' Sanity check: did Brooklyn's Asian population grow by 43% while the rest of the county grew 9%? The output below shows what fold the population increased by in our analysis.

output %>%
  group_by(group) %>%
  summarize(fold = sum(pop_2020, na.rm = T) / sum(pop_2010, na.rm = T))

#' Write out the output if desired.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  output %>%
    write.csv(args[[1]], row.names = FALSE)
}
