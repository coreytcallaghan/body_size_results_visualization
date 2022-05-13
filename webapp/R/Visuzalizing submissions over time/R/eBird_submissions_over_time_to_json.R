## packages
pacman::p_load(dplyr, ggplot2, lubridate, tidyr, anytime,  jsonlite)

# devtools::install_github("dgrtwo/gganimate")
## load data
load("data/corey_data.RData")

###########################
## submissions over time ##
###########################

# format date
corey_data$OBSERVATION_DATE <- as.Date(corey_data$OBSERVATION_DATE, format="%Y-%m-%d")
corey_data$Year_mon <- format(as.Date(corey_data$OBSERVATION_DATE), "%Y-%m")

# submissions over time
corey_data %>% 
  group_by(Year_mon) %>%
  summarise(checklists=length(unique(SAMPLING_EVENT_IDENTIFIER))) %>%
  mutate(cumulative=cumsum(checklists)) %>%
  mutate(Year_mon=anydate(Year_mon)) %>%  write_json("data/corey_submissions_over_time.json")


corey_data %>%
  filter(COMMON_NAME %in% c("Muscovy Duck", "Rock Pigeon")) %>%
  bind_rows(corey_data %>%
              filter(CATEGORY %in% c("species", "issf", "form"))) %>%
  filter(!grepl("/", COMMON_NAME)) %>%
  group_by(COMMON_NAME) %>%
  arrange(OBSERVATION_DATE) %>%
  slice(which.min(OBSERVATION_DATE)) %>%
  group_by(Year_mon) %>%
  summarise(species=length(unique(COMMON_NAME))) %>%
  mutate(cumulative=cumsum(species)) %>%
  mutate(Year_mon=anydate(Year_mon)) %>% write_json('data/corey_new_species_over_time.json')
