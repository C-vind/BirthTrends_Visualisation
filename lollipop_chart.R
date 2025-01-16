# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)

# Load data from file 2023birthregistrations.xlsx from tab "Table_12" and start read the data from the sixth row
dailyLiveBirths <- read_excel("2023birthregistrations.xlsx", sheet = "Table_12", skip = 5)

# ======================================= Data Pre-Processing =======================================

# Remove the column for years before 10 years ago
dailyLiveBirths <- dailyLiveBirths %>% select(3:12)

# Handle missing values by replacing all value of "[z]" with "0"
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(everything(), ~str_replace(., "\\[z\\]", "0")))

# Convert all data to numeric class
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(everything(), as.numeric))

# Calculate the total number of live births for each year
yearlyLiveBirths <- dailyLiveBirths %>% summarise(across(everything(), sum))

# Reorder the column name ascendingly from 2014 to 2023
yearlyLiveBirths <- yearlyLiveBirths[, order(colnames(yearlyLiveBirths))]

# Transform the structure to table with two columns: Year and LiveBirths
yearlyLiveBirths <- yearlyLiveBirths %>%
	pivot_longer(cols = everything(), names_to = "Year", values_to = "LiveBirths")

# Calculate the mean live births across all 10 years
meanLiveBirths <- mean(yearlyLiveBirths$LiveBirths)

# Add new column to assign different color based on
# whether the number of live birth is above or below the mean
yearlyLiveBirths <- yearlyLiveBirths %>%
	mutate(Color = ifelse(LiveBirths > meanLiveBirths, "#f8766d", "#619cff"))

# ======================================= Data Visualisation =======================================

# Generate lollipop chart
yearlyLiveBirths %>%
	ggplot(aes(x = Year, y = LiveBirths)) +
	geom_segment(
		aes(
			x = Year,
			xend = Year,
			y = meanLiveBirths,
			yend = LiveBirths
		),
		color = ifelse(yearlyLiveBirths$Year == "2023", "#BF2F24",
			ifelse(yearlyLiveBirths$LiveBirths > meanLiveBirths, "#4f6f7c", "#f8766d")),
		alpha = 0.8,
		linewidth = ifelse(yearlyLiveBirths$Year == "2023", 2.5, 1.8)
	) +
	geom_point(
		shape = 21,
		color = "#ffffff",
		fill = ifelse(yearlyLiveBirths$Year == "2023", "#BF2F24", "#69b3a2"),
		size = ifelse(yearlyLiveBirths$Year == "2023", 13, 10.5),
		stroke = ifelse(yearlyLiveBirths$Year == "2023", 3.5, 2.5)
	) +
	geom_text(
		aes(label = ifelse(Year == "2023", "", LiveBirths)),
		fontface = "bold",
		size = 5,
		nudge_y = ifelse(yearlyLiveBirths$LiveBirths > meanLiveBirths, 5500, -5500)
	) +
	geom_hline(
		yintercept = meanLiveBirths,
		color = "#00ba38",
		linewidth = 1.3,
		linetype = 5
	) +
	annotate(
		"text",
		x = grep("2023", yearlyLiveBirths$Year) - 4.51,
		y = yearlyLiveBirths$LiveBirths[which(yearlyLiveBirths$Year == "2023")],
		label = paste(
			"Lowest number of live births in the last 10 years:",
			yearlyLiveBirths$LiveBirths[which(yearlyLiveBirths$Year == "2023")],
			sep = " "
		),
		color = "#BF2F24",
		size = 7,
		fontface = "bold",
		hjust = 0
	) +
	labs(
		title = "Yearly number of live births in England and Wales",
		x = "Year",
		y = "Number of Live Births"
	) +
	theme_minimal() +
	theme(
		panel.grid.major.x = element_blank(),
		panel.grid.major.y = element_line(color = "grey90"),
		panel.grid.minor.y = element_line(linetype = 3, color = "grey55"),
		plot.title = element_text(face = "bold", size = 30, hjust = 0.5, margin = margin(b = 15)),
		axis.title.x = element_text(size = 24, margin = margin(t = 15)),
		axis.text.x = element_text(size = 18),
		axis.title.y = element_text(size = 26, margin = margin(r = 20)),
		axis.text.y = element_text(size = 16.5),
		plot.margin = margin(l = 25, r = 5, b = 15, t = 30)
	)
