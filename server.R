source("utils.R")


server <- function(input, output){
    
    covid.data <- reactive({
        req(input$country, input$dates)
        covid %>%
            filter(country %in% input$country,
                   between(dates, input$dates[1], input$dates[2])
            )
    })
    
    R.est <- reactive({
        req(input$country, input$dates, input$mean_si, input$std_si)
        estimate_R(covid.data()[, c("dates", "I")],
                   method = "parametric_si",
                   config = make_config(
                       list(
                           mean_si = input$mean_si,
                           std_si = input$std_si
                           )
                       ))
        })
    
    R.df <- reactive({
        R.df <- data.frame(country = character())
    })
    
    dep.var <- reactive({
        col <- select(covid.data(), input$col) %>%
            pull()
        
        col.equal <- (uniqueN(col, na.rm = TRUE) > 2)
        feedbackDanger("col", !col.equal, "All elements have the same value.")
        req(col.equal, cancelOutput = TRUE)
        col
    })
    
    indep.var <- reactive({
        col <- select(covid.data(), country) %>%
            pull()
        
        n.cnt <- length(unique(col))
        feedbackWarning("country", n.cnt < 2, "For hypothesis testing,
                        select 2 or more countries.")
        req(n.cnt >= 2, cancelOutput = TRUE)
        col
    })
    
    # COVID-19 dataset
    output$covid_dataset <- renderReactable({
        reactable(
            covid.data(),
            striped = TRUE,
            filterable = TRUE,
            showPageSizeOptions = TRUE
            )
        })
    
    # R-estimation
    output$r_plot <- renderPlotly({
        plot(R.est(), "R")
    })
    
    output$r_summary <- renderReactable({
        reactable(
            R.est()$R,
            filterable = TRUE
        )
    })
    
    # Effectiveness of mask wearing
    mask.eff.df <- reactive({
        m <- seq(1, 100, 1)
        p <- m
        mask.eff.df <- expand.grid(m = m,
                               p = p)
        mask.eff.df
    })
    
    R0 <- eventReactive(input$heatplot_button, {
        input$R0
    })
    
    pop.perc <- eventReactive(input$maskplot_button, {
        input$mask_percent
    })
    
    output$mask_heatplot <- renderPlotly({
        new_R0 <- (1 - mask.eff.df()$m/100 * mask.eff.df()$p/100)^2 * R0()
        
        p <- plot_ly(x = mask.eff.df()$m,
                     y = mask.eff.df()$p,
                     z = new_R0,
                     type = "contour",
                     reversescale = TRUE,
                     contours = list(showlabels = TRUE,
                                     labelfont = list(size = 18, color = "red"),
                                     start = 0,
                                     end = R0(),
                                     size = 0.25))
        p
    })
    
    mask.kind.df <- reactive({
        data.frame(kind = c("Cotton", "Cotton-flannel",
                            "Cotton-silk", "Cotton-chiffon",
                            "Surgical", "Flannel", "Silk", "N95",
                            "Chiffon"),
                   filtr_eff = c(80, 95, 94, 97, 75, 57, 58, 85, 67))
    })
    
    output$mask_plot <- renderPlotly({
        mask.newR0.df <- covid.data() %>%
            select(dates, reproduction_rate)
        
        for(i in 3:nrow(mask.kind.df())){
            filtr.eff <- mask.kind.df()$filtr_eff[i]
            new.col <- paste0(mask.kind.df()$kind[i], " ", filtr.eff,
                              "% effectiveness")
            mask.newR0.df[[new.col]] <- (1 - filtr.eff/100 * pop.perc()/100)^2 * mask.newR0.df$reproduction_rate
        }
        
        mask.newR0.df <- mask.newR0.df %>%
            pivot_longer(cols = -c(dates, reproduction_rate),
                         names_to = "mask_kind",
                         values_to = "new_R0") %>%
            drop_na(reproduction_rate)

        p <- ggplot(mask.newR0.df, aes(x = dates, y = new_R0)) +
            geom_line(color = "blue") +
            geom_line(aes(y = reproduction_rate), color = "red") +
            facet_wrap(~mask_kind) +
            geom_hline(yintercept = 1, linetype = "dashed",
                       size = 0.3) + theme_bw()

        ggplotly(p)
    })
    
    # Hypotheses testing
    output$stat_test <- renderPrint({
        n.grps <- length(unique(indep.var()))
        feedbackWarning("hypothesis", n.grps > 2, "When comparing more than 2
                        groups (ANOVA/Kruskal-Wallis), the two-sided
                        hypothesis is verified.")
        
        if (n.grps >= 2) {
            normality.table <- aggregate(formula = dep.var() ~ indep.var(),
                                         data = covid.data(),
                                         FUN = function(x){
                                             st <- shapiro.test(x)
                                             c(st$p.value)
                                             })
            var.check <- ifelse(bartlett.test(dep.var() ~ indep.var())$p.value > 0.05,
                                TRUE, FALSE)
        }
        if (n.grps == 2) {
            if (min(normality.table$dep.var) < 0.05) {
                wilcox.test(dep.var() ~ indep.var(), alternative = input$hypothesis,
                            na.action = "na.pass")
            }
            else if (var.check == FALSE) {
                t.test(dep.var() ~ indep.var(), alternative = input$hypothesis,
                       var.equal = FALSE, na.action = "na.pass")
            }
            else {
                t.test(dep.var() ~ indep.var(), alternative = input$hypothesis,
                       var.equal = TRUE, na.action = "na.pass")
            }
        }
            else if (n.grps > 2) {
            if (min(normality.table$dep.var) < 0.05 & var.check == FALSE) {
                covid.kruskal <- kruskal.test(dep.var() ~ indep.var())
                
                if (covid.kruskal$p.value < 0.05) {
                    covid.dunntest <- dunnTest(dep.var() ~ indep.var())
                    list(Kruskal.Wallis.test = covid.kruskal,
                         Dunnett.Test = covid.dunntest)
                }
                else {
                    covid.kruskal
                }
            }
            else {
                covid.anova <- aov(dep.var() ~ indep.var())
                if (summary(covid.anova)[[1]][[1, "Pr(>F)"]] < 0.05) {
                    covid.tukey <- TukeyHSD(covid.anova)
                    list(ANOVA = summary(covid.anova),
                         Tukey.Test = covid.tukey)
                }
            }
        }
    })
    
    # Hypotheses testing - boxplot
    output$stat_test_boxplot <- renderPlotly({
        covid.data() %>%
            plot_ly(y = ~dep.var(), color = ~indep.var(), type = "box")
    })
    
    # COVID-19 plots
    
    # New cases
    output$new_cases_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(), y = covid.data()$I,
                         y.title = "Number of new infections")
            }
        else{
            ggplot.log(data = covid.data(), y = covid.data()$I,
                       y.title = "Number of new infections")
            }
        })
        
    # New deaths
    output$new_deaths_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(), y = covid.data()$new_deaths,
                         y.title = "Number of new deaths")
        }
        else {
            ggplot.log(data = covid.data(), y = covid.data()$new_deaths,
                       y.title = "Number of new deaths")
        }
        })
    
    # Cases (cumulated)
    output$cases_cum_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(), y = covid.data()$total_cases,
                         y.title = "Cumulated number of new infections")
        }
        else {
            ggplot.log(data = covid.data(), y = covid.data()$total_cases,
                       y.title = "Cumulated number of new infections")
        }
        })
    
    # Deaths (cumulated)
    output$deaths_cum_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(), y = covid.data()$total_deaths,
                         y.title = "Cumulated number of new deaths")
        }
        else{
            ggplot.log(data = covid.data(), y = covid.data()$total_deaths,
                       y.title = "Cumulated number of new deaths")
        }
    })
    
    # New cases (7-day moving average)
    output$new_cases_7da_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(),
                         y = covid.data()$new_cases_smoothed,
                         y.title = "Number of new infections")
        }
        else {
            ggplot.log(data = covid.data(),
                       y = covid.data()$new_cases_smoothed,
                       y.title = "Number of new infections")
        }
    })
    
    # New deaths (7-day moving average)
    output$new_deaths_7da_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(),
                         y = covid.data()$new_deaths_smoothed,
                         y.title = "Number of new deaths")
        }
        else {
            ggplot.log(data = covid.data(),
                       y = covid.data()$new_deaths_smoothed,
                       y.title = "Number of new deaths")
        }
    })
    
    # New cases per 1 mln (7-day moving average)
    output$new_cases_smoothed_7da_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(),
                         y = covid.data()$new_cases_smoothed_per_million,
                         y.title = "Number of new infections")
        }
        else {
            ggplot.log(data = covid.data(),
                       y = covid.data()$new_cases_smoothed_per_million,
                       y.title = "Number of new infections")
        }
    })
    
    # New deaths per 1 mln (7-day moving average)
    output$new_deaths_smoothed_7da_plot <- renderPlotly({
        if (input$log_scale == FALSE) {
            ggplot.nolog(data = covid.data(),
                         y = covid.data()$new_deaths_smoothed_per_million,
                         y.title = "Number of new deaths")
        }
        else {
            ggplot.log(data = covid.data(),
                       y = covid.data()$new_deaths_smoothed_per_million,
                       y.title = "Number of new deaths")
        }
    })
}
