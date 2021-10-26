#
# This file helps to explore stuff; helpful for color stuff
#

library(tidyverse)
library(Ckmeans.1d.dp)

# Plurality strength
consolidated %>% 
  filter(group != "total") %>% 
  arrange(GEOID, -prop19) %>% 
  group_by(GEOID) %>%
  slice(c(1, 2)) %>% 
  filter(!is.na(prop19)) %>% 
  summarize(max = max(prop19), min = min(prop19), distance = max(prop19) - min(prop19)) %>%
  ggplot(aes(distance)) +
  geom_histogram() +
  facet_wrap(~ max >= 0.5)
  
     

# THE MISSING SHITS
# 360470106022 seems to always be suppressed. Its neighbor, 360470116001, always has the data

get_acs(
  geography = "tract",
  state = "New York",
  county = "Kings",
  variables = "B19013_001",
  year = 2018,
  survey = "acs5"
) %>% filter(GEOID %in% c("360470106022", "360470116001") | GEOID %in% c("36047010602", "36047011600"))


