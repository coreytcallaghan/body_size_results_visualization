# script to visualize the effect of body size on urban tolerance at family level across
# a phylogenetic tree

# rotl link: https://ropensci.github.io/rotl/articles/rotl.html

# custom functions
'%!in%' <- function(x,y)!('%in%'(x,y))

# packages
library(rotl)
library(dplyr)
library(ggplot2)
library(GGally)
library(ggtree)
library(tidytree)
library(treeio)

# read in the parameter estimates
dat_family <- readRDS("intermediate_results/family_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95>=0, "True", "False"))

# get the most numerous species from each family
species_family_try <- readRDS("urban_scores/subrealm_potential_urban_scores.RDS") %>%
  ungroup() %>%
  group_by(family, species) %>%
  summarize(total_obs=sum(recorded_count)) %>%
  arrange(family, desc(total_obs)) %>%
  group_by(family) %>%
  slice(1)

# Manually handle problematic observations
species_family_try[which(species_family_try$family=="Trochidae"),]$species <- "Phorcus lineatus"
species_family_try[which(species_family_try$family=="Asilidae"),]$species <- "Tolmerus atricapillus"
species_family_try[which(species_family_try$family=="Aphodiidae"),]$species <- "Aphodius rufipes"
species_family_try[which(species_family_try$family=="Bucerotidae"),]$species <- "Tockus camurus"
species_family_try[which(species_family_try$family=="Cerambycidae"),]$species <- "Leptura maculata"
species_family_try[which(species_family_try$family=="Lauxaniidae"),]$species <- "Lyciella rorida"
species_family_try[which(species_family_try$family=="Megachilidae"),]$species <- "Osmia bicornis"
species_family_try[which(species_family_try$family=="Nolidae"),]$species <- "Pseudoips prasinanus"
species_family_try[which(species_family_try$family=="Onagraceae"),]$species <- "Epilobium dodonaei"
species_family_try[which(species_family_try$family=="Scarabaeidae"),]$species <- "Scarabaeus aegyptiacus"
species_family_try[which(species_family_try$family=="Silphidae"),]$species <- "Phosphuga atrata"
species_family_try[which(species_family_try$family=="Thraupidae"),]$species <- "Tangara episcopus"
species_family_try[which(species_family_try$family=="Bovidae"),]$species <- "Bos taurus"

# join the most numerous species
# with the list of families above 
# for which we modeled
dat_family <- dat_family %>%
  left_join(., species_family_try)

# Try to get a tree from otl with 'species'
# for each family
my_taxa <- dat_family$species
resolved_names <- rotl::tnrs_match_names(names = my_taxa)

resolved_names$in_tree <- rotl::is_in_tree(resolved_names$ott_id)
table(resolved_names$in_tree)

# now try to make a tree
my_tree <- rotl::tol_induced_subtree(resolved_names %>%
                                       dplyr::filter(in_tree=="TRUE") %>%
                                       .$ott_id)

tips <- data.frame(tips=my_tree$tip.label) %>%
  mutate(species=gsub("_", " ", stringr::word(tips, 1, 2, sep="_"))) %>%
  left_join(., species_family_try) %>%
  left_join(., dat_family, by="family")

my_taxa <- dat_family$family
unres_names <- my_taxa[my_taxa %!in% tips$family]

my_tree$urban <- tips$estimate
my_tree$family_name <- tips$family

ape::plot.phylo(my_tree, cex = 0.7)

tree_tibble <- my_tree %>%
  as_tibble() %>%
  mutate(species=gsub("_", " ", stringr::word(label, 1, 2, sep="_"))) %>%
  left_join(., species_family_try, by="species") %>%
  left_join(., dat_family, by="family") %>%
  dplyr::mutate(label = family)

tree_dat <- tree_tibble %>%
  as.treedata()
