# Predict the money made on loans issued by a bank - STAT301-3 Regression Competition

This GitHub Repo is a place to present my work for Northwestern University STAT301-3 (Spring 2020) regression competition.

### Data Source: [STAT 301-3 Regression 2020: Bank Loans (Kaggle)](https://www.kaggle.com/c/nustat3013reg)

This data was published on Kaggle (2020) for the purpose of employ the skills and techniques students have learned in class and build a model to predict the amount of money made on loans issued by a bank. To collect this data, I will simply download from the Kaggle website which contains a 2 csv files of training and testing datasets with ~8k and ~4k observations of 35 attributes. The training data consists of loan applications, including information on the applicants themselves, as well as the amount of money made off of each application. Fortunately, the data has no missing values needed to be handled. The target variable for this competition is `money_made_inv`, which is the money made by the bank on a loan. By doing this project, I hope to explore how banks make money from loans and what information or qualities about the applicants in the loan application is more likely to result in more profits for the banks.

I will first approach this dataset by conducting a brief Exploratory Data Analysis on the team statistics using 20% of the training dataset. Then using the initial analysis, I will begin the data cleaning and wrangling process to standardize the non-numeric features and address with potential data issues mentioned in the next section below. Finally, after data cleaning, I will proceed to the model building process trying different regression algorithms and compare their performance in predicting our target using root mean square error.

### How banks make money from loans

To start this project, I need to understand how banks profits from loans in the first place. Depending on different types of loans, banks may charge additional service fees in addition to interests.

### Potential Data Issues

From a brief skimming through the datasets, there are some potential cleanings that need to be done on the data:
1. There are repeated predictors such as `blue_first_blood` and `red_first_blood` which are mutually exclusive within every unique observation. There are also similar predictors such as `blue_dragons` and `red_dragons` that are not mutually exclusive and need to be handled differently.
2. There are also predictors that are opposite but equal with each other due to the nature of the game being divided in two side. For example, `blue_gold_difference` and `red_gold_difference` has the same absolute value as the gold difference is calculated by subtracting the gold from its team by the opposite team.
3. There are some highly correlated predictors such as `blue_cs_per_min` and `blue_gold_per_min` when cs (amount of minions killed) is one of the main sources of gold income.
4. Many categorical columns that should be change to factor types instead of character.
5. Reduce number of features by handling predictor issues above and trim down the dimension of the dataset before model fitting.
6. For the purpose of EDA, I will drop the `gameId` column entirely and assume each row represents a unique game/observation.
