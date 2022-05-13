pacman::p_load(rvest, httr, dplyr)
GET("https://en.wikipedia.org/wiki/List_of_vegetables") -> veges

veges %>% read_html %>%
  html_nodes("table") %>%
  html_table(header = T)
