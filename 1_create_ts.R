##########################
# 1. Create 2019-23 polarization time series
#
# Seth Warner, 1-2-2024
##########################

library(dplyr)

###
# A. Standardize variables

# i. Nationscape data

natscape$party <- ifelse(natscape$pid7_legacy < 4, 'Democrat',
                         ifelse(natscape$pid7_legacy > 4, 'Republican', 'Independent'))

natscape$polarization <- ifelse(natscape$party == 'Democrat',
                                natscape$ft_dems - natscape$ft_reps, # If Dems, the D - R
                                
                                ifelse(natscape$party == 'Republican', 
                                       natscape$ft_reps - natscape$ft_dems, # If Reps, then R - D
                                       
                                       ifelse(natscape$ft_dems > natscape$ft_reps, # If neither, higher - lower
                                              natscape$ft_dems - natscape$ft_reps,
                                              natscape$ft_reps - natscape$ft_dems)))

natscape$ingroup_feel <- ifelse(natscape$party == 'Democrat', natscape$ft_dems,
                                ifelse(natscape$party == 'Republican', natscape$ft_reps, NA))

natscape$outgroup_feel <- ifelse(natscape$party == 'Democrat', natscape$ft_reps,
                                ifelse(natscape$party == 'Republican', natscape$ft_dems, NA))

natscape$bachelors <- ifelse(natscape$education >= 8, 1, 0)
natscape$male <- ifelse(natscape$gender == 2, 1, 0)
natscape$white <- ifelse(natscape$race_ethnicity == 1 & natscape$hispanic == 1, 1, 0)
natscape$high_interest <- ifelse(natscape$interest == 1, 1, 0)
natscape$strong_partisan <- ifelse(natscape$pid7_legacy == 1 | natscape$pid7_legacy == 7, 1, 0)
natscape$starttime <- natscape$start_date
natscape$survey <- 'Nationscape'


# ii. America's Political Pulse data

pol_pulse$party <- ifelse(grepl('Democrat',pol_pulse$pid7), 'Democrat',
                          ifelse(grepl('Republican', pol_pulse$pid7), 'Republican', 'Independent'))

pol_pulse$polarization <- ifelse(pol_pulse$party == 'Democrat',
                                 pol_pulse$democrat_therm_1 - pol_pulse$republican_therm_1,
                                 
                                 ifelse(pol_pulse$party == 'Republican',
                                        pol_pulse$republican_therm_1 - pol_pulse$democrat_therm_1,
                                        
                                        ifelse(pol_pulse$democrat_therm_1 > pol_pulse$republican_therm_1,
                                               pol_pulse$democrat_therm_1 - pol_pulse$republican_therm_1,
                                               pol_pulse$republican_therm_1 - pol_pulse$democrat_therm_1)))

pol_pulse$ingroup_feel <- ifelse(pol_pulse$party == 'Democrat', pol_pulse$democrat_therm_1,
                                 ifelse(pol_pulse$party == 'Republican', pol_pulse$republican_therm_1, NA))

pol_pulse$outgroup_feel <- ifelse(pol_pulse$party == 'Democrat', pol_pulse$republican_therm_1,
                                 ifelse(pol_pulse$party == 'Republican', pol_pulse$democrat_therm_1, NA))

pol_pulse$bachelors <- ifelse(pol_pulse$educ == '4-year' | pol_pulse$educ == 'Post-grad', 1, 0)
pol_pulse$male <- ifelse(pol_pulse$gender == 'Male', 1, 0)
pol_pulse$white <- ifelse(pol_pulse$race == 'White', 1, 0)
pol_pulse$high_interest <- ifelse(pol_pulse$newsint == 'Most of the time', 1, 0)
pol_pulse$strong_partisan <- ifelse(grepl('Strong', pol_pulse$pid7), 1, 0)
pol_pulse$survey <- "America's Political Pulse"


###
# B. Create a combined dataframe

# i. Pick out collated variables
natscape_selected <- natscape[, c("starttime", "polarization", "party", "ingroup_feel", "outgroup_feel", "bachelors", "male", "white", "high_interest", "strong_partisan", "weight", "survey")]
pol_pulse_selected <- pol_pulse[, c("starttime", "polarization", "party", "ingroup_feel", "outgroup_feel", "bachelors", "male", "white", "high_interest", "strong_partisan", "weight", "survey")]

combined_df <- rbind(natscape_selected, pol_pulse_selected)


###
# C. Make function that aggregates weighted mean by date

# Convert starttime to Date format
combined_df$starttime <- as.Date(combined_df$starttime)

# Function to calculate weighted mean
weighted_mean <- function(x, w) {
  sum(x * w, na.rm = TRUE) / sum(w, na.rm = TRUE) }

# Function to find the mode
get_mode <- function(x) {
  uniqx <- unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))] }

# Aggregate data by date for different subsets
aggregate_data <- function(data) {
  data %>%
    group_by(starttime) %>%
    summarise(
      polarization = weighted_mean(polarization, weight),
      ingroup_feel = weighted_mean(ingroup_feel, weight),
      outgroup_feel = weighted_mean(outgroup_feel, weight),
      pct_bachelors = weighted_mean(bachelors, weight),
      pct_male = weighted_mean(male, weight),
      pct_white = weighted_mean(white, weight),
      pct_high_interest = weighted_mean(high_interest, weight),
      pct_strong_partisan = weighted_mean(strong_partisan, weight),
      survey = get_mode(survey),
      day_of_week = weekdays(starttime[1]),
      n_responses = n()
    )
}


###
# D. Create time series datasets

# Subsets
democrats <- combined_df %>% filter(party == 'Democrat')
republicans <- combined_df %>% filter(party == 'Republican')

# Aggregate data
democrats_all <- aggregate_data(combined_df %>% filter(party == 'Democrat'))
republicans_all <- aggregate_data(combined_df %>% filter(party == 'Republican'))
public_all <- aggregate_data(combined_df)

democrats_ns <- aggregate_data(combined_df %>% filter(party == 'Democrat' & survey == 'Nationscape'))
republicans_ns <- aggregate_data(combined_df %>% filter(party == 'Republican' & survey == 'Nationscape'))
public_ns <- aggregate_data(combined_df %>% filter(survey == 'Nationscape'))

democrats_pulse <- aggregate_data(combined_df %>% filter(party == 'Democrat' & survey == "America's Political Pulse"))
republicans_pulse <- aggregate_data(combined_df %>% filter(party == 'Republican' & survey == "America's Political Pulse"))
public_pulse <- aggregate_data(combined_df %>% filter(survey == "America's Political Pulse"))


###
# E. Clean up environment

# List of objects to keep
keep_objects <- c("democrats_all", "republicans_all", "public_all", 
                  "democrats_ns", "republicans_ns", "public_ns", 
                  "democrats_pulse", "republicans_pulse", "public_pulse")

# Get all objects in the environment
all_objects <- ls()

# Determine which objects to remove
remove_objects <- setdiff(all_objects, keep_objects)

# Remove the objects
rm(list = remove_objects)
rm(all_objects, remove_objects)

# Save
save.image('ts_data.RData')