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
  
# ckmeans <-
consolidated %>% 
  filter(group != "total") %>% 
  arrange(GEOID, -prop19) %>% 
  group_by(GEOID) %>%
  slice(c(1, 2)) %>% 
  filter(!is.na(prop19)) %>% 
  summarize(max = max(prop19), min = min(prop19), distance = max(prop19) - min(prop19)) %>%
  filter(max < .5) %>% 
  pull(distance) %>% 
  median()

centers <- ckmeans$centers
centers[-length(centers)] + diff(centers) / 2


# Continuous scale for household language

centers <- ((
  output %>%
    filter(hhlang_total > 0) %>%
    mutate(prop = hhlang_asian / hhlang_total) %>%
    pull(prop)
) %>% 
  Ckmeans.1d.dp(k = 6) )$centers
centers[-length(centers)] + diff(centers) / 2        

centers <- ((
  output %>%
    filter(!is.na(income)) %>% 
    mutate(prop = income) %>%
    pull(prop)
) %>% 
  Ckmeans.1d.dp(k = 6) )$centers
centers[-length(centers)] + diff(centers) / 2        
