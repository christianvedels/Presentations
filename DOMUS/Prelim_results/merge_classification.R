suppressPackageStartupMessages({library(dplyr); library(readr); library(stringr)})
out_dir <- "D:/Dropbox/Teaching/Guest_Lectures_and_misc_talks/DOMUS/Prelim_results"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
proj <- "D:/Dropbox/Research_projects/Mapping_medieval_population/"

cls <- read_delim("D:/tmp/classification_raw.csv", delim = "|", show_col_types = FALSE)
idx <- read_csv("D:/tmp/sheets/sheet_index.csv", show_col_types = FALSE)
rum <- read_csv(paste0(proj, "Data/Labelling/full_pages/Civitates_city_index.csv"),
                show_col_types = FALSE, locale = locale(encoding = "UTF-8")) %>%
  transmute(file, rumsey_cities = city, rumsey_date = date, rumsey_title = short_title)
qual <- read_csv(paste0(proj, "Rscripts/Buringh_Match/crosswalk/plate_quality_status_ANALYSIS_USED.csv"),
                 show_col_types = FALSE) %>%
  transmute(plate_id, chiara_plate_type = plate_type, chiara_include = include_in_analysis)
cnn <- read_csv(paste0(proj, "Data/Predictions/domus_convolution/plate_counts.csv"), show_col_types = FALSE) %>%
  distinct(plate_id, .keep_all = TRUE) %>%
  transmute(plate_id, cnn_total = round(total_count), cnn_houses = round(count_ordinary_building))
vit <- read_csv(paste0(proj, "Data/Predictions/domus_vit/plate_counts.csv"), show_col_types = FALSE) %>%
  distinct(plate_id, .keep_all = TRUE) %>%
  transmute(plate_id, vit_total = round(total_count))

d <- idx %>% inner_join(cls, by = "k") %>%
  mutate(plate_id = str_remove(file, "\\.jpg$"),
         volume = str_extract(file, "Vol_[IV]+")) %>%
  left_join(rum, by = "file") %>%
  left_join(qual, by = "plate_id") %>%
  left_join(cnn, by = "plate_id") %>% left_join(vit, by = "plate_id") %>%
  mutate(
    # the three questions, answered directly
    q1_more_than_one_city = case_when(n_city_views == 0 ~ "n/a", multi_city == "yes" ~ "yes", TRUE ~ "no"),
    q2_seen_from_above    = case_when(n_city_views == 0 ~ "n/a", TRUE ~ from_above),
    q3_not_a_city         = non_city,
    usable_for_house_count = case_when(
      non_city == "yes" ~ "no",
      multi_city == "yes" ~ "after cropping",
      from_above == "yes" ~ "yes",
      from_above == "partly" ~ "with caution",
      TRUE ~ "no")) %>%
  select(k, plate_id, volume, rumsey_cities, n_city_views, q1_more_than_one_city, q2_seen_from_above,
         q3_not_a_city, view_type, usable_for_house_count, notes, chiara_plate_type, chiara_include,
         cnn_total, cnn_houses, vit_total, rumsey_date, rumsey_title, file)

write_csv(d, file.path(out_dir, "plate_classification.csv"))

# summaries
s1 <- d %>% count(q1_more_than_one_city, name = "plates")
s2 <- d %>% count(q2_seen_from_above, name = "plates")
s3 <- d %>% count(q3_not_a_city, name = "plates")
s4 <- d %>% count(view_type, name = "plates") %>% arrange(desc(plates))
s5 <- d %>% count(usable_for_house_count, name = "plates") %>% arrange(desc(plates))
s6 <- d %>% filter(q1_more_than_one_city != "n/a") %>%
  count(q1_more_than_one_city, q2_seen_from_above, name = "plates")
s7 <- d %>% filter(q3_not_a_city == "no") %>% count(volume, view_type) %>%
  tidyr::pivot_wider(names_from = view_type, values_from = n, values_fill = 0)
# mean DOMUS count by view type -- how much does perspective drive the count?
s8 <- d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no") %>%
  group_by(view_type) %>%
  summarise(plates = n(), median_cnn_total = median(cnn_total, na.rm = TRUE),
            median_cnn_houses = median(cnn_houses, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(median_cnn_total))
# disagreements with Chiara's current plate-quality layer
s9 <- d %>% filter(q3_not_a_city == "yes" & chiara_include == TRUE) %>%
  select(plate_id, notes, chiara_plate_type, cnn_total, vit_total)
s10 <- d %>% filter(q1_more_than_one_city == "yes" & !chiara_plate_type %in% c("multi_city_plate")) %>%
  select(plate_id, n_city_views, notes, chiara_plate_type)

for (nm in c("s1","s2","s3","s4","s5","s6","s7","s8","s9","s10")) {
  write_csv(get(nm), file.path(out_dir, paste0("summary_", nm, ".csv")))
}
cat("\n== Q1 more than one city ==\n"); print(s1)
cat("\n== Q2 seen from above ==\n"); print(s2)
cat("\n== Q3 not a city ==\n"); print(s3)
cat("\n== view type ==\n"); print(s4)
cat("\n== usable for house count ==\n"); print(s5)
cat("\n== Q1 x Q2 ==\n"); print(s6)
cat("\n== per volume ==\n"); print(s7, width = 200)
cat("\n== median DOMUS count by view type (single-city, real city views) ==\n"); print(s8)
cat("\n== non-city plates still included in Chiara's analysis ==\n"); print(s9, n = 50, width = 200)
cat("\n== multi-city plates not flagged multi_city in Chiara's layer ==\n"); print(s10, n = 100, width = 200)
