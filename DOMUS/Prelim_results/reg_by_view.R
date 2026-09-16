suppressPackageStartupMessages({library(dplyr); library(readr); library(ggplot2); library(broom)})
proj <- "D:/Dropbox/Research_projects/Mapping_medieval_population/"
out  <- "D:/Dropbox/Teaching/Guest_Lectures_and_misc_talks/DOMUS/Prelim_results/"

cls <- read_csv(paste0(out, "plate_classification.csv"), show_col_types = FALSE) %>%
  select(plate_id, view_type, q1_more_than_one_city, q2_seen_from_above, q3_not_a_city)
reg <- read_csv(paste0(proj, "Rscripts/Buringh_Match/results/regression_sample_BASELINE_COMPLETE_MULTICITY.csv"),
                show_col_types = FALSE) %>%
  filter(year == 1550, pop_000 > 0, include_in_analysis) %>%
  inner_join(cls, by = "plate_id")

fit <- function(d, label) {
  m <- lm(log_pop ~ log_total, data = d)
  tidy(m) %>% filter(term == "log_total") %>%
    transmute(sample = label, n = nrow(d), slope = estimate, se = std.error,
              ci_low = estimate - 1.96 * se, ci_high = estimate + 1.96 * se,
              r2 = summary(m)$r.squared, cor_log = cor(d$log_pop, d$log_total))
}

res <- bind_rows(lapply(c("CNN", "ViT"), function(mod) {
  d <- reg %>% filter(model == mod)
  bind_rows(
    fit(d, "Broad baseline (Chiara)"),
    fit(d %>% filter(q3_not_a_city == "no"), "Drop non-city plates"),
    fit(d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no"), "Single-city, any view"),
    fit(d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no", view_type == "plan_birdseye"),
        "Single-city, plan/bird's-eye only"),
    fit(d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no", view_type == "oblique_distant"),
        "Single-city, oblique distant only"),
    fit(d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no", view_type == "profile"),
        "Single-city, profile only"),
    fit(d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no", view_type == "landscape"),
        "Single-city, landscape only")
  ) %>% mutate(model = mod, .before = 1)
}))

# view-type fixed effects, single-city genuine views
fe <- bind_rows(lapply(c("CNN", "ViT"), function(mod) {
  d <- reg %>% filter(model == mod, q3_not_a_city == "no", q1_more_than_one_city == "no")
  m <- lm(log_pop ~ log_total + view_type, data = d)
  tidy(m) %>% mutate(model = mod, n = nrow(d), r2 = summary(m)$r.squared, .before = 1)
}))

write_csv(res, paste0(out, "loglog_by_view_type_1550.csv"))
write_csv(fe,  paste0(out, "loglog_view_type_FE_1550.csv"))
print(res %>% mutate(across(where(is.numeric), ~ round(., 3))), n = 30, width = 200)
cat("\n== with view_type fixed effects ==\n")
print(fe %>% mutate(across(where(is.numeric), ~ round(., 3))), n = 30, width = 200)

# scatter: plan/bird's-eye vs the rest, CNN
d <- reg %>% filter(model == "CNN", q3_not_a_city == "no", q1_more_than_one_city == "no") %>%
  mutate(group = ifelse(view_type == "plan_birdseye", "Plan / bird's-eye", "Other views"))
p <- ggplot(d, aes(log_total, log_pop, colour = group)) +
  geom_point(alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 1) +
  scale_colour_manual(values = c("Plan / bird's-eye" = "#b33d3d", "Other views" = "grey55")) +
  labs(x = "log(DOMUS building count), CNN", y = "log(Buringh population 1550, thousands)",
       colour = NULL, title = "Single-city plates: counts vs population by viewpoint") +
  theme_minimal(base_size = 14) + theme(legend.position = "bottom")
ggsave(paste0(out, "loglog_plan_vs_other_1550_cnn.png"), p, width = 8, height = 5.5, dpi = 200, bg = "white")
