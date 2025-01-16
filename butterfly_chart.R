# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)
library(reshape2)
library(ggtext)

# Load data from file 2023birthsbyparentscountryofbirth.xlsx from sheet "Table_2a"
# and start read the data from the ninth row
parentsCountryOfBirth <- read_excel("2023birthsbyparentscountryofbirth.xlsx", sheet = "Table_2a", skip = 8)

# ======================================= Data Pre-Processing =======================================

# Remove all but first row
parentsCountryOfBirth <- parentsCountryOfBirth[1,]

# Get all column name that contain "Percentage of all live births"
selectedColumnName <- grep("Percentage of all live births", colnames(parentsCountryOfBirth))

# Create a list of number from 2023 to 2003 decrement by 5
selectedYears <- 2023 - 5 * (0:4)

# Filter only columns with year in selectedYears
selectedColumnName <- colnames(parentsCountryOfBirth[, selectedColumnName]) %>%
	str_subset(paste(selectedYears, collapse = "|"))

# Remove all columns except the columns in selectedColumnName
parentsCountryOfBirth <- parentsCountryOfBirth %>% select(all_of(selectedColumnName))

# Flip the column to become row
parentsCountryOfBirth <- t(parentsCountryOfBirth)

# Rename column name to "Non_UK"
colnames(parentsCountryOfBirth) <- "Non_UK"

# Rename row to number from 1 to 5
rownames(parentsCountryOfBirth) <- c(1:5)

# Convert above matrix to data frame
parentsCountryOfBirth <- as.data.frame(parentsCountryOfBirth)

# Add new column named Year with value from selectedYears
parentsCountryOfBirth <- parentsCountryOfBirth %>%
	mutate(Year = selectedYears)

# Change value in column "Non_UK" to numeric
parentsCountryOfBirth <- parentsCountryOfBirth %>%
	mutate(across(Non_UK, as.numeric))

# Round all value in column "Non_UK" to 1 decimal place
parentsCountryOfBirth <- parentsCountryOfBirth %>%
	mutate(across(Non_UK, ~round(., 1)))

# Create new column named "UK" with value "Non_UK" - 100
parentsCountryOfBirth <- parentsCountryOfBirth %>%
	mutate(`UK` = `Non_UK` - 100)

# Transpose the data frame
parentsCountryOfBirth <- melt(parentsCountryOfBirth, id.vars = "Year")

# Sort the data frame by Year
parentsCountryOfBirth <- parentsCountryOfBirth %>%
	arrange(Year)

# Update column name
colnames(parentsCountryOfBirth) <- c("Year", "Country of Birth", "Percentage")

# Create new table that only consists of data with "Non_UK" countries
countryNonUK <- subset(parentsCountryOfBirth, `Country of Birth` == "Non_UK")

# Create new table that only consists of data with "UK" countries
countryUK <- subset(parentsCountryOfBirth, `Country of Birth` == "UK")

# Update the Percentage value to positive
countryUK$Percentage <- abs(countryUK$Percentage)

# ======================================= Data Visualisation =======================================

# Generate butterfly chart
ggplot(parentsCountryOfBirth, aes(x = Year, color = `Country of Birth`)) +
	geom_linerange(
		data = parentsCountryOfBirth[parentsCountryOfBirth$`Country of Birth` == "UK",],
		aes(ymin = -2, ymax = -2 + `Percentage` + 66),
		linewidth = 20
	) +
	geom_linerange(data = parentsCountryOfBirth[parentsCountryOfBirth$`Country of Birth` == "Non_UK",],
		aes(ymin = 2, ymax = 2 + `Percentage` - 16),
		linewidth = 20
	) +
	geom_label(
		aes(x = Year, y = 0, label = Year),
		inherit.aes = F,
		fontface = "bold",
		size = 8,
		label.padding = unit(0.0, "lines"),
		label.size = 0,
		fill = "#ffffff",
		color = "black"
	) +
	geom_text(
		data = countryNonUK,
		aes(x = Year, y = 2, label = paste0(Percentage, "%")),
		nudge_y = 0.37,
		family = "Arial Narrow",
		fontface = "bold",
		colour = "white",
		hjust = 0,
		size = 6.5
	) +
	geom_text(
		data = countryUK,
		aes(x = Year, y = -2, label = paste0(Percentage, "%")),
		nudge_y = -0.37,
		family = "Arial Narrow",
		fontface = "bold",
		colour = "white",
		hjust = 1,
		size = 6.5
	) +
	scale_color_manual(
		name = "",
		values = c(`UK` = "#7B2C3CFF", `Non_UK` = "#294F5EFF"),
		labels = c("`UK`", "Non_UK")
	) +
	scale_x_reverse(
		breaks = c(seq(2003, 2023, 5))
	) +
	scale_y_continuous(
		limits = c(-17.8, 17.8),
		breaks = c(c(-16, -12, -8, -4, 0) + -2, c(0, 4, 8, 12, 16) + 2),
		labels = c("82", "78", "74", "70", "66", "16", "20", "24", "28", "32")
	) +
	coord_flip() +
	labs(
		title = "Live birth percentage by mother's country of birth",
		subtitle = "<b><span style='color:#7B2C3CFF '>Red bar</span></b> represents <span
		style='color:black'><i>\"UK\"</i></span> countries. <b><span style='color:#294F5EFF'>Blue bar</span></b>
		represents <span style='color:black'><i>\"Non-UK\"</i></span> countries.",
		x = "Number of Live Births",
		y = "Year"
	) +
	theme_minimal() +
	theme(
		legend.position = "none",
		plot.title = element_text(face = "bold", size = 28, hjust = 0, margin = margin(l = 55, b = 12)),
		plot.subtitle = element_markdown(size = 19, hjust = 0, margin = margin(l = 55, b = 23), color = "grey35"),
		panel.grid.major.x = element_line(linetype = 5, color = "grey83"),
		panel.grid.minor.x = element_blank(),
		panel.grid.major.y = element_blank(),
		panel.grid.minor.y = element_blank(),
		axis.title = element_blank(),
		axis.text.x = element_text(face = "bold", size = 18.5, color = "black", margin = margin(t = 15)),
		axis.text.y = element_blank(),
		plot.margin = margin(l = 0, r = 0, b = 20, t = 30),
	)
