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
  
     
