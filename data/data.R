#' ---
#' title: "Data consolidationn"
#' description: "This file consolidates all the data we need into a CSV that can be joined with the 2020 block group geography."
#' author: "Jason Kao"
#' ---

#' # Libraries, helper functions

library(tidycensus)
library(stringr)
suppressPackageStartupMessages(library(dplyr))
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

#' # Decennial population data; commented out bc we only care about CVAP populations now

# 2010 population data interpolated to 2020 block groups (asian = Asian alone)
pop10_bg20 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = c(asian = "P003005", total = "P001001", white = "P003002", black = "P003003", hispanic = "P009002"),
  year = 2010
) %>%
  select(GEOID, group = variable, value) %>%
  interpolate() %>% 
  rename(pop = value)

# 2020 population data in 2020 block groups
pop20_bg20 <- get_decennial(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = c(total = "P1_001N", asian = "P1_006N", white = "P1_003N", black = "P1_004N", hispanic = "P2_002N"),
  sumfile = "pl",
  year = 2020
) %>%
  select(GEOID, group = variable, pop = value)

#' # CVAP Data

#' Notable columns:
#' - CIT_EST: rounded estimate of total number of citizens
#' - CVAP_EST: rounded estimate of total number of citizens >= 18 years old
#'
#' Also: I don't think these both are actually on 2010 Decennial block group geography. It [seems like](https://www.census.gov/programs-surveys/acs/geography-acs/geography-boundaries-by-year.html) they're updated every year...

read_cvap <- function(fname) {
  data <- read.csv(fname)
  if ("LNTITLE" %in% colnames(data)) {
    data <- data %>% select(GEOID, group = LNTITLE, value = CVAP_EST)
  } else {
    data <- data %>% select(GEOID = geoid, group = lntitle, value = cvap_est)
  }
  data %>%
    mutate(GEOID = substr(GEOID, 8, 19)) %>%
    mutate(group = str_replace(group, "Asian Alone", "asian")) %>%
    mutate(group = str_replace(group, "White Alone", "white")) %>%
    mutate(group = str_replace(group, "Black or African American Alone", "black")) %>%
    mutate(group = str_replace(group, "Hispanic or Latino", "hispanic")) %>%
    mutate(group = str_replace(group, "Total", "total")) %>%
    filter(group %in% c("asian", "black", "hispanic", "white", "total")) %>% 
    interpolate() %>% 
    rename(cvap = value)
}

cvap10_bg20 <- read_cvap("./cvap/CVAP_2010.csv")
cvap19_bg20 <- read_cvap("./cvap/CVAP_2019.csv")

#' # TODO: ACS Data

#' ## Language

# This can get language spoken at home by ability to speak English and by age
# load_variables(2019, "acs5") %>% filter(grepl(toupper("language spoken at home by ability"), concept)) %>% View()
# load_variables(2019, "acs5") %>% filter(grepl("NATIVITY BY LANGUAGE SPOKEN AT HOME", concept)) %>% View()
# B16004 is individual-level language ability. Easier to start with C16002 (household-level)

# TODO: MISSING GEOGRAPHIC STUFF
hhlang20_bg20 <- get_acs(
  geography = "block group",
  state = "New York",
  county = "Kings",
  variables = c(total = "C16002_001", asian = "C16002_010"), # 'asian' means API language HHs with LEP
  year = 2019
) %>% 
  select(GEOID, group = variable, hhlang = estimate)

#' ## Educational attainment

# load_variables(2019, "acs5", cache = T) %>% filter(grepl("place of birth by educational attainment", concept))

#' ## Others
#' - "geographic mobility"

#' # Data consolidation

# consolidated <- inner_join(
#   # Decennial populations by race
#   inner_join(
#     pop10_bg20 %>% rename(pop = value),
#     pop20_bg20 %>% rename(pop = value),
#     by = c("GEOID", "group"),
#     suffix = c("10", "20")
#   ),
#   # Citizen VAP by race
#   inner_join(
#     cvap10_bg20,
#     cvap19_bg20,
#     by = c("GEOID", "group"),
#     suffix = c("10", "19")
#   ),
#   by = c("GEOID", "group")
# )

consolidated <- inner_join(
  cvap10_bg20,
  cvap19_bg20,
  by = c("GEOID", "group"),
  suffix = c("10", "19")
) %>%
  inner_join(inner_join(
    pop10_bg20,
    pop20_bg20,
    by = c("GEOID", "group"),
    suffix = c("10", "20")
  ),
  by = c("GEOID", "group")) %>% 
  left_join(hhlang20_bg20, by = c("GEOID", "group"))

#' # Generating desirable output

output <- consolidated %>%
  tidyr::pivot_wider(names_from = group, values_from = !c(GEOID, group)) %>% 
  select(!c(hhlang_black, hhlang_hispanic, hhlang_white))

#' If we're running this on the command line, make the data wide, add some helpful variables, and save it in a file.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  output %>% write.csv(args[[1]], row.names = FALSE)
}