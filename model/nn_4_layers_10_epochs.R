# Load data
source("load_data.R")

# Load libraies
library(keras)
library(onehot)
library(tensorflow)

set.seed(12345)

#one hot encode
ohe_rules <- train %>% 
  select(-money_made_inv, -id, -addr_state, -emp_length, -emp_title, -purpose, -sub_grade) %>% 
  onehot()

train_ohe <- train %>%
  select(-money_made_inv, -id, -addr_state, -emp_length, -emp_title, -purpose, -sub_grade) %>% 
  predict(ohe_rules, data = .)

test_ohe <- test %>%
  select(-id, -addr_state, -emp_length, -emp_title, -purpose, -sub_grade) %>% 
  predict(ohe_rules, data = .)

train_targets <- train %>% 
  pull(money_made_inv)

means_train_data <- apply(train_ohe, 2, mean)
std_train_data <- apply(train_ohe, 2, sd)

train_data <- scale(train_ohe, center = means_train_data, scale = std_train_data)
test_data <- scale(test_ohe, center = means_train_data, scale = std_train_data)

use_python("/Users/JunhuaTan/opt/anaconda3/bin/python")

#4 layer nn 10 epochs
model <- keras_model_sequential() %>% 
  layer_dense(units = 32, activation = "relu", input_shape = c(dim(train_data)[[2]])) %>% 
  layer_dense(units = 32, activation = "relu") %>% 
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1)

model %>% compile(
  optimizer = "rmsprop", 
  loss = "mse", 
  metrics = c("mse")
)

val_indices <- 1:500
x_val <- train_data[val_indices,]
partial_x_train <- train_data[-val_indices,]
y_val <- train_targets[val_indices]
partial_y_train <- train_targets[-val_indices]


history <- model %>% fit(
  partial_x_train,
  partial_y_train,
  epochs = 10,
  batch_size = 1,
  validation_data = list(x_val, y_val),
  verbose = 0
)

history$metrics$val_mse
plot(history)

nn_pred <- model %>% predict(test_data)

nn_out <-tibble(
  Id = id,
  Predicted = nn_pred
)

write_csv(nn_out, "nn_test_predictions.csv")
