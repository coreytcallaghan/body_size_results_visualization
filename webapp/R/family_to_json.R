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
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95 >=0, "True", "False"))

dat_order <- readRDS("../../intermediate_results/order_level_results.RDS") %>%
  dplyr::filter(response_type=="viirs") %>%
  dplyr::select(-b_body_size_scaled_log10) %>%
  distinct() %>%
  dplyr::mutate(scaled_estimate=range01(estimate)) %>%
  mutate(overlap_zero=ifelse(lwr_95<=0 & upr_95 >=0, "True", "False"))

# Pull in the model data for each family
dat_tree <- read_csv("../taxonomy/family_stats.csv") %>%
  left_join(dat_family, by=c("fam"="family")) %>%
  left_join(dat_order, by=c("fam"="order")) %>%
  dplyr::mutate(estimate=ifelse(is.na(estimate.x), estimate.y, estimate.x),
                lwr_95=ifelse(is.na(lwr_95.x), lwr_95.y, lwr_95.x),
                upr_95=ifelse(is.na(upr_95.x), upr_95.y, upr_95.x),
                scaled_estimate=ifelse(is.na(scaled_estimate.x), scaled_estimate.y, scaled_estimate.x)) %>%
  dplyr::select(Order, Family, sp_count, obs_count, bio_count, fam, estimate, lwr_95, upr_95, scaled_estimate)

write_json(dat_tree, "../taxonomy/family_stats.json")