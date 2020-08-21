# Load xgboost setup
source("xgboost_setup.R")

# Training our model
model <- xgboost(data = dtrain, # the data   
                 label = train_labels,
                 nround = 550, # max number of boosting iterations,
                 eta = 0.05,
                 subsample = 0.50,
                 min_child_weight = 4,
                 num_parallel_tree = 4,
                 max_depth = 6,
                 objective = "reg:linear")  # the objective function

# generate predictions for our held-out testing data
pred <- predict(model, dtest)

# get & print the regression error
err <- sqrt(mean((pred - test_labels)^2))
print(paste("test-error=", err))

model_performance <- tibble(nround = numeric(),
                            eta = numeric(),
                            subsample = numeric(),
                            min_child_weight = numeric(),
                            max_depth = numeric(),
                            train_rmse = numeric(),
                            test_rmse = numeric())

nround <- c(100, 300, 550)
eta <- c(0.05, 0.1)
min_child_weight <- c(2, 4)
max_depth <- c(5, 6)
subsample <- c(0.5, 0.75)

for(n in nround) {
  for(et in eta) {
    for(mc in min_child_weight) {
      for(md in max_depth) {
        for(ss in subsample) {
          params = list(eta = et, min_child_weight = mc,
                      max_depth = md, subsample = ss)
          xgb = xgboost(dtrain, label = train_labels,  nrounds = n, params = params)
          
          train_rmse = xgb$evaluation_log$train_rmse[n]
          pred = predict(xgb, dtest)
          test_rmse = sqrt(mean((pred - test_labels)^2))
          
          model_performance <- model_performance %>% 
            add_row(nround = n,
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
}

model_performance %>% 
  arrange(test_rmse)

# Analyze results
feature_names <- colnames(trainInfo_numeric)
importance <- xgb.importance(feature_names, model)
