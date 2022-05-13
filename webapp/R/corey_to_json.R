if(!require(pacman)) install.packages("pacman")
p_load(readr, dplyr, jsonlite)
## load data
load("data/corey_data.RData")
read_csv("taxonomy/eBird-Clements-Checklist-v2016-10-August-2016.csv") %>%
  filter(Category=="species")->lo
lo$`Scientific name`<-sub(" ","_",lo$`Scientific name`)

corey_df<-data.frame(gs=corey_data$Scientific_Name)
corey_df$Family<-lo$Family[match(sub(" ","_",corey_df$gs),lo$`Scientific name`)]
corey_df$Family <-  gsub(' .*', '', corey_df$Family)

lo %>% group_by(Order, Family) %>%
  summarize(sp_count=n()) %>% 
  ungroup() %>%
  mutate(Family =  gsub(' .*', '', Family)) -> sp_per_fam

group_by(corey_df, Family) %>% 
  summarize(seen_count=n_distinct(gs)) -> seen_list

left_join(sp_per_fam, seen_list) -> joined
joined$seen_count[is.na(joined$seen_count)] <- 0
joined %>% jsonlite::write_json('data/corey_family_list.json')
