#' ---
#' title: "Data consolidationn"
#' description: "This file consolidates all the data we need into a CSV that can be joined with the 2020 block group geography."
#' author: "Jason Kao"
#' ---

#' # Libraries, helper functions
library(tidycensus)
library(stringr)
library(dplyr)
census_api_key('b0c03e2d243c837b10d7bb336a998935c35828af')

crosswalk <- read.csv("./crosswalk/crosswalk.csv") %>%
  mutate(blk_group10 = as.character(blk_group10),
         blk_group20 = as.character(blk_group20))

interpolate <- function(data) {
  # Data must have columns: GEOID, group, and value
  crosswalk %>%
    inner_join(data %>% rename(blk_group10 = GEOID), by = "blk_group10") %>%
    mutate(value_weighted = value * weight) %>%
    select(GEOID = blk_group20, group, value = value_weighted) %>%
    group_by(GEOID, group) %>%
    summarize(value = sum(value, na.rm = T))
}

#' # Decennial population data

# 2010 population data interpolated to 2020 block groups (asiana = Asian alone)
pop10_bg20 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = c("Kings", "Richmond"),
  variables = c(asiana = "P003005", total = "P001001"),
  year = 2010
) %>%
  select(GEOID, group = variable, value) %>%
  interpolate()

# 2020 population data in 2020 block groups
pop20_bg20 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = c("Kings", "Richmond"),
  variables = c(total = "P1_001N", asiana = "P1_006N"),
  sumfile = "pl",
  year = 2020
) %>%
  select(GEOID, group = variable, value)

#' # CVAP Data

#' Notable columns:
#' - CIT_EST: rounded estimate of total number of citizens
#' - CVAP_EST: rounded estimate of total number of citizens >= 18 years old
#'
#' Also: I don't think these both are actually on 2010 Decennial block group geography. It [seems like](https://www.census.gov/programs-surveys/acs/geography-acs/geography-boundaries-by-year.html) they're updated every year...

vap10_bg20 <- read.csv("./cvap/CVAP_2010.csv") %>%
  mutate(GEOID = substr(GEOID, 8, 19)) %>%
  select(GEOID, group = LNTITLE, value = CVAP_EST) %>%
  mutate(group = str_replace(group, "Asian Alone", "asiana")) %>%
  mutate(group = str_replace(group, "Total", "total")) %>%
  interpolate()

vap19_bg20 <- read.csv("./cvap/CVAP_2019.csv") %>%
  mutate(GEOID = substr(geoid, 8, 19)) %>%
  select(GEOID, group = lntitle, value = cvap_est) %>%
  mutate(group = str_replace(group, "Asian Alone", "asiana")) %>%
  mutate(group = str_replace(group, "Total", "total")) %>%
  interpolate()

#' # TODO: ACS Data

#' ## Language

# This can get language spoken at home by ability to speak English and by age
# load_variables(2019, "acs5", cache = T) %>% filter(grepl(toupper("language spoken at home by ability"), concept)) %>% View()

#' ## Educational attainment

# load_variables(2019, "acs5", cache = T) %>% filter(grepl("place of birth by educational attainment", concept))

#' ## Others
#' - "geographic mobility"

#' # Data consolidation

consolidated <- inner_join(
  # Decennial populations by race
  inner_join(
    pop10_bg20 %>% rename(pop = value),
    pop20_bg20 %>% rename(pop = value),
    by = c("GEOID", "group"),
    suffix = c("10", "20")
  ),
  # Citizen VAP by race
  inner_join(
    vap10_bg20 %>% rename(vap = value),
    vap19_bg20 %>% rename(vap = value),
    by = c("GEOID", "group"),
    suffix = c("10", "19")
  ),
  by = c("GEOID", "group")
)

#' # Generating desirable output

output <- consolidated %>%
  select(GEOID, group, starts_with("vap")) %>%
  tidyr::pivot_wider(names_from = group, values_from = c(vap10, vap19)) %>%
  mutate(
    vap10_asiana_prop = vap10_asiana / vap10_total,
    vap19_asiana_prop = vap19_asiana / vap19_total
  )

#' If we're running this on the command line, make the data wide, add some helpful variables, and save it in a file.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  output %>% write.csv(args[[1]], row.names = FALSE)
}