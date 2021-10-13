# Functions
create.box <- function(title, width, collapsed, ...){
  box(title = title, status = "primary", solidHeader = TRUE, width = width,
      collapsible = TRUE, collapsed = collapsed, ...)
}

ggplot.nolog <- function(data, y, y.title){
  data %>%
    ggplot(aes(x = data$date, y = y, col = country)) +
    labs(x = "Data",
         y = y.title,
         col = "Kraj") +
    scale_y_continuous(labels = comma) +
    geom_line() +
    theme_bw()
}

ggplot.log <- function(data, y, y.title){
  data %>%
    ggplot(aes(x = data$date, y = y, col = country)) +
    labs(x = "Data",
         y = y.title,
         col = "Kraj") +
    scale_y_continuous(trans = "log10", labels = comma) +
    geom_line() +
    theme_bw()
}
