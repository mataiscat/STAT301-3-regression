# Loading package(s)
library(xgboost)
library(tidyverse)
library(onehot)
library(lubridate)


set.seed(1235)


train <- read_csv("train.csv",
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
  select(-last_credit_pull_d, -earliest_cr_line)

test <- read_csv("test.csv",
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
  select(-last_credit_pull_d, -earliest_cr_line)

# Remove information about the target variable from the training data
train_targetrm <- train %>%
  dplyr::select(-money_made_inv, -id)

train_label <- train %>% 
  select(money_made_inv) %>% 
  as_vector()

# select just the numeric columns
trainInfo_numeric <- train_targetrm %>%
  select_if(is.numeric) # select remaining numeric columns

trainInfo_factor <- train_targetrm %>%
  select_if(is.factor) # select remaining numeric columns

# convert categorical factor into one-hot encoding
acc_now_delinq <- model.matrix(~acc_now_delinq-1,train)
addr_state <- model.matrix(~addr_state-1,train)
application_type <- model.matrix(~application_type-1,train)
emp_length <- model.matrix(~emp_length-1,train)
emp_title <- model.matrix(~emp_title-1,train)
grade <- model.matrix(~grade-1,train)
home_ownership <- model.matrix(~home_ownership-1,train)
initial_list_status <- model.matrix(~initial_list_status-1,train)
num_tl_120dpd_2m <- model.matrix(~num_tl_120dpd_2m-1,train)
num_tl_30dpd <- model.matrix(~num_tl_30dpd-1,train)
purpose <- model.matrix(~purpose-1,train)
sub_grade <- model.matrix(~sub_grade-1,train)
term <- model.matrix(~term-1,train)
verification_status <- model.matrix(~verification_status-1,train)

# add our one-hot encoded variable and convert the dataframe into a matrix
trainInfo_numeric <- cbind(trainInfo_numeric, acc_now_delinq, application_type, emp_length,
                           grade, home_ownership, initial_list_status, num_tl_120dpd_2m,
                           num_tl_30dpd, purpose, term, verification_status)

trainInfo_matrix <- data.matrix(trainInfo_numeric)

# get the numb 70/30 training test split
#numberOfTrainingSamples <- round(length(train_label) * .7)

# training data
#train_data <- trainInfo_matrix[1:numberOfTrainingSamples,]
train_data <- trainInfo_matrix
#train_labels <- train_label[1:numberOfTrainingSamples]
train_labels <- train_label

# testing data
#test_data <- trainInfo_matrix[-(1:numberOfTrainingSamples),]
#test_labels <- train_label[-(1:numberOfTrainingSamples)]

# generate final predition on test data

# Remove information about the target variable from the training data
test_targetrm <- test %>%
  dplyr::select(-id)

# select just the numeric columns
testInfo_numeric <- test_targetrm %>%
  select_if(is.numeric) # select remaining numeric columns

testInfo_factor <- test_targetrm %>%
  select_if(is.factor) # select remaining numeric columns

# convert categorical factor into one-hot encoding
acc_now_delinq_test <- model.matrix(~acc_now_delinq-1,test)
addr_state_test <- model.matrix(~addr_state-1,test)
application_type_test <- model.matrix(~application_type-1,test)
emp_length_test <- model.matrix(~emp_length-1,test)
emp_title_test <- model.matrix(~emp_title-1,test)
grade_test <- model.matrix(~grade-1,test)
home_ownership_test <- model.matrix(~home_ownership-1,test)
initial_list_status_test <- model.matrix(~initial_list_status-1,test)
num_tl_120dpd_2m_test <- model.matrix(~num_tl_120dpd_2m-1,test)
num_tl_30dpd_test <- model.matrix(~num_tl_30dpd-1,test)
purpose_test <- model.matrix(~purpose-1,test)
sub_grade_test <- model.matrix(~sub_grade-1,test)
term_test <- model.matrix(~term-1,test)
verification_status_test <- model.matrix(~verification_status-1,test)

# add our one-hot encoded variable and convert the dataframe into a matrix
testInfo_numeric <- cbind(testInfo_numeric, acc_now_delinq_test, application_type_test, 
                          emp_length_test, grade_test, home_ownership_test, 
                          initial_list_status_test, num_tl_120dpd_2m_test,
                          num_tl_30dpd_test, purpose_test, term_test, verification_status_test)

testInfo_matrix <- data.matrix(testInfo_numeric)

test_data <- testInfo_matrix

test_labels <- test %>% 
  mutate(money_made_inv = 0) %>% 
  select(money_made_inv) %>% 
  as_vector()

# Convert the cleaned dataframe to a dmatrix

# put our testing & training data into two seperates Dmatrixs objects
dtrain <- xgb.DMatrix(data = train_data, label= train_labels)
dtest <- xgb.DMatrix(data = test_data, label= test_labels)

# Training our model

# train a model using our training data
model <- xgboost(data = dtrain, # the data   
                 nround = 550, # max number of boosting iterations,
                 eta = 0.05,
                 subsample = 0.6,
                 min_child_weight = 3,
                 num_parallel_tree = 4,
                 max_depth = 5,
                 objective = "reg:linear")  # the objective function

# train-rmse: 27.769 (with cv)
# train-rmse: 94.593 (with entire train dataset and default parameters)

# generate predictions for our held-out testing data
pred <- predict(model, dtest)

# get & print the regression error
err <- sqrt(mean((pred - test_labels)^2))
print(paste("test-error=", err))

# test-error: 1473.180

# submission
out <- tibble(Id = test$id,
              Predicted = as.character(pred))

write_csv(out, "test_predictions_xgboost.csv")
