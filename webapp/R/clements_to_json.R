# clements_to_json.R
if(!require(pacman)) install.packages('pacman')
# pac man installs then loads if not found
p_load(jsonlite, dplyr, readr, rotl)

#ebird for taxonomy lookup
read_csv("taxonomy/eBird-Clements-Checklist-v2016-10-August-2016.csv") %>%
  filter(Category=="species") -> lo

lo %>% group_by(Order, Family) %>%
  summarize(sp_count=n()) %>% 
  ungroup() %>%
  mutate(fam =  gsub(' .*', '', Family), 
         ott_id = tnrs_match_names(fam, context_name = "Birds")$ott_id
  ) %>%
  write_json("taxonomy/eBird_clements_checklist_family.json")

lo %>% group_by(Order) %>%
  summarize(gs = `Scientific name`[1],
            gs = sub(" ", "_", gs),
            sp_count=n()) %>%
  write_json("taxonomy/eBird_clements_checklist_order.json")
