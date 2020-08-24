# Load data
source("model/load_data.R")

# Load libraies
library(xgboost)

# Remove information about the target variable and id from the training data
train_targetrm <- train %>%
  dplyr::select(-money_made_inv, -id)

# save target variable as vector for future comparison
train_label <- train %>% 
  select(money_made_inv) %>% 
  as_vector()

# select just the numeric columns
trainInfo_numeric <- train_targetrm %>%
  select_if(is.numeric)

# select just the factor columns
trainInfo_factor <- train_targetrm %>%
  select_if(is.factor)

# convert categorical factor into one-hot encoding
acc_now_delinq <- model.matrix(~acc_now_delinq-1,train)
#addr_state <- model.matrix(~addr_state-1,train)
application_type <- model.matrix(~application_type-1,train)
emp_length <- model.matrix(~emp_length-1,train)
#emp_title <- model.matrix(~emp_title-1,train)
grade <- model.matrix(~grade-1,train)
home_ownership <- model.matrix(~home_ownership-1,train)
initial_list_status <- model.matrix(~initial_list_status-1,train)
num_tl_120dpd_2m <- model.matrix(~num_tl_120dpd_2m-1,train)
num_tl_30dpd <- model.matrix(~num_tl_30dpd-1,train)
purpose <- model.matrix(~purpose-1,train)
#sub_grade <- model.matrix(~sub_grade-1,train)
term <- model.matrix(~term-1,train)
verification_status <- model.matrix(~verification_status-1,train)

# add our one-hot encoded variable
trainInfo_numeric <- cbind(trainInfo_numeric, acc_now_delinq, application_type, emp_length,
                           grade, home_ownership, initial_list_status, num_tl_120dpd_2m,
                           num_tl_30dpd, purpose, term, verification_status)

# convert the dataframe into a matrix (~3.7 Mb)
trainInfo_matrix <- data.matrix(trainInfo_numeric)

# split 70% for model performance testing
#numberOfTrainingSamples <- round(length(train_label) * .7)
fractionTrain <- 0.70
fractionTest <- 0.30

sampleSizeTrain <- floor(fractionTrain * nrow(trainInfo_matrix))
sampleSizeTest <- floor(fractionTest * nrow(trainInfo_matrix))

indicesTrain <- sort(sample(seq_len(nrow(trainInfo_matrix)), size=sampleSizeTrain))
indicesTest <- setdiff(seq_len(nrow(trainInfo_matrix)), indicesTrain)

# training data
#train_data <- trainInfo_matrix[1:numberOfTrainingSamples,]
#train_labels <- train_label[1:numberOfTrainingSamples]
train_data <- trainInfo_matrix[indicesTrain, ]
train_labels <- train_label[indicesTrain]

# testing data
#test_data <- trainInfo_matrix[-(1:numberOfTrainingSamples),]
#test_labels <- train_label[-(1:numberOfTrainingSamples)]
test_data <- trainInfo_matrix[indicesTest, ]
test_labels <- train_label[indicesTest]


# put our testing & training data into two seperates Dmatrixs objects
dtrain <- xgb.DMatrix(data = train_data, label= train_labels)
dtest <- xgb.DMatrix(data = test_data, label= test_labels)