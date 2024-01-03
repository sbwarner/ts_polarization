#######################
# 2. Basic diagnostics of TS data
#
# Seth Warner, 1-2-2024
########################

# Load the tseries package for the ADF test
library(tseries)

###
# A. Stationarity of time series

# Dataframes and their corresponding columns
dataframes <- c("democrats_ns", "democrats_pulse", 
                "public_ns", "public_pulse", 
                "republicans_ns", "republicans_pulse")
columns <- c("polarization", "ingroup_feel", "outgroup_feel")

# Initialize a dataframe to store results
adf_results_df <- data.frame(
  dataframe = character(),
  column = character(),
  test_statistic = numeric(),
  p_value = numeric(),
  is_stationary = logical(),
  stringsAsFactors = FALSE
)

# Function to perform ADF test and add results to dataframe
run_adf_test <- function(df, col) {
  ts_data <- get(df)[[col]]
  adf_test_result <- adf.test(ts_data, alternative = "stationary")
  
  # Add results to dataframe
  adf_results_df <<- rbind(adf_results_df, data.frame(
    dataframe = df,
    column = col,
    test_statistic = adf_test_result$statistic,
    p_value = adf_test_result$p.value,
    is_stationary = adf_test_result$p.value < 0.05,
    stringsAsFactors = FALSE
  ))
}

# Loop through dataframes and columns to run ADF test
for (df in dataframes) {
  for (col in columns) {
    if (col %in% names(get(df))) { # Check if the column exists in the dataframe
      run_adf_test(df, col)
    }
  }
}
warnings() # Just saying that the p-values are less than 0.01

# All 18 time series show stationarity
adf_results_df


###
# B. Autocorrelation in time series

# Define a set of lags for the Ljung-Box test
lags <- 1:20

# Initialize a dataframe to store results
box_test_results_df <- data.frame(
  dataframe = character(),
  column = character(),
  lag = integer(),
  test_statistic = numeric(),
  p_value = numeric(),
  is_significant = logical(),
  stringsAsFactors = FALSE
)

# Function to perform Ljung-Box test and add results to dataframe
run_box_test <- function(df, col) {
  ts_data <- get(df)[[col]]
  
  for (lag in lags) {
    test_result <- Box.test(ts_data, lag = lag, type = "Ljung-Box")
    
    # Add results to dataframe
    box_test_results_df <<- rbind(box_test_results_df, data.frame(
      dataframe = df,
      column = col,
      lag = lag,
      test_statistic = test_result$statistic,
      p_value = test_result$p.value,
      is_significant = test_result$p.value < 0.01,
      stringsAsFactors = FALSE
    ))
  }
}

# Loop through dataframes and columns to run Ljung-Box test
for (df in dataframes) {
  for (col in columns) {
    if (col %in% names(get(df))) {
      run_box_test(df, col)
    }
  }
}

# Some group affect TSs show autocorrelation, more limited for polarization TSs
table(paste(box_test_results_df$dataframe, box_test_results_df$column),
      box_test_results_df$is_significant)

