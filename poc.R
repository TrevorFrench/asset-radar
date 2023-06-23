#CURRENTLY HAVE A TIME WEIGHTED AVERAGE, NEXT DO A VWAP

library(ggplot2)
library(dplyr)

df <- read.csv('pricing.csv')
data <- df[, c('id', 'start', 'o', 'h', 'l', 'c', 'v')]
data$start <- substr(data$start, 0, 10)
data$start <- as.Date(as.character(data$start), format = "%Y-%m-%d")
data <- data |> filter(id != 4587)

df2 <- cross_join(data, data)

df2 <- df2 %>%
  mutate(diff = difftime(start.y, start.x, units = "days")) %>%
  filter(diff >= 365)

df2 <- df2 |> 
  mutate("gain" = (h.y - l.x)/l.x) |> 
  mutate("loss" = (l.y - h.x)/h.x) |>
  mutate("avg_gl" = (((c.y + o.y)/2)-((c.x + o.x)/2))/((c.x + o.x)/2))

gain <- df2 |> filter(gain == max(df2$gain))
loss <- df2 |> filter(loss == min(df2$loss))

gain_proceeds <- gain[1, 'h.y']
gain_gains <- gain_proceeds - gain[1,'l.x']

loss_proceeds <- loss[1,'l.y']
loss_gains <- loss_proceeds - loss[1,'h.x']

lower_threshold <- quantile(df2$avg_gl, probs = c(.159))
lower_bound <- df2[which.min(abs(df2$avg_gl - lower_threshold)),]
lower_bound_proceeds <- (lower_bound[1,'c.y'] + lower_bound[1,'o.y']) / 2
lower_bound_gains <- lower_bound_proceeds - ((lower_bound[1,'c.x'] + lower_bound[1,'o.x'])/2)


upper_threshold <- quantile(df2$avg_gl, probs = c(.841))
upper_bound <- df2[which.min(abs(df2$avg_gl - upper_threshold)),]
upper_bound_proceeds <- (upper_bound[1,'c.y'] + upper_bound[1,'o.y']) / 2
upper_bound_gains <- upper_bound_proceeds - ((upper_bound[1,'c.x'] + upper_bound[1,'o.x'])/2)

run <- max(abs(loss_gains), abs(gain_gains))

x_range <- c(-run, run)
y_range <- c(0, run)

ggplot() +
  geom_abline(slope = 100, intercept = 0, color = "white", linetype = "dashed") +
  geom_abline(slope = lower_bound_proceeds/lower_bound_gains, intercept = 0, color = "pink", linetype = "solid", lwd = 1) +
  geom_abline(slope = upper_bound_proceeds/upper_bound_gains, intercept = 0, color = "yellow", linetype = "solid", lwd = 1) +
  geom_polygon(mapping=aes(x=c(0,lower_bound_gains/lower_bound_proceeds * run,upper_bound_gains/upper_bound_proceeds * run)
                           , y=c(0,run,run))) +
  geom_abline(slope = gain_proceeds/gain_gains, intercept = 0, color = "#00c805", linetype = "solid", lwd = 1) +
  geom_abline(slope = loss_proceeds/loss_gains, intercept = 0, color = "#ff5000", linetype = "solid", lwd = 1) +
  coord_cartesian(xlim = x_range, ylim = y_range, expand = 0) + 
  theme(
    panel.background = element_rect(fill = "black",
                                    colour = "black",
                                    size = 0.5, linetype = "solid"))