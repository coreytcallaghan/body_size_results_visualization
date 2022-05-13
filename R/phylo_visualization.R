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

# join the most numerous species
# with the list of families above 
# for which we modelled
dat_family <- dat_family %>%
  left_join(., species_family_try)

# Try to get a tree from otl with 'species'
# for each family
my_taxa <- dat_family$species
resolved_names <- rotl::tnrs_match_names(names = my_taxa)

resolved_names$in_tree <- rotl::is_in_tree(resolved_names$ott_id)

table(resolved_names$in_tree)

# now try to make a tree
my_taxa <- dat_family$family
resolved_names <- rotl::tnrs_match_names(names = my_taxa)

resolved_names$in_tree <- rotl::is_in_tree(resolved_names$ott_id)

table(resolved_names$in_tree)

my_tree <- rotl::tol_induced_subtree(resolved_names %>%
                                       dplyr::filter(in_tree=="TRUE") %>%
                                       .$ott_id)

tips <- data.frame(tips=my_tree$tip.label) %>%
  mutate(family=stringr::word(tips, 1, sep="_")) %>%
  left_join(., dat_family)
unres_names <- my_taxa[my_taxa %!in% tips$family]

my_tree$urban <- tips$mean_urban_score
my_tree$family_name <- tips$family

ape::plot.phylo(my_tree, cex = 2)

tree_tibble <- my_tree %>%
  as_tibble() %>%
  mutate(family=stringr::word(label, 1, sep="_")) %>%
  left_join(., dat_family, by="family") %>%
  mutate(label=family)

tree_dat <- tree_tibble %>%
  as.treedata()

pal <- c("(-5,-0.5]"="#990000",
         "(-0.5,0]"="#ff9900",
         "0"="#808080",
         "(0,0.5]"="#65cafd",
         "(0.5,5]"="#003366")
tree_dat@data$estimateCat <- cut(tree_dat@data$estimate, 
                                 breaks=c(-10, 
                                          -0.5, 
                                          0,
                                          0.5, 
                                          10))
levels(tree_dat@data$estimateCat) <- c("(-5,-0.5]", "(-0.5,0]",
                                       "(0,0.5]", "(0.5,5]", "0")
tree_dat@data$estimateCat[tree_dat@data$estimate==0] <- 0

ggtree(tree_dat, layout="circular")+
  geom_point(aes(shape=isTip, color=isTip), size=3)

ggtree(tree_dat, layout="circular")+
  geom_tippoint(aes(color=estimateCat), size=3)+
  scale_color_manual(values=pal, name="Body size effect", na.value=NA)

ggtree(tree_dat, layout="circular")+
  geom_tippoint(aes(color=estimateCat), size=1)+
  scale_color_manual(values=pal, name="Body size effect", na.value=NA)+
facet_wrap(~kingdom)

ggtree(tree_dat, layout="circular")+
  geom_tippoint(aes(color=estimateCat), size=2)+
  scale_color_manual(values=pal, name="Body size effect", na.value=NA,
                     labels=c("Strongly Negative", "Slightly Negative", "None",
                              "Slightly Positive", "Strongly Positive"))+
  geom_tiplab(size=3, offset=0.5)+
  theme(legend.position="bottom")
#ggsave("figures/tree_test.png", dpi=400, height=10, width=12)
#write.tree(tree_dat, "tree.txt")

# get the node number that matches with plantae
plant_nodes <- tree_dat@data %>%
  dplyr::filter(kingdom=="Plantae") %>%
  .$node

ggtree(tree_dat, layout="circular")+
  geom_hilight(node=179,
               alpha=0.3, fill="#66C2A5")+
  geom_hilight(node=255,
               alpha=0.3, fill="#FC8D62")+
  geom_tippoint(aes(color=estimateCat), size=2)+
  scale_color_manual(values=pal, name="Body size effect", na.value=NA,
                     labels=c("Strongly Negative", "Slightly Negative", "None",
                              "Slightly Positive", "Strongly Positive"))+
  geom_tiplab(size=3, offset=0.5)+
  theme(legend.position="bottom")
ggsave("figures/tree_test.png", dpi=400, height=10, width=12)

ggtree(tree_dat, layout="circular")+
  geom_tippoint(aes(color=estimate), size=3)+
  scale_color_gradientn(colours=pal, name="Body size effect")+
  geom_cladelabel(node=255, label="Plantae", 
                  color="red2", offset=.8, align=TRUE)+
  theme_tree2() + 
  xlim(0, 70) + 
  theme_tree()

##########################################################################
##########################################################################
################ Now try to repeat the same thing but at the order level!
# read in the parameter estimates
dat_order <- readRDS("intermediate_results/order_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95>=0, "True", "False"))

# get the most numerous species from each order
species_order_try <- readRDS("urban_scores/subrealm_potential_urban_scores.RDS") %>%
  ungroup() %>%
  group_by(order, species) %>%
  summarize(total_obs=sum(recorded_count)) %>%
  arrange(order, desc(total_obs)) %>%
  group_by(order) %>%
  slice(1)

# join the most numerous species
# with the list of families above 
# for which we modelled
dat_order <- dat_order %>%
  left_join(., species_order_try)

# Try to get a tree from otl with 'species'
# for each order
my_taxa <- dat_order$species
resolved_names <- rotl::tnrs_match_names(names = my_taxa)

resolved_names$in_tree <- rotl::is_in_tree(resolved_names$ott_id)

table(resolved_names$in_tree)

# now try to make a tree
my_tree <- rotl::tol_induced_subtree(resolved_names %>%
                                       dplyr::filter(in_tree=="TRUE") %>%
                                       .$ott_id)

tips <- data.frame(tips=my_tree$tip.label) %>%
  mutate(species=stringr::word(tips, 1, 2, sep="_")) %>%
  left_join(., species_order_try %>%
              mutate(species=gsub(" ", "_", species))) %>%
  left_join(., dat_order, by="order")
unres_names <- my_taxa[my_taxa %!in% tips$order]

my_tree$urban <- tips$mean_urban_score
my_tree$order_name <- tips$order

ape::plot.phylo(my_tree, cex = 2)

tree_tibble <- my_tree %>%
  as_tibble() %>%
  mutate(species=stringr::word(label, 1, 2, sep="_")) %>%
  left_join(., species_order_try %>%
              mutate(species=gsub(" ", "_", species))) %>%
  left_join(., dat_order, by="order") %>%
  mutate(label=order)

tree_dat <- tree_tibble %>%
  as.treedata()

pal <- c("(-5,-0.5]"="#990000",
         "(-0.5,0]"="#ff9900",
         "0"="#808080",
         "(0,0.5]"="#65cafd",
         "(0.5,5]"="#003366")
tree_dat@data$estimateCat <- cut(tree_dat@data$estimate, 
                                 breaks=c(-10, 
                                          -0.5, 
                                          0,
                                          0.5, 
                                          10))
levels(tree_dat@data$estimateCat) <- c("(-5,-0.5]", "(-0.5,0]",
                                       "(0,0.5]", "(0.5,5]", "0")
tree_dat@data$estimateCat[tree_dat@data$estimate==0] <- 0

ggtree(tree_dat, layout="circular")+
  geom_tippoint(aes(color=estimateCat), size=2)+
  scale_color_manual(values=pal, name="Body size effect", na.value=NA,
                     labels=c("Strongly Negative", "Slightly Negative", "None",
                              "Slightly Positive", "Strongly Positive"))+
  geom_tiplab(size=3, offset=0.5)+
  theme(legend.position="bottom")

