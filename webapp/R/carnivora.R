library(dplyr)
library(httr)
library(rvest)
library(phytools)

"https://en.wikipedia.org/wiki/List_of_species_in_order_Carnivora" %>% 
  GET -> txt
# we want these ones
txt %>% read_html() %>% 
  html_nodes("ul") %>% 
  .[-(1:7)] %>% 
  html_nodes("i a") %>% 
  html_attr("href") %>%
  gsub('/wiki/', '', .) %>% Filter(function (x) grep("_", x), .) -> want

read.newick("tree/subtree-ottol-44565-Carnivora.tre") -> full
# hax
paste(want, collapse = "|") -> reeeee
grep(full$tip.label, pattern = reeeee, ignore.case = T) -> matches
full %>% drop.tip((1:length(.$tip.label))[-matches]) -> small

# the other thing to try is:
# but the tree it makes is a little boring
# full %>% drop.leaves() -> small
plot(small, show.node.label = F)
small %>% write.tree("tree/small_carn.tre")
