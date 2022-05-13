# clements_to_json.R
if(!require(pacman)) install.packages('pacman')
# pac man installs then loads if not found
p_load(jsonlite, dplyr, readr, rotl)

#ebird for taxonomy lookup
read_csv("taxonomy/family_stats.csv") %>%
  write_json("taxonomy/family_stats.json")