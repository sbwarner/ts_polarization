Over the past few years, frequent survey questions about partisan affect in the US have made it possible to study affective polarization using time series data. This compiles responses to two large projects, the Nationscape and America's Political Pulse surveys, to create a combined daily time series of T ~ 1000 for US polarization from 2019 and 2023.

Data are included in the ts_data.RData file. This is an R environment with 9 dataframes, each containing 3 separate time series. The first word ("public", "democrats", and "republicans") indicates the group for which polarization is measured, and the second word ("ns", "pulse", or "all") indicates which survey the time series was drawn from, or if it combines them both. Then, each dataframe has a time series for polarization and its component parts, inparty affect and outparty affect.

In additional columns, the dataframes contain information about the daily survey sample represented by each row. These columns are:

* pct_bachelors -- Weighted percentage of respondents with a Bachelor's degree or higher
* pct_white -- Weighted percentage of respondents who are non-Hispanic White
* pct_male -- Weighted percentage of respondents whose gender ID is male
* pct_strong_partisan -- Weighted percentage of respondents who identify as "strong" partisans (a 1 or 7 on the seven-point PID scale)
* pct_high_interest -- Weighted percentage of respondents who say they follow news "most of the time"
* survey -- Whether day's responses come from Nationscape or America's Political Pulse study
* day_of_week -- Day of week (Sun to Sat) for that row's responses
* n_responses -- Number of responses contributing to that day's estimates

Additional notes for analysis:

* The source data from the Nationscape and America's Political Pulse studies are not housed here. You can download them from the links below:
    https://www.voterstudygroup.org/data/nationscape
    https://polarizationresearchlab.org/americas-political-pulse/ (see "Download" on the left sidebar)
  
* In these data, polarization and affect are presented on a 0 to 100 scale. This is the standard set by the ANES feeling thermometers, which the America's Political Pulse survey uses. To scale the Nationscape study, I assigned values of 0/33/66/99 to the responses "very unfavorable," "somewhat unfavorable," "somewhat favorable," and "very favorable" (see my dissertation for validation of this instrument). An artifact of this is that NS scores are slightly lower than APP, and analyses should account for this using a control variable indicating the survey from which estimates were sourced.
