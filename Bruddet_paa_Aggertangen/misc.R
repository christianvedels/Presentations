
# ==== Libraries ====
library(tidyverse)
library(foreach)

# ==== Load data ====
fs = list.files("D:/Dropbox/Research_projects/Occupational_Income/Incomes_Copenhagen/Data/Intermediate_data/Tmp_pages1870_71", full = TRUE)
data0 = foreach(f = fs, .combine = "bind_rows") %do% {
  cat(f, "                \r")
  read_csv(f, show_col_types = FALSE) %>% mutate_all(as.character)
} %>% mutate(
  income = as.numeric(income_reported_100_rdlr),
  net_income = as.numeric(income_reported_100_rdlr) - as.numeric(tax_quarter_rdlr)
)

# ==== Distribution ====
data0 %>% 
  ggplot(aes(income)) + 
  geom_histogram() + 
  scale_x_log10() + 
  theme_minimal()

data0 %>% 
  ggplot(aes(net_income)) + 
  geom_histogram() + 
  scale_x_log10() + 
  theme_minimal()

data0 %>% 
  filter(income < 100) %>% 
  ggplot(aes(income)) + 
  geom_histogram() + 
  scale_x_log10() + 
  theme_minimal()

median(data0$income_reported_100_rdlr, na.rm = TRUE)

# Lorenz curve
data0_sorted = data0 %>%
  drop_na(net_income) %>% 
  arrange(net_income) %>%
  mutate(
    cum_pop = cumsum(rep(1, n())) / n(),
    cum_income = cumsum(income) / sum(income)
  )

lorenz_df = bind_rows(
  data.frame(cum_pop = 0, cum_income = 0),
  data0_sorted %>% select(cum_pop, cum_income)
)

gini = 1 - 2 * sum(diff(lorenz_df$cum_pop) * 
                      (
                        head(lorenz_df$cum_income, -1) + 
                          tail(lorenz_df$cum_income, -1)) / 2
                   )

p1 = ggplot(lorenz_df, aes(x = cum_pop, y = cum_income)) +
  geom_line(color = "blue", size = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(
    title = "Lorenz Curve of Income",
    subtitle = paste("Gini coefficient:", round(gini, 3)),
    x = "Cumulative Share of Population",
    y = "Cumulative Share of Income"
  ) +
  theme_minimal()

p1
# Modern DK ~ 0.30 gini

# ==== Ask about distribution ====
percentile_of_distribution = function(x){
  # Based on:
  # Ljungberg, J. European consumer price indices since 1870. Cliometrica (2024).
  # https://doi.org/10.1007/s11698-024-00283-6
  
  full_dist = data0 %>% drop_na(income)
  partial_dist = full_dist %>% filter(income >= x)
  
  share = NROW(partial_dist)/NROW(full_dist)
  n_count = NROW(partial_dist)
  today = 158*x / 10000 # Using 
  
  message0 = paste0("Blandt de ", round(share*100, 2), "% rigeste. ", 
                    n_count, " personer er ligesaa eller rigere end denne.",
                    "\nSvarende til aarligt ", today, " mio. kr.")
  cat(message0)
  
}

percentile_of_distribution(400)

data0 %>%
  filter(str_starts(name, "Bohr")) %>% 
  select(name, stand, income)

