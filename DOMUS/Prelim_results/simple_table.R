suppressPackageStartupMessages({library(dplyr); library(readr); library(tidyr)})
proj <- "D:/Dropbox/Research_projects/Mapping_medieval_population/"
out  <- "D:/Dropbox/Teaching/Guest_Lectures_and_misc_talks/DOMUS/Prelim_results/"
cls <- read_csv(paste0(out, "plate_classification.csv"), show_col_types = FALSE) %>%
  filter(view_type == "plan_birdseye", q1_more_than_one_city == "no", q3_not_a_city == "no") %>%
  select(plate_id, rumsey_cities)
reg <- read_csv(paste0(proj, "Rscripts/Buringh_Match/results/regression_sample_BASELINE_COMPLETE_MULTICITY.csv"),
                show_col_types = FALSE) %>%
  filter(year == 1550, pop_000 > 0, include_in_analysis) %>%
  select(plate_id, model, city = plate_label, pop_1550_thousands = pop_000,
         buildings = total_count, houses = count_ordinary_building) %>%
  pivot_wider(names_from = model, values_from = c(buildings, houses), names_glue = "{.value}_{tolower(model)}")
d <- cls %>% inner_join(reg, by = "plate_id") %>%
  mutate(across(starts_with(c("buildings", "houses")), round)) %>%
  select(plate_id, city, pop_1550_thousands, buildings_cnn, houses_cnn, buildings_vit, houses_vit) %>%
  arrange(desc(pop_1550_thousands))
write_csv(d, paste0(out, "plan_birdseye_pop_vs_buildings_1550.csv"))
cat(nrow(d), "plates\n"); print(head(d, 10), width = 200)
