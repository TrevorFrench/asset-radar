library(ggplot2)
library(dplyr)

df <- read.csv('pricing.csv')
data <- df[, c('id', 'start', 'h', 'l', 'v')]
data$start <- substr(data$start, 0, 10)
data$start <- as.Date(as.character(data$start), format = "%Y-%m-%d")
data <- data |> filter(id != 4587)

df2 <- cross_join(data, data)

df2 <- df2 %>%
  mutate(diff = difftime(start.y, start.x, units = "days")) %>%
  filter(diff >= 365)

df2 <- df2 |> mutate("gain" = (h.y - l.x)/l.x)
df2 <- df2 |> mutate("loss" = (l.y - h.x)/h.x)

gain <- df2 |> filter(gain == max(df2$gain))
loss <- df2 |> filter(loss == min(df2$loss))

gain_gains <- gain[1,'h.y'] - gain[1,'l.x']
gain_proceeds <- gain[1, 'h.y']

loss_gains <- loss[1,'l.y'] - loss[1,'h.x']
loss_proceeds <- loss[1,'l.y']

run <- max(abs(loss_gains), abs(gain_gains))

x_range <- c(-run, run)
y_range <- c(0, run)

gain_points <- df2[,'h.y'] - df2[,'l.x']
loss_points <- df2[,'l.y'] - df2[,'h.x']

# Create the plot with no data points
ggplot() +
  # geom_abline(slope = 2, intercept = 0, color = "green", linetype = "solid") +
  geom_abline(slope = 100, intercept = 0, color = "white", linetype = "dashed") +
  # geom_abline(slope = mean(df2[,'h.y'])/mean(gain_points), intercept = 0, color = "#00c805", linetype = "dotted", lwd = 2) +
  # geom_abline(slope = (mean(df2[,'h.y'])-sd(df2[,'h.y']))/(mean(gain_points)-sd(gain_points)), intercept = 0, color = "#00c805", linetype = "dotted") +
  # geom_abline(slope = (mean(df2[,'h.y'])+sd(df2[,'h.y']))/(mean(gain_points)+sd(gain_points)), intercept = 0, color = "#00c805", linetype = "dotted") +
  # geom_abline(slope = mean(df2[,'l.y'])/mean(loss_points), intercept = 0, color = "#ff5000", linetype = "dotted", lwd = 2) +
  # geom_abline(slope = (mean(df2[,'l.y'])-sd(df2[,'l.y']))/(mean(loss_points)-sd(loss_points)), intercept = 0, color = "#ff5000", linetype = "dotted") +
  # geom_abline(slope = (mean(df2[,'l.y'])+sd(df2[,'l.y']))/(mean(loss_points)+sd(loss_points)), intercept = 0, color = "#ff5000", linetype = "dotted") +
  # geom_abline(slope = -2, intercept = 0, color = "red", linetype = "solid") +
  geom_abline(slope = gain_proceeds/gain_gains, intercept = 0, color = "#00c805", linetype = "solid", lwd = 1) +
  geom_abline(slope = loss_proceeds/loss_gains, intercept = 0, color = "#ff5000", linetype = "solid", lwd = 1) +
  coord_cartesian(xlim = x_range, ylim = y_range, expand = 0) + 
  theme(
    panel.background = element_rect(fill = "black",
                                    colour = "black",
                                    size = 0.5, linetype = "solid"))