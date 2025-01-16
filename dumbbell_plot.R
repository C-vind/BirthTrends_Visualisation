# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)
library(ggtext)
library(patchwork)

# Load data from file 2023birthregistrations.xlsx from sheet "Table_10" and start read the data from the sixth row
maternalAge <- read_excel("2023birthregistrations.xlsx", sheet = "Table_10", skip = 5)

# ======================================= Data Pre-Processing =======================================

# Select rows where country is "England, Wales and Elsewhere" and parent is "Mother"
# and year is greater than or equal to "2004"
maternalAge <- maternalAge %>% filter(Country == "England, Wales and Elsewhere" &
	Parent == "Mother" &
	Year >= 2004)

# Drop the columns for country, parent and age-specific fertility rate
maternalAge <- maternalAge %>% select(-Country, -Parent, -`Age-specific fertility rate`)

# Update data type for column "Number of live births" to numeric
maternalAge <- maternalAge %>% mutate(across(3, as.numeric))

# Merge data for value "Under 20" and "20 to 24" and "25 to 29" to become "Under 30"
maternalAge <- maternalAge %>% mutate(`Age group (years)` =
	ifelse(`Age group (years)` %in% c("Under 20", "20 to 24", "25 to 29"), "Under 30", "30 and over"))

# Sum the data based on "Age group (years)" and "Year"
maternalAge <- maternalAge %>%
	group_by(Year, `Age group (years)`) %>%
	summarise(across(everything(), sum))

# Create new column "30 and over" and "Under 30" based on value in column "Number of live births"
maternalAgeFlip <- maternalAge %>%
	mutate(
		`30 and over` = ifelse(`Age group (years)` == "30 and over", `Number of live births`, 0),
		`Under 30` = ifelse(`Age group (years)` == "Under 30", `Number of live births`, 0)
	)

# Drop column "Age group (years)" and "Number of live births"
maternalAgeFlip <- maternalAgeFlip %>% select(-`Age group (years)`, -`Number of live births`)

# Merge 2 rows of data based on column "Year"
maternalAgeFlip <- maternalAgeFlip %>%
	group_by(Year) %>%
	summarise(across(everything(), sum))

# Create new column "Gap", to store the gap between the live birth counts of the two age groups in same year
maternalAge <- maternalAge %>%
	group_by(Year) %>%
	mutate(Gap = abs((sum(`Number of live births`) - 2 * `Number of live births`)))

# Create new column "Max", to store the maximum value of "Number of live births" for each year
maternalAge <- maternalAge %>%
	group_by(Year) %>%
	mutate(Max = max(`Number of live births`))

# Create new column "Gap", to store the gap between the live birth counts of the two age groups in same year
maternalAgeFlip <- maternalAgeFlip %>%
	mutate(Gap = `Under 30` - `30 and over`)

# Create new column "Max", to store the maximum value between column "Under 30" and column "30 and over" for each year
maternalAgeFlip <- maternalAgeFlip %>%
	mutate(Max = pmax(`Under 30`, `30 and over`))

# ======================================= Data Visualisation =======================================

# Visualise the dumbbell plot and store it to mainPlot variable
mainPlot <-
	maternalAge %>%
		ggplot(aes(x = `Number of live births`, y = Year)) +
		geom_line(aes(group = Year), color = "#E7E7E7", linewidth = 3.5) +
		geom_point(aes(color = `Age group (years)`), size = 8) +
		geom_text(
			aes(label = `Number of live births`),
			color = ifelse(
				maternalAge$`Age group (years)` == "30 and over",
				"#763181FF",
				"#025F79FF"
			),
			nudge_x = ifelse(
				maternalAge$`Number of live births` == maternalAge$Max,
				3000,
				-3000
			),
			hjust = ifelse(
				maternalAge$`Number of live births` == maternalAge$Max,
				0,
				1
			),
			fontface = "bold",
			size = 4.7
		) +
		scale_color_manual(values = c("#8f519a", "#1380A1")) +
		scale_y_reverse(breaks = seq(2004, 2023, 1)) +
		scale_x_continuous(
			limits = c(225000, 400000),
			breaks = seq(225000, 400000, 25000)
		) +
		coord_cartesian(
			xlim = c(230000, 383000),
			ylim = c(2023, 2004.5)
		) +
		labs(
			title = "Number of live births by age group of mothers",
			subtitle = "<b><span style='color:#025F79FF'>Blue dot</span></b> shows age group of <span
			style='color:black'><i>\"Under 30\"</i></span>. <b><span style='color:#763181FF'>Purple dot</span></b>
			shows age group of <span style='color:black'><i>\"30 and Over\"</i></span>.",
			x = "Number of Live Births",
			y = "Year"
		) +
		theme_minimal() +
		theme(
			legend.position = "none",
			panel.grid.major.x = element_line(color = "grey93"),
			panel.grid.minor.x = element_line(linetype = 2, color = "grey85"),
			panel.grid.major.y = element_line(color = "grey95"),
			panel.grid.minor.y = element_blank(),
			plot.title = element_text(face = "bold", size = 26, hjust = 0, margin = margin(b = 0)),
			plot.subtitle = element_markdown(size = 18, hjust = 0, margin = margin(b = 15), color = "grey35"),
			axis.title.x = element_text(size = 20, margin = margin(t = 15)),
			axis.text.x = element_text(face = "bold", size = 16),
			axis.title.y = element_text(size = 22, margin = margin(r = 15)),
			axis.text.y = element_text(face = "bold", size = 15),
			plot.margin = margin(l = 15, r = 0, b = 10, t = 25)
		)

# Visualise the gap between age groups and store it to gapPlot variable
gapPlot <-
	maternalAgeFlip %>%
		ggplot(aes(x = Gap, y = Year)) +
		geom_text(
			aes(
				x = 0,
				label = ifelse(Gap < 0, Gap, paste0("+", Gap))
			),
			color = ifelse(
				maternalAgeFlip$`Under 30` < maternalAgeFlip$`30 and over`,
				"#991300FF",
				"#097D5AFF"
			),
			fontface = "bold",
			size = 5
		) +
		labs(
			title = "Gap between age groups",
			subtitle = "<b>(<span style='color:#025F79FF'> #Younger </span><span style='color:#025F79FF'> Group
			</span> - <span style='color:#763181FF'> #Older </span><span style='color:#763181FF'> Group </span>)</b>",
		) +
		scale_y_reverse(breaks = seq(2004, 2023, 1)) +
		coord_cartesian(
			xlim = c(-.05, 0.05),
			ylim = c(2023, 2004.5)
		) +
		theme_minimal() +
		theme(
			legend.position = "none",
			plot.title = element_text(face = "bold", size = 18, hjust = 0.5, margin = margin(t = 7, b = 11)),
			plot.subtitle = element_markdown(size = 12, hjust = 0.5, margin = margin(b = 13), color = "black"),
			panel.grid.major.x = element_blank(),
			panel.grid.minor.x = element_blank(),
			panel.grid.minor.y = element_blank(),
			panel.grid.major.y = element_line(color = "grey93"),
			axis.text.y = element_blank(),
			axis.title.y = element_blank(),
			axis.text.x = element_blank(),
			axis.title.x = element_blank(),
			plot.margin = margin(l = 0, r = 0, b = 0, t = 0),
		)

# Generate the final chart by combining mainPlot (on the left) and gapPlot (on the right)
mainPlot +
	gapPlot +
	plot_layout(design =
		c(
			area(l = 0, r = 50, t = 0, b = 1), # defines the main figure area
			area(l = 51, r = 61, t = 0, b = 1)  # defines the gap figure area
		))
