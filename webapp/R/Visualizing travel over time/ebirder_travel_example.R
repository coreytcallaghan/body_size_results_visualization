#### Load necessary packages
library(readr)
library(dplyr)
library(ggplot2)
library(gganimate)
library(maps)
library(mapdata)
library(lubridate)
library(ggmap)


## function for mode
mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

### make dataframe of unique checklists
corey_checklists <- corey_data %>%
  filter(COMMON_NAME %in% c("Muscovy Duck", "Rock Pigeon")) %>%
  bind_rows(corey_data %>%
              filter(CATEGORY %in% c("species", "issf", "form"))) %>%
  filter(!grepl("/", COMMON_NAME)) %>%
  select(SAMPLING_EVENT_IDENTIFIER, LATITUDE, LONGITUDE, COMMON_NAME, OBSERVATION_DATE) %>%
  group_by(SAMPLING_EVENT_IDENTIFIER, LATITUDE, LONGITUDE) %>%
  summarise(species_richness = length(unique(COMMON_NAME)),
            date=mode(OBSERVATION_DATE))
  


## simple map of world
mapworld <- borders("world", colour='gray20', fill='gray85')
ggplot() +
  mapworld +
  
  
## add all points to the map
ggplot() +
  mapworld +
  geom_point(data=corey_checklists, aes(x=LONGITUDE, y=LATITUDE), color='red', size=3.5)


## try to animate it
p1 <- ggplot()+
  mapworld+
  geom_point(data=corey_checklists, aes(x=LONGITUDE, y=LATITUDE, frame=date, cumulative=FALSE),
             color='red', size=3.5)

pa1 <- gganimate(p1, title_frame=FALSE)
gganimate_save(pa1,
               interval=0.0001,
               "C:/Users/CTC/Desktop/pa1.gif",
               ani.width=870,
               ani.height=567,
               saver="mp4")








