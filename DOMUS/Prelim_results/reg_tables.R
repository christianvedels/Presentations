suppressPackageStartupMessages({library(dplyr); library(readr); library(broom)})
proj <- "D:/Dropbox/Research_projects/Mapping_medieval_population/"
out  <- "D:/Dropbox/Teaching/Guest_Lectures_and_misc_talks/DOMUS/Prelim_results/"
cls <- read_csv(paste0(out, "plate_classification.csv"), show_col_types = FALSE) %>%
  select(plate_id, view_type, q1_more_than_one_city, q3_not_a_city)
reg <- read_csv(paste0(proj, "Rscripts/Buringh_Match/results/regression_sample_BASELINE_COMPLETE_MULTICITY.csv"),
                show_col_types = FALSE) %>%
  filter(year == 1550, pop_000 > 0, include_in_analysis) %>% inner_join(cls, by = "plate_id")

fit <- function(d, label) {
  m <- lm(log_pop ~ log_total, data = d); t <- tidy(m)
  data.frame(sample = label, n = nrow(d),
             intercept = t$estimate[1], se_int = t$std.error[1],
             slope = t$estimate[2], se_slope = t$std.error[2],
             t_slope = t$statistic[2], p_slope = t$p.value[2],
             p_slope_eq_1 = 2 * pt(-abs((t$estimate[2] - 1) / t$std.error[2]), m$df.residual),
             r2 = summary(m)$r.squared, sigma = summary(m)$sigma)
}
single <- function(d) d %>% filter(q3_not_a_city == "no", q1_more_than_one_city == "no")
for (mod in c("CNN", "ViT")) {
  d <- reg %>% filter(model == mod)
  res <- bind_rows(
    fit(d, "Broad baseline (Chiara)"),
    fit(d %>% filter(q3_not_a_city == "no"), "Drop non-city plates"),
    fit(single(d), "Single-city, any view"),
    fit(single(d) %>% filter(view_type == "plan_birdseye"), "Single-city, plan/bird's-eye"),
    fit(single(d) %>% filter(view_type == "oblique_distant"), "Single-city, oblique distant"),
    fit(single(d) %>% filter(view_type == "profile"), "Single-city, profile"),
    fit(single(d) %>% filter(view_type == "landscape"), "Single-city, landscape"))
  cat("\n=====", mod, ": log(Buringh pop 1550, thousands) ~ log(DOMUS total count) =====\n")
  print(res %>% mutate(across(where(is.numeric), ~ signif(., 3))), row.names = FALSE, width = 200)
  m <- lm(log_pop ~ log_total + view_type, data = single(d))
  cat("\n--- ", mod, ": single-city plates with view_type fixed effects (ref = landscape), n =", nrow(single(d)),
      ", R2 =", round(summary(m)$r.squared, 3), "---\n")
  print(round(coef(summary(m)), 3))
}
