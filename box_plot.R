# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)
library(ggstatsplot)
library(MetBrewer)

# Load data from file 2023birthregistrations.xlsx from sheet "Table_9" and start read the data from the sixth row
# This is England and Wales data in 2023
imdStillBirth2023EW <- read_excel("2023birthregistrations.xlsx", sheet = "Table_9", skip = 5)

# Load data from file cim2022deathcohortworkbook.xlsx from sheet "21" and start read the data from the eight row
# This is England data from 2010 to 2022
imdStillBirth2022E <- read_excel("cim2022deathcohortworkbook.xlsx", sheet = "21", skip = 7)

# Load data from file cim2022deathcohortworkbook.xlsx from sheet "25" and start read the data from the tenth row
# This is Wales data from 2010 to 2022
imdStillBirth2022W <- read_excel("cim2022deathcohortworkbook.xlsx", sheet = "25", skip = 9)

# ======================================= Data Pre-Processing =======================================

# For table imdStillBirth2023EW, add column Year with value 2023
imdStillBirth2023EW <- imdStillBirth2023EW %>% mutate(Year = 2023)

# For table imdStillBirth2023EW, rename column IMD Decile to IMD
imdStillBirth2023EW <- imdStillBirth2023EW %>% rename(IMD = `IMD Decile`)

# Drop all columns besides Year, IMD and Stillbirths
imdStillBirth2023EW <- imdStillBirth2023EW %>% select(`Year`, `IMD`, Stillbirths)
imdStillBirth2022E <- imdStillBirth2022E %>% select(Year, IMD, Stillbirths)
imdStillBirth2022W <- imdStillBirth2022W %>% select(Year, IMD, Stillbirths)

# Merge the data from all three tables
imdStillBirth <- rbind(imdStillBirth2022E, imdStillBirth2022W, imdStillBirth2023EW)

# Remove rows with values "All deciles" or "Total" in column IMD
imdStillBirth <- imdStillBirth %>% filter(`IMD` != "All deciles" & `IMD` != "Total")

# Convert the data in column IMD to numeric class
imdStillBirth <- imdStillBirth %>% mutate(across(2, as.numeric))

# Sum the data based on column Year and IMD
imdStillBirth <- imdStillBirth %>%
	group_by(Year, IMD) %>%
	summarise(across(everything(), sum))

# ======================================= Data Visualisation =======================================

# Generate combination of box plot, violin plot and jitter plot
ggbetweenstats(
	data = imdStillBirth,
	x = IMD,
	y = Stillbirths,
	title = "Number of stillbirths by IMD decile",
	xlab = "Index of Multiple Deprivation",
	ylab = "Number of Stillbirths",
	package = "MetBrewer",
	palette = "Redon",
	type = "np",
	centrality.point.args = list(size = 0),
	point.args = list(
		position = position_jitterdodge(dodge.width = 0.7),
		alpha = 0.7,
		size = 3.5,
		stroke = 0
	),
	boxplot.args = list(
		width = 0.2,
		alpha = 0.3,
		fill = "grey85",
		colour = "black",
		linewidth = 0.7
	),
	violin.args = list(
		width = 0.67,
		alpha = 0.1,
		colour = "grey30",
		linetype = 5
	),
	partial = FALSE,
	results.subtitle = FALSE
) +
	geom_segment(
		data = imdStillBirth %>%
			group_by(IMD) %>%
			summarise(median = median(Stillbirths)),
		aes(
			x = IMD - 0.1,
			xend = IMD + 0.1,
			y = median,
			yend = median
		),
		colour = "#BF2F24",
		size = 1.3
	) +
	coord_cartesian(
		ylim = c(100, 670),
		xlim = c(1, 10.1)
	) +
	theme(
		panel.grid.major.x = element_line(color = "grey95"),
		panel.grid.major.y = element_line(color = "grey90"),
		panel.grid.minor.y = element_line(linetype = 3, color = "grey50"),
		plot.title = element_text(face = "bold", size = 30, hjust = 0.5, margin = margin(b = 20)),
		axis.title.x = element_text(size = 22, margin = margin(t = 20)),
		axis.text.x = element_text(face = "bold", size = 15),
		axis.title.y = element_text(size = 22, margin = margin(r = 20)),
		axis.text.y = element_text(face = "bold", size = 15),
		plot.margin = margin(l = 25, r = -8, b = 15, t = 25)
	)
