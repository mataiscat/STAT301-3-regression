library(keras)
library(tidyverse)
library(onehot)
library(tensorflow)


set.seed(12345)


train_data <- read_csv('data/train.csv') %>%
  mutate_if(is_character, as_factor)
test_data <- read_csv('data/test.csv')
id <- test_data$id

#one hot encode
ohe_rules <- train_data %>% 
  select(-earliest_cr_line, -money_made_inv, -id) %>% 
  onehot()

train_data_ohe <- train_data %>%
  select(-earliest_cr_line, -money_made_inv, -id) %>% 
  predict(ohe_rules, data = .)

test_data_ohe <- test_data %>%
  select(-earliest_cr_line) %>% 
  predict(ohe_rules, data = .)

train_targets <- train_data %>% 
  pull(money_made_inv) 


means_train_data <- apply(train_data_ohe, 2, mean)
std_train_data <- apply(train_data_ohe, 2, sd)

train_data <- scale(train_data_ohe, center = means_train_data, scale = std_train_data)
test_data <- scale(test_data_ohe, center = means_train_data, scale = std_train_data)



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
