# Load xgboost setup
source("model/XGBoost/xgboost_setup.R")

set.seed(13281)

# Load libraies
library(reshape2)

# Tuning Parameters
model_performance <- tibble(nround = numeric(),
                            eta = numeric(),
                            subsample = numeric(),
                            min_child_weight = numeric(),
                            max_depth = numeric(),
                            train_rmse = numeric(),
                            test_rmse = numeric())


nrounds <- 550
eta <- c(0.03, 0.05, 0.07)
subsample <- c(1/3, 0.5, 0.75)
min_child_weight <- c(1, 2, 3, 4)
max_depth <- c(4, 5, 6, 7)

for(et in eta) {
  for(mc in min_child_weight) {
    for(md in max_depth) {
      for(ss in subsample) {
        params = list(eta = et, min_child_weight = mc,
                    max_depth = md, subsample = ss)
        
        xgb = xgboost(dtrain, nrounds = nrounds, params = params)
        
        train_rmse = xgb$evaluation_log$train_rmse[nrounds]
        pred = predict(xgb, dtest)
        test_rmse = sqrt(mean((pred - test_labels)^2))
        
        model_performance <- model_performance %>% 
          add_row(nround = nrounds,
                  eta = et,
                  subsample = ss,
                  min_child_weight = mc,
                  max_depth = md,
                  train_rmse = train_rmse,
                  test_rmse = test_rmse)
      }
    }
  }
}

model_performance %>% 
  arrange(test_rmse)

write_csv(model_performance, "model/XGBoost/model_performance.csv")

# ETA
# learning rate

eta <- c(0.01, 0.03, 0.05, 0.07, 0.1)
eta_performance <- matrix(NA, nrounds, length(eta))

for(i in 1:length(eta)) {
  
  params = list(eta = eta[i], min_child_weight = 4,
                max_depth = 6, subsample = 0.5)
  
  xgb = xgboost(dtrain, nrounds = nrounds, params = params)
  
  eta_performance[,i] = xgb$evaluation_log$train_rmse
  
  train_rmse = xgb$evaluation_log$train_rmse[nrounds]
  pred = predict(xgb, dtest)
  test_rmse = sqrt(mean((pred - test_labels)^2))
  
  model_performance <- model_performance %>% 
    add_row(nround = nrounds,
            eta = eta[i],
            subsample = 0.5,
            min_child_weight = 4,
            max_depth = 6,
            train_rmse = train_rmse,
            test_rmse = test_rmse)
}

eta_performance <- data.frame(iter = 1:nrounds, eta_performance)
eta_performance <- melt(eta_performance, id.vars = "iter")
eta_performance %>% 
  ggplot(aes(x = iter, y = value, color = variable)) +
  geom_line()

model_performance %>% 
  arrange(test_rmse)

# Subsample Ratios
# randomly collected fractions of the training instance to grow trees (prevent overfitting)

subsample <- c(1/3, 0.5, 0.75)
ss_performance <- matrix(NA, nrounds, length(subsample))

for(i in 1:length(subsample)) {
  
  params = list(eta = 0.05, min_child_weight = 4,
                max_depth = 6, subsample = subsample[i])
  
  xgb = xgboost(dtrain, nrounds = nrounds, params = params)
  
  ss_performance[,i] = xgb$evaluation_log$train_rmse
  
  train_rmse = xgb$evaluation_log$train_rmse[nrounds]
  pred = predict(xgb, dtest)
  test_rmse = sqrt(mean((pred - test_labels)^2))
  
  model_performance <- model_performance %>% 
    add_row(nround = nrounds,
            eta = 0.05,
            subsample = subsample[i],
            min_child_weight = 4,
            max_depth = 6,
            train_rmse = train_rmse,
            test_rmse = test_rmse)
}

ss_performance <- data.frame(iter = 1:nrounds, ss_performance)
ss_performance <- melt(ss_performance, id.vars = "iter")
ss_performance %>% 
  ggplot(aes(x = iter, y = value, color = variable)) +
  geom_line()

model_performance %>% 
  arrange(test_rmse)

# Min Child Weight

min_child_weight <- c(1, 2, 3, 4)
mc_performance <- matrix(NA, nrounds, length(min_child_weight))

for(i in 1:length(min_child_weight)) {
  
  params = list(eta = 0.05, min_child_weight = min_child_weight[i],
                max_depth = 6, subsample = 0.5)
  
  xgb = xgboost(dtrain, nrounds = nrounds, params = params)
  
  mc_performance[,i] = xgb$evaluation_log$train_rmse
  
  train_rmse = xgb$evaluation_log$train_rmse[nrounds]
  pred = predict(xgb, dtest)
  test_rmse = sqrt(mean((pred - test_labels)^2))
  
  model_performance <- model_performance %>% 
    add_row(nround = nrounds,
            eta = 0.05,
            subsample = 0.5,
            min_child_weight = min_child_weight[i],
            max_depth = 6,
            train_rmse = train_rmse,
            test_rmse = test_rmse)
}

mc_performance <- data.frame(iter = 1:nrounds, mc_performance)
mc_performance <- melt(mc_performance, id.vars = "iter")
mc_performance %>% 
  ggplot(aes(x = iter, y = value, color = variable)) +
  geom_line()

model_performance %>% 
  arrange(test_rmse)

# Max Depth
max_depth <- c(4, 5, 6, 7)
md_performance <- matrix(NA, nrounds, length(max_depth))

for(i in 1:length(max_depth)) {
  
  params = list(eta = 0.05, min_child_weight = 4,
                max_depth = max_depth[i], subsample = 0.5)
  
  xgb = xgboost(dtrain, nrounds = nrounds, params = params)
  
  md_performance[,i] = xgb$evaluation_log$train_rmse
  
  train_rmse = xgb$evaluation_log$train_rmse[nrounds]
  pred = predict(xgb, dtest)
  test_rmse = sqrt(mean((pred - test_labels)^2))
  
  model_performance <- model_performance %>% 
    add_row(nround = nrounds,
            eta = 0.05,
            subsample = 0.5,
            min_child_weight = 4,
            max_depth = max_depth[i],
            train_rmse = train_rmse,
            test_rmse = test_rmse)
}

md_performance <- data.frame(iter = 1:nrounds, md_performance)
md_performance <- melt(md_performance, id.vars = "iter")
md_performance %>% 
  ggplot(aes(x = iter, y = value, color = variable)) +
  geom_line()

model_performance %>% 
  arrange(test_rmse)

# Training our model
model <- xgboost(data = dtrain, # the data  
                 nround = 550, # max number of boosting iterations,
                 eta = 0.05,
                 subsample = 0.50,
                 min_child_weight = 4,
                 max_depth = 6,
                 objective = "reg:linear")  # the objective function

# generate predictions for our held-out testing data
pred <- predict(model, dtest)
summary(pred)

# get & print the regression error
err <- sqrt(mean((pred - test_labels)^2))
print(paste("test-error=", err))

# Analyze results
feature_names <- colnames(trainInfo_numeric)
importance <- xgb.importance(feature_names, model)
