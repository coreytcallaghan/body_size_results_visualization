if(!require(pacman)) install.packages('pacman')
# pac man installs then loads if not found
p_load(jsonlite, dplyr, readr, rotl)

range01 <- function(x){(x-min(x))/(max(x)-min(x))}

# Pull in the effect estimates
dat_family <- readRDS("../../intermediate_results/family_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  dplyr::mutate(scaled_estimate=range01(estimate)) %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95 >=0, "True", "False")) %>%
  dplyr::select(order, family, number_species, number_of_obs, number_of_subrealms, estimate,
                lwr_95, upr_95)

dat_order <- readRDS("../../intermediate_results/order_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  dplyr::mutate(scaled_estimate=range01(estimate)) %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95 >=0, "True", "False"),
         order = order, family = order) %>%
  dplyr::select(order, family, number_species, number_of_obs, number_of_subrealms, estimate,
                lwr_95, upr_95)

dat_total <- rbind(dat_family, dat_order)

write.csv(dplyr::select(dat_total,
                        Order=order,
                        Family=family,
                        sp_count=number_species,
                        obs_count=number_of_obs,
                        bio_count=number_of_subrealms,
                        fam=family), "../taxonomy/family_stats.csv")

# Pull in the model data for each family
dat_tree <- read_csv("../taxonomy/family_stats.csv") %>%
  left_join(dat_total, by=c("fam"="family")) %>%
  dplyr::select(Order, Family, 
                sp_count, obs_count, bio_count, 
                fam, 
                estimate, lwr_95, upr_95) %>%
  dplyr::mutate(scaled_estimate = plogis(estimate))

write_json(dat_tree, "../taxonomy/family_stats.json")