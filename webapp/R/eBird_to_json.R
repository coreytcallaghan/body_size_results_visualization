source("R/clean_data.R")
library(magrittr)
corey <- clean_data("data/eBird data/corey_data.csv")
will <- clean_data("data/eBird data/will_data.csv")
jim <- clean_data("data/eBird data/jim_data.csv")

# read clements
read_csv("taxonomy/eBird-Clements-Checklist-v2016-10-August-2016.csv") %>%
  filter(Category=="species")->lo
lo$`Scientific name`<-sub(" ","_",lo$`Scientific name`)
lo %>% group_by(Order, Family) %>%
  summarize(sp_count=n()) %>% 
  ungroup() %>%
  mutate(Family =  gsub(' .*', '', Family)) -> sp_per_fam

to_seen_list <- function (cleaned) {
    cleaned %<>% transmute( gs = Scientific_Name) 
  
    cleaned$Family <- lo$Family[ match(sub(" ","_",cleaned$gs), lo$`Scientific name`)]
    cleaned$Family <-  gsub(' .*', '', cleaned$Family)
    
    cleaned %>% group_by(Family) %>% 
      summarize(seen_count=n_distinct(gs)) %>% filter(!is.na(Family))
}

to_seen_list(will) %>% jsonlite::write_json("data/eBird_json/will.json")
to_seen_list(jim) %>% jsonlite::write_json("data/eBird_json/jim.json")
to_seen_list(corey) %>% jsonlite::write_json("data/eBird_json/corey.json")
