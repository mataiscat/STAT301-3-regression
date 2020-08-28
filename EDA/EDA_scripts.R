# Loading package(s)
library(tidyverse)
library(onehot)
library(lubridate)
library(janitor)
library(dataMaid)
library(corrplot)
library(dataMaid)

# Set seed
set.seed(12352)

setwd("~/Documents/GitHub/STAT301-3-regression")
dataset <- read_csv("data/train.csv",
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
                                                                  "Source Verified")))
)

fractionEDA <- 0.20
sampleSizeEDA <- floor(fractionEDA * nrow(dataset))

indicesEDA <- sort(sample(seq_len(nrow(dataset)), size=sampleSizeEDA))
EDA_data <- dataset[indicesEDA, ]

# Check Missing Values
EDA_data %>% 
  summarise_all(funs(
    sum(is.na(.)) / length(.)
  ))

# Check Co-linearity
EDA_data %>% 
  select_if(is.numeric) %>% 
  cor() %>% 
  corrplot()

# Make a codebook containing these variable description (already made)
#makeCodebook(train, replace = TRUE)