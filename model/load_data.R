# Loading package(s)
library(tidyverse)
library(onehot)
library(lubridate)
library(janitor)

# Set seed
set.seed(1235)

states <- c("CA", "NY", "TX", "FL", "NJ", "IL", "MI")
two_years <- c("< 1 year", "1 year", "2 years")
five_years <- c("3 years", "4 years", "5 years")
nine_years <- c("6 years", "7 years", "8 years", "9 years")
purposes <- c("debt_consolidation", "credit_card", "home_improvement", "major_purchase")

train <- read_csv("data/train.csv",
                  col_types = cols(
                    acc_now_delinq = col_factor(levels = c("0", "1", "2")),
                    application_type = col_factor(levels = c("Individual", "Joint App")),
                    earliest_cr_line = col_datetime(format = "%b-%Y"),
                    emp_length = col_factor(levels = c("< 1 year", "1 year", "2 years", "3 years",
                                                       "4 years", "5 years", "6 years", "7 years",
                                                       "8 years", "9 years", "10+ years",
                                                       "n/a", "moving")),
                    grade = col_factor(levels = c("A", "B", "C", "D", "E", "F", "G")),
                    home_ownership = col_factor(levels = c("RENT", "MORTGAGE", "OWN", "ANY")),
                    initial_list_status = col_factor(levels = c("w", "f")),
                    last_credit_pull_d = col_datetime(format = "%b-%Y"),
                    term = col_factor(levels = c("36 months", "60 months")),
                    verification_status = col_factor(levels = c("Verified", "Not Verified",
                                                                "Source Verified"))
                  )) %>% 
  mutate(acc_now_delinq = ifelse(acc_now_delinq == 0, 0, 1),
         acc_open_past_24mths = ifelse(acc_open_past_24mths > 10, 11, acc_open_past_24mths),
         addr_state = as.factor(if_else(addr_state %in% states, addr_state, as.character("Other States"))),
         annual_inc = ifelse(annual_inc == 0, 0, log(annual_inc)),
         avg_cur_bal = ifelse(out_prncp_inv == 0, 0, log(avg_cur_bal)),
         bc_util = (bc_util - mean(bc_util))/sd(bc_util),
         delinq_2yrs = as.ordered(ifelse(delinq_2yrs > 2, "3+", delinq_2yrs)),
         delinq = as.factor(ifelse(delinq_amnt > 0, "1", delinq_amnt)),
         dti = ifelse(dti > 40, 40, dti),
         dti = (dti - mean(dti))/sd(dti),
         day_from_opening = as.numeric(ymd("2020-06-01") - as.Date(earliest_cr_line)),
         emp_length = if_else(emp_length %in% two_years, "<= 2 years", 
                              as.character(emp_length)),
         emp_length = if_else(emp_length %in% five_years, "<= 5 years", 
                              as.character(emp_length)),
         emp_length = if_else(emp_length %in% nine_years, "<= 9 years", 
                              as.character(emp_length)),
         emp_length = as.factor(emp_length),
         int_rate = (int_rate - min(int_rate))/(max(int_rate) - min(int_rate)),
         last_credit_pull_from_now = as.numeric(ymd("2020-06-01") - as.Date(last_credit_pull_d)),
         day_diff = as.numeric(last_credit_pull_d - earliest_cr_line),
         loan_amnt = (loan_amnt - mean(loan_amnt))/sd(loan_amnt),
         mort_acc = if_else(mort_acc > 5, 6, mort_acc),
         num_sats = (num_sats - min(num_sats))/(max(num_sats) - min(num_sats)),
         num_tl_120dpd_2m = as.factor(if_else(num_tl_120dpd_2m > 0, 1, num_tl_120dpd_2m)),
         num_tl_90g_dpd_24m = as.factor(if_else(num_tl_90g_dpd_24m > 0, 1, num_tl_90g_dpd_24m)),
         num_tl_30dpd = as.factor(if_else(num_tl_30dpd > 0, 1, num_tl_30dpd)),
         out_prncp_inv = ifelse(out_prncp_inv == 0, 0, log(out_prncp_inv)),
         pub_rec = as.factor(if_else(pub_rec > 1, 2, pub_rec)),
         pub_rec_bankruptcies = as.factor(if_else(pub_rec_bankruptcies > 1, 2, pub_rec_bankruptcies)),
         purpose = as.factor(if_else(purpose %in% purposes, purpose, as.character("Others"))),
         tot_coll_amt = ifelse(tot_coll_amt == 0, 0, log(tot_coll_amt)),
         tot_cur_bal = ifelse(tot_cur_bal == 0, 0, log(tot_cur_bal)),
         late = as.factor(if_else(total_rec_late_fee > 0, 1, total_rec_late_fee))
         ) %>% 
  select(-delinq_amnt, -earliest_cr_line, -emp_title, -last_credit_pull_d, -sub_grade, 
         -total_rec_late_fee) %>% 
  clean_names()

