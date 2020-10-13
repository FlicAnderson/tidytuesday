# From: https://github.com/edinkasia/tidytuesday/blob/master/datasaurus.R on 13th Oct 2020

#install.packages("ggstatsplot")
#install.packages("remotes")
#library(psych)  # allegedly this package doesn't exist for R 4.0.2?? (I think this is lies)
#library(ggstatsplot)

library(tidyverse)
library(RColorBrewer)


# remotes::install_github(
#   repo = "IndrajeetPatil/ggstatsplot", # package path on GitHub
#   dependencies = TRUE, # installs packages which ggstatsplot depends on
#   upgrade_dependencies = TRUE # updates any out of date dependencies
# )

datasaurus <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-10-13/datasaurus.csv')

# > str(datasaurus)
# tibble [1,846 × 3] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
# $ dataset: chr [1:1846] "dino" "dino" "dino" "dino" ...
# $ x      : num [1:1846] 55.4 51.5 46.2 42.8 40.8 ...
# $ y      : num [1:1846] 97.2 96 94.5 91.4 88.3 ...
# - attr(*, "spec")=
#   .. cols(
#     ..   dataset = col_character(),
#     ..   x = col_double(),
#     ..   y = col_double()
#     .. )


# Starting code snippet provided by Tidy Tuesday
facet_plot <- ggplot(datasaurus, aes(x=x, y=y, colour=dataset))+
  geom_point()+
  theme_void()+
  theme(legend.position = "none")+
  facet_wrap(~dataset, ncol=3)

facet_plot
# each of these data have same mean and SD, but each look very different when you plot them. 

# CHANGE COLOURS

# The colours are ugly, can we change them?
# The Brewer palettes are usually better, but they only have 8-12 colours

display.brewer.all()

# The plot will be generated, but parts will be missing (only 8 plots here):

facet_brewer <- ggplot(datasaurus, aes(x=x, y=y, colour=dataset))+
  geom_point()+
  theme_void()+
  theme(legend.position = "none")+
  facet_wrap(~dataset, ncol=3) +
  scale_color_brewer(palette = "Set1")

facet_brewer

# this doesn't show some plots because that set of colours Set1 only has 9 colours, our data has 12 plots (length(datasaurus$dataset))

# Can we get more colours from Brewer?
# Yes: https://www.r-bloggers.com/2013/09/how-to-expand-color-palette-with-ggplot-and-rcolorbrewer/

colourCount = length(unique(datasaurus$dataset)) #this tells us how many colours we need
getPalette = RColorBrewer::colorRampPalette(brewer.pal(9, "Set1")) #this returns a function (that takes an integer argument)!
 # so getPalette is a function that takes a palette & a number to stretch it into.

facet_brewer_13 <- ggplot(datasaurus, aes(x=x, y=y, colour=dataset))+
  geom_point()+
  theme_void()+
  theme(legend.position = "none")+
  facet_wrap(~dataset, ncol=3) +
  scale_colour_manual(values = getPalette(colourCount)) 

facet_brewer_13

# Challenge - try it with different palettes


# Challenge - could we get R to display the name of the colour together with the name of the dataset?


# Let's try something different - can we get two plots on top of one another?


datasaurus %>% 
  filter(dataset %in% c("circle", "slant_up")) %>% 
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()

datasaurus %>% 
  filter(dataset %in% c("circle", "slant_up")) %>% 
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point() +
  theme(legend.position = "none")

datasaurus %>% 
  filter(dataset %in% c("circle", "slant_up")) %>% 
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point() +
  theme(legend.position = "none") +
  scale_color_brewer(palette = "Paired")

# Challenge - how would we define the colours exactly?

# We can look at the data descriptive using the describeBy function from the psych package

#psyche::describeBy(datasaurus, group = "dataset")

# Tidyverse alternative - group_by?

datasaurus %>%
  filter(dataset %in% c("circle", "slant_up")) %>%
  group_by(dataset) %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()




# Additional examples from Twitter:
# https://github.com/jack-davison/TidyTuesday

# {gganimate} - really slow, but cool apparently?
# 


# PATCHWORK

# Kasia also mentioned this: https://patchwork.data-imaginist.com/
# {patchwork}
install.packages("patchwork")
library(patchwork)
# Just FYI: it doesnt play with cowplot if cowplot was loaded first
# Attaching package: ‘patchwork’
# 
# The following object is masked from ‘package:cowplot’:
#   
#   align_plots

# create some individual plots to play with by filtering datasets 
plot_circle <- 
  datasaurus %>%
  filter(dataset == "circle") %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()

plot_away <- 
datasaurus %>%
  filter(dataset == "away") %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()

plot_dino <- 
  datasaurus %>%
  filter(dataset == "dino") %>%
  group_by(dataset) %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()

plot_star <- 
  datasaurus %>%
  filter(dataset == "star") %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point()


# basic "side by side 2 plots"
plot_set <- plot_circle + plot_dino
plot_set

# plot a 2 x 2 grid 
plot_set <- (plot_circle|plot_away)/(plot_dino|plot_star)
plot_set

# plot a 1:2:1 grid 
plot_set <- plot_circle|plot_away/plot_dino|plot_star
plot_set


# I keep hearing about {cowplot}
#https://cran.r-project.org/web/packages/cowplot/vignettes/introduction.html

install.packages("cowplot")
library(cowplot)

# 'classic' cowplot 
datasaurus %>%
  filter(dataset %in% c("circle", "slant_up")) %>%
  group_by(dataset) %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point() + 
  theme_cowplot(12)  # I'm not sure which argument this '12' actually refers to?

# 'minimal grid' cowplot 
datasaurus %>%
  filter(dataset %in% c("circle", "star")) %>%
  group_by(dataset) %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point() + 
  theme_minimal_grid(12) 

# save this out to .pdf
# 'minimal grid' cowplot 
testplot <- datasaurus %>%
  filter(dataset %in% c("circle", "star")) %>%
  group_by(dataset) %>%
  ggplot(aes(x=x, y=y, colour=dataset)) + 
  geom_point() + 
  theme_minimal_grid(12) 

ggsave(testplot, filename="/home/fanders6/tidytuesday/data/2020/2020-10-13/starcircle_cowplot_minimal.pdf", device="pdf")

