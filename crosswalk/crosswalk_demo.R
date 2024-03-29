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
#' First, retrieve block-level population data in New York State in 2010.

blk_pop_2010 <- get_decennial(
  geography = "block",
  state = "New York",
  variables = "P001001",
  year = 2010
) %>%
  select(GEOID, pop = value)

#' Read in the NHGIS 2010 block to 2020 block crosswalk.

blk_crosswalk <-
  read.csv("./crosswalk/nhgis_blk2010_blk2020_ge_36.csv") %>%
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

#' Save the crosswalk in [bg2010_bg2020.csv](https://github.com/jsonkao/asam-redistricting-maps/blob/main/crosswalk/bg2010_bg2020.csv).

bg_crosswalk %>% write.csv("./crosswalk/bg2010_bg2020.csv", row.names = FALSE)

#' ### Using the block-group-to-block-group crosswalk
#'
#' Retrieve 2010 block-group-level population data that we want to interpolate into 2020 block groups. Below, I'm grabbinng the Asian population and the total population for each block group.

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

#' Use the bg2bg crosswalk to interpolate this data from 2010 block groups into 2020 block groups.

bg2020_pop_2010 <- bg_crosswalk %>%
  inner_join(bg_pop_2010 %>% rename(blk_group10 = blk_group), by = "blk_group10") %>%
  mutate(pop_weighted = pop * weight) %>%
  select(GEOID = blk_group20, group, pop = pop_weighted) %>%
  group_by(GEOID, group) %>%
  summarize(pop = sum(pop, na.rm = T))

#' Sanity check: is the total number of Asian people still the same after switching from 2010 block groups to 2020 block groups? Yes.
stopifnot(
  round(
    bg2020_pop_2010 %>% filter(group == "asian") %>% pull(pop) %>% sum(na.rm = T)
  ) ==
    round(bg_pop_2010 %>% filter(group == "asian") %>% pull(pop) %>% sum())
)

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

#' Now, we have 2010 and 2020 population data on the same block group geography.

output %>% head

#' Sanity check: did Brooklyn's Asian population grow by 43% while the rest of the county grew 9%? The output below shows what fold the population increased by in our analysis.

output %>%
  group_by(group) %>%
  summarize(fold = sum(pop_2020) / sum(pop_2010))

#' If we're running this on the command line, make the data wide, add some helpful variables, and save it in a file.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  output %>%
    tidyr::pivot_wider(names_from = group,
                       values_from = c(pop_2010, pop_2020)) %>%
    mutate(
      pop_2010_asian_proportion = pop_2010_asian / pop_2010_total,
      pop_2020_asian_proportion = pop_2020_asian / pop_2020_total
    ) %>%
    write.csv(args[[1]], row.names = FALSE)
}
