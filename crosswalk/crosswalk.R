#' ---
#' title: "Getting 2010 and 2020 Asian populations on the same block group geography"
#' author: "Jason Kao"
#' ---

#' Library installation and configuration.

knitr::opts_chunk$set(message = FALSE)
suppressPackageStartupMessages(library(dplyr))
library(tidycensus)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')

#' ### Creating a block-group-to-block-group crosswalk
#'
#' To interpolate many block-group statistics (e.g. Asian population, White population, Black population), we first make a block-group-to-block-group crosswalk.
#'
#' First, retrieve block-level population data in 2010.

blk_pop_2010 <- get_decennial(
  geography = "block",
  state = "New York",
  variables = "P001001",
  year = 2010
) %>%
  select(GEOID, pop = value)

#' Read in the NHGIS 2010 block to 2020 block crosswalk.

blk_crosswalk <-
  read.csv("./crosswalk/nhgis_blk2010_blk2020.csv") %>%
  mutate(GEOID10 = as.character(GEOID10), GEOID20 = as.character(GEOID20)) %>%
  select(GEOID10, GEOID20, WEIGHT, PAREA)

#' Interpolate the 2010 block-level population data from 2010 blocks to 2020 blocks.

blk2020_pop_2010 <- blk_crosswalk %>%
  inner_join(blk_pop_2010 %>% rename(GEOID10 = GEOID), by = "GEOID10") %>%
  mutate(pop_weighted = pop * WEIGHT)

#' Find the proportion of the 2010 block group’s population that lies in each 2020 block group.

bg_crosswalk <- blk2020_pop_2010 %>%
  mutate(blk_group10 = substr(GEOID10, 1, 12),
         blk_group20 = substr(GEOID20, 1, 12)) %>%
  group_by(blk_group10, blk_group20) %>%
  summarize(pop_weighted = sum(pop_weighted)) %>%
  inner_join(
    blk_pop_2010 %>% mutate(blk_group10 = substr(GEOID, 1, 12)) %>% group_by(blk_group10) %>% summarize(pop = sum(pop)),
    by = "blk_group10"
  ) %>%
  mutate(weight = pop_weighted / pop) %>%
  select(-pop_weighted, -pop) %>%
  ungroup()

#' This is our block-group-to-block-group (bg2bg) crosswalk.

bg_crosswalk %>% head

#' Save the crosswalk

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  bg_crosswalk %>% write.csv(args[[1]], row.names = FALSE)
}
