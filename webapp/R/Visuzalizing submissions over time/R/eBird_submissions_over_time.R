## packages
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyr)
# devtools::install_github("dgrtwo/gganimate")
library(gganimate)
library(anytime)

## load data
load("data/corey_data.RData")

###########################
## submissions over time ##
###########################

# format date
corey_data$OBSERVATION_DATE <- as.Date(corey_data$OBSERVATION_DATE, format="%Y-%m-%d")
corey_data$Year_mon <- format(as.Date(corey_data$OBSERVATION_DATE), "%Y-%m")


# plot cumulative checklists per time
checklists_over_time <- corey_data %>% 
        group_by(Year_mon) %>%
        summarise(checklists=length(unique(SAMPLING_EVENT_IDENTIFIER))) %>%
        mutate(cumulative=cumsum(checklists)) %>%
        mutate(Year_mon=anydate(Year_mon)) %>%
        ggplot(., aes(x=Year_mon, y=cumulative, frame=Year_mon, cumulative=TRUE)) +
        geom_point()+
        geom_line()+
        xlab('Year-Month')+
        ylab('Checklists submitted')+
        theme_bw()+
        theme(axis.title.x = element_text(size=14),
              axis.title.y = element_text(size=14),
              axis.text.x = element_text(size=12, color='black'),
              axis.text.y = element_text(size=12, color='black'),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank())

print(checklists_over_time)

# export gif
checklists_over_time.a <- gganimate(checklists_over_time, title_frame=FALSE)
gganimate_save(checklists_over_time.a,
               interval=0.08,
               ani.width=875,
               ani.height=435,
               "C:/Users/CTC/Desktop/checklists_over_time.a.gif",
               saver="mp4")


# plot cumulative species over time
new_species_over_time <- corey_data %>%
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
          mutate(Year_mon=anydate(Year_mon)) %>%
          ggplot(., aes(x=Year_mon, y=cumulative, frame=Year_mon, cumulative=TRUE)) +
          geom_point()+
          geom_line()+
          xlab('Year-Month')+
          ylab('Total species')+
          theme_bw()+
          theme(axis.title.x = element_text(size=14),
                axis.title.y = element_text(size=14),
                axis.text.x = element_text(size=12, color='black'),
                axis.text.y = element_text(size=12, color='black'),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank())
  

# export gif
new_species_over_time.a <- gganimate(new_species_over_time, title_frame=FALSE)
gganimate_save(new_species_over_time.a,
               interval=0.08,
               ani.width=875,
               ani.height=435,
               "C:/Users/CTC/Desktop/new_species_over_time.a.gif",
               saver="mp4")