test <- read_csv("data/test.csv",
                 col_types = cols(
                   acc_now_delinq = col_factor(levels = c("0", "1", "2")),
                   application_type = col_factor(levels = c("Individual", "Joint App")),
                   earliest_cr_line = col_datetime(format = "%b-%Y"),
                   emp_length = col_factor(levels = c("< 1 year", "1 year", "2 years", "3 years",
                                                      "4 years", "5 years", "6 years", "7 years",
                                                      "8 years", "9 years", "10+ years",
                                                      "n/a", "moving")),
                   grade = col_factor(levels = c("A", "B", "C", "D", "E", "F", "G")),
                   home_ownership = col_factor(levels = c("RENT", "MORTGAGE", "OWN", "ANY")),
                   initial_list_status = col_factor(levels = c("w", "f")),
                   last_credit_pull_d = col_datetime(format = "%b-%Y"),
                   term = col_factor(levels = c("36 months", "60 months")),
                   verification_status = col_factor(levels = c("Verified", "Not Verified",
                                                               "Source Verified"))
                 )) %>% 
  mutate(acc_now_delinq = ifelse(acc_now_delinq == 0, 0, "1+"),
         addr_state = as.factor(if_else(addr_state %in% states, addr_state, as.character("Other States"))),
         annual_inc = ifelse(annual_inc == 0, 0, log(annual_inc)),
         avg_cur_bal = ifelse(out_prncp_inv == 0, 0, log(avg_cur_bal)),
         bc_util = (bc_util - mean(bc_util))/sd(bc_util),
         delinq_2yrs = as.ordered(ifelse(delinq_2yrs > 2, "3+", delinq_2yrs)),
         delinq = as.factor(ifelse(delinq_amnt > 0, "1", delinq_amnt)),
         dti = ifelse(dti > 40, 40, dti),
         dti = (dti - mean(dti))/sd(dti),
         day_from_opening = as.numeric(ymd("2020-06-01") - as.Date(earliest_cr_line)),
         emp_length = if_else(emp_length %in% two_years, "<= 2 years", 
                              as.character(emp_length)),
         emp_length = if_else(emp_length %in% five_years, "<= 5 years", 
                              as.character(emp_length)),
         emp_length = if_else(emp_length %in% nine_years, "<= 9 years", 
                              as.character(emp_length)),
         emp_length = as.factor(emp_length),
         int_rate = (int_rate - min(int_rate))/(max(int_rate) - min(int_rate)),
         last_credit_pull_from_now = as.numeric(ymd("2020-06-01") - as.Date(last_credit_pull_d)),
         day_diff = as.numeric(last_credit_pull_d - earliest_cr_line),
         loan_amnt = (loan_amnt - mean(loan_amnt))/sd(loan_amnt),
         mort_acc = as.factor(if_else(mort_acc > 5, 6, mort_acc)),
         num_sats = (num_sats - min(num_sats))/(max(num_sats) - min(num_sats)),
         num_tl_120dpd_2m = as.factor(if_else(num_tl_120dpd_2m > 0, 1, num_tl_120dpd_2m)),
         num_tl_90g_dpd_24m = as.factor(if_else(num_tl_90g_dpd_24m > 0, 1, num_tl_90g_dpd_24m)),
         num_tl_30dpd = as.factor(if_else(num_tl_30dpd > 0, 1, num_tl_30dpd)),
         out_prncp_inv = ifelse(out_prncp_inv == 0, 0, log(out_prncp_inv)),
         pub_rec = as.factor(if_else(pub_rec > 1, 2, pub_rec)),
         pub_rec_bankruptcies = as.factor(if_else(pub_rec_bankruptcies > 1, 2, pub_rec_bankruptcies)),
         purpose = as.factor(if_else(purpose %in% purposes, purpose, as.character("Others"))),
         tot_coll_amt = ifelse(tot_coll_amt == 0, 0, log(tot_coll_amt)),
         tot_cur_bal = ifelse(tot_cur_bal == 0, 0, log(tot_cur_bal)),
         late = as.factor(if_else(total_rec_late_fee > 0, 1, total_rec_late_fee))
  ) %>% 
  select(-delinq_amnt, -earliest_cr_line, -emp_title, -last_credit_pull_d, -sub_grade, 
         -total_rec_late_fee) %>% 
  clean_names()