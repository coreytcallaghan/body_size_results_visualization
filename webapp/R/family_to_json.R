if(!require(pacman)) install.packages('pacman')
# pac man installs then loads if not found
p_load(jsonlite, dplyr, readr, rotl)

# Pull in the effect estimates
dat_family <- readRDS("../../intermediate_results/family_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95 >=0, "True", "False"))

# Pull in the model data for each family
dat_tree <- read_csv("../taxonomy/family_stats.csv") %>%
  left_join(dat_family, by=c("fam"="family"))
write_json(dat_tree, "../taxonomy/family_stats.json")