#############################
# 3. Descriptive plots of TS trends
#
# Seth Warner, 1-2-2024
#############################

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(zoo)
library(scales)


###
# A. Plot Nationscape time series

# Calculate moving averages
window_size <- 14

public_ma <- public_ns %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Public")

democrats_ma <- democrats_ns %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Democrats")

republicans_ma <- republicans_ns %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Republicans")

# Combine data for plotting
combined_ma <- rbind(public_ma, democrats_ma, republicans_ma)

ggplot(combined_ma, aes(x = starttime, y = moving_avg, color = Group, group = Group)) +
  geom_line(size = 1) +
  scale_x_date(date_breaks = "3 month", date_labels = "%b %Y", minor_breaks = NULL) +
  scale_colour_manual(values = c("Public" = "black", "Democrats" = "blue", "Republicans" = "red")) +
  theme_minimal(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom") +
  labs(title = "Affective Polarization from Sept 2019 - Jan 2021 (Nationscape)", 
       x = "Date", 
       y = "Moving Average Polarization", 
       color = "Group",
       caption = "Note: Plot presents 14-day moving averages")



###
# B. Plot America's Pulse time series

# Calculate moving averages
window_size <- 14

public_ma <- public_pulse %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Public")

democrats_ma <- democrats_pulse %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Democrats")

republicans_ma <- republicans_pulse %>%
  mutate(moving_avg = rollmean(polarization, window_size, align = "center", na.pad = TRUE),
         Group = "Republicans")

# Combine data for plotting
combined_ma <- rbind(public_ma, democrats_ma, republicans_ma)

# Plotting
ggplot(combined_ma, aes(x = starttime, y = moving_avg, color = Group, group = Group)) +
  geom_line(size = 1) +
  scale_x_date(date_breaks = "3 month", date_labels = "%b %Y", minor_breaks = NULL) +
  scale_colour_manual(values = c("Public" = "black", "Democrats" = "blue", "Republicans" = "red")) +
  theme_minimal(base_size = 16) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "bottom") +
  labs(title = "Affective Polarization from Sept 2022 - Dec 2023 (Polarization Research Lab)", 
       x = "Date", 
       y = "Moving Average Polarization", 
       color = "Group",
       caption = "Note: Plot presents 14-day moving averages")
