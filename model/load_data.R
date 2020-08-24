# Loading package(s)
library(tidyverse)
library(onehot)
library(lubridate)
library(janitor)

# Set seed
set.seed(1235)

train <- read_csv("data/train.csv",
                  col_types = cols(
                    acc_now_delinq = col_factor(levels = c("0", "1", "2")),
                    addr_state = col_factor(),
                    application_type = col_factor(levels = c("Individual", "Joint App")),
                    earliest_cr_line = col_datetime(format = "%b-%Y"),
                    emp_length = col_factor(levels = c("1 year", "3 years", "2 years", "10+ years",
                                                       "8 years", "< 1 year", "6 years", "4 years", "n/a", "moving",
                                                       "7 years", "5 years", "9 years")),
                    emp_title = col_factor(),
                    grade = col_factor(levels = c("A", "B", "C", "D", "E", "F", "G")),
                    home_ownership = col_factor(levels = c("RENT", "OWN", "MORTGAGE", "ANY")),
                    initial_list_status = col_factor(levels = c("w", "f")),
                    last_credit_pull_d = col_datetime(format = "%b-%Y"),
                    num_tl_120dpd_2m = col_factor(levels = c("0", "1", "2")),
                    num_tl_30dpd = col_factor(levels = c("0", "1", "2")),
                    purpose = col_factor(levels = c("debt_consolidation", "credit_card", "other", "home_improvement",
                                                    "major_purchase", "house", "medical", "vacation", "car", "moving",
                                                    "small_business", "renewable_energy", "wedding")),
                    sub_grade = col_factor(ordered = T),
                    term = col_factor(levels = c("36 months", "60 months")),
                    verification_status = col_factor(levels = c("Verified", "Not Verified",
                                                                "Source Verified"))
                  )) %>% 
  mutate(out_prncp_inv = ifelse(out_prncp_inv == 0, 0, log(out_prncp_inv)),
         annual_inc = ifelse(annual_inc == 0, 0, log(annual_inc)),
         tot_cur_bal = ifelse(tot_cur_bal == 0, 0, log(tot_cur_bal)),
         tot_coll_amt = ifelse(tot_coll_amt == 0, 0, log(tot_coll_amt)),
         day_diff = as.numeric(last_credit_pull_d - earliest_cr_line),
         last_credit_pull_from_now = as.numeric(ymd("2020-06-01") - as.Date(last_credit_pull_d)),
         day_from_opening = as.numeric(ymd("2020-06-01") - as.Date(earliest_cr_line))) %>% 
  select(-last_credit_pull_d, -earliest_cr_line) %>% 
  clean_names()

test <- read_csv("data/test.csv",
                 col_types = cols(
                   acc_now_delinq = col_factor(levels = c("0", "1", "2")),
                   addr_state = col_factor(),
                   application_type = col_factor(levels = c("Individual", "Joint App")),
                   earliest_cr_line = col_datetime(format = "%b-%Y"),
                   emp_length = col_factor(levels = c("1 year", "3 years", "2 years", "10+ years",
                                                      "8 years", "< 1 year", "6 years", "4 years", "n/a", "moving",
                                                      "7 years", "5 years", "9 years")),
                   emp_title = col_factor(),
                   grade = col_factor(levels = c("A", "B", "C", "D", "E", "F", "G")),
                   home_ownership = col_factor(levels = c("RENT", "OWN", "MORTGAGE", "ANY")),
                   initial_list_status = col_factor(levels = c("w", "f")),
                   last_credit_pull_d = col_datetime(format = "%b-%Y"),
                   num_tl_120dpd_2m = col_factor(levels = c("0", "1", "2")),
                   num_tl_30dpd = col_factor(levels = c("0", "1", "2")),
                   purpose = col_factor(levels = c("debt_consolidation", "credit_card", "other", "home_improvement",
                                                   "major_purchase", "house", "medical", "vacation", "car", "moving",
                                                   "small_business", "renewable_energy", "wedding")),
                   sub_grade = col_factor(ordered = T),
                   term = col_factor(levels = c("36 months", "60 months")),
                   verification_status = col_factor(levels = c("Verified", "Not Verified",
                                                               "Source Verified"))
                 )) %>%
  mutate(out_prncp_inv = ifelse(out_prncp_inv == 0, 0, log(out_prncp_inv)),
         annual_inc = ifelse(annual_inc == 0, 0, log(annual_inc)),
         tot_cur_bal = ifelse(tot_cur_bal == 0, 0, log(tot_cur_bal)),
         tot_coll_amt = ifelse(tot_coll_amt == 0, 0, log(tot_coll_amt)),
         day_diff = as.numeric(last_credit_pull_d - earliest_cr_line),
         last_credit_pull_from_now = as.numeric(ymd("2020-06-01") - as.Date(last_credit_pull_d)),
         day_from_opening = as.numeric(ymd("2020-06-01") - as.Date(earliest_cr_line))) %>% 
  select(-last_credit_pull_d, -earliest_cr_line) %>% 
  clean_names()