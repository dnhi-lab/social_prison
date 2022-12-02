# Plot the PCL-R scores withouot individual data

setwd("C:/Users/kuper/Desktop/Psychopathy and economic games/Analysis")

# libraries 
library("readr")  
library('tidyr')    
library("dplyr")
library("ggplot2")
library("gghalves")

# load data
data_PCL <- read_table2("PCLR_4_R.txt")


# PREPROCESS DATA --------------------------------------------------------------------------------------

# make data frame
data_p <- data.frame(data_PCL)

# add subject number
sub_n <- length(data_p[,1])
subj <- 1:sub_n
data_p <- data.frame(subj, data_p)

# convert to long format
data_p <- data_p %>%
  pivot_longer(!subj, names_to = 'who', values_to = 'response')

# as factor for plotting
data_p$who <- factor(data_p$who) 

# change order of factor levels 
data_p$who <- factor(data_p$who, levels = c("overall","factor1","factor2"))

# colors 
color1 <- 'dodgerblue'

# positions 
x_box <- .15
x_vio <- -.15


# PLOT -------------------------------------------------------------------------------------------------



fig_p <- ggplot(data = data_p, aes(x = who, y = response)) +  
  # add darker grid line at y = 0
  geom_hline(yintercept = 0, color = 'gray55') +
  geom_point(position = position_jitter(width = 0.1, seed = '321'),
             size = 1.5, 
             color = color1,
             alpha = 0.6) +
  geom_half_boxplot(position = position_nudge(x = x_box),
                    side = "r",
                    outlier.shape = NA,
                    center = TRUE,
                    errorbar.draw = FALSE,
                    width = 0.2,
                    fill = color1,
                    alpha = 0.6) +
  geom_half_violin(position = position_nudge(x = x_vio),
                   fill = color1, 
                   alpha = 0.6,
                   scale = 'width')+
  # theme & labels 
  scale_x_discrete(labels=c("Overall", "Factor 1", "Factor 2")) +
  xlab("") +
  ylab("PCL-R Score") +
  theme_bw() +                                           
  theme(panel.grid.major.x = element_blank()) # remove vertical grid lines                                                                     

fig_p


