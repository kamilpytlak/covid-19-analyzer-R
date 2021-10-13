source("utils.R")


ui <- dashboardPage(
    # App title
    dashboardHeader(
        title = "COVID-19 Analyzer"
        ),
    
    # Sidebar (left)
    dashboardSidebar(
        sidebarMenu(id = "tabs", style = "position:fixed;width:220px;",
            menuItem("Information",
                     tabName = "info_tab",
                     icon = icon("info-circle")),
            menuItem("COVID-19 dataset",
                     tabName = "covid_dataset_tab",
                     icon = icon("table")),
            menuItem("R-estimation",
                     tabName = "r_calculator_tab",
                     icon = icon("calculator")),
            menuItem("Effectiveness of mask wearing",
                     tabName = "mask_tab",
                     icon = icon("head-side-mask")),
            menuItem("Hypothesis testing",
                     tabName = "hypotheses_tab",
                     icon = icon("question")),
            menuItem("COVID-19 plots",
                     tabName = "plots_tab",
                     icon = icon("chart-line")),
            
            # Wybór: kraj
            selectizeInput("country",
                        label = "COuntry",
                        choices = countries,
                        selected = "Poland",
                        multiple = TRUE,
                        options = list('plugins' = list('remove_button'),
                                       'create' = TRUE,
                                       'persist' = FALSE)),
            
            # Wybór: okres
            dateRangeInput("dates",
                           label = "Period",
                           min = min.date,
                           max = max.date,
                           start = min.date,
                           end = max.date,
                           language = "en"),
            
            # Wybór: skala logarytmiczna wykresów
            checkboxInput("log_scale",
                          label = "Logarithmic scale",
                          value = FALSE)
        )
        ),
    
    # Zawartość główna (po prawej)
    dashboardBody(
        useShinyFeedback(),
        tabItems(
            # Informacje
            tabItem(tabName = "info_tab",
                    withMathJax(includeMarkdown("covid-analyzer-info.md"))),
            
            # Zbiór danych COVID-19
            tabItem(tabName = "covid_dataset_tab",
                    reactableOutput("covid_dataset")),
            
            # Kalkulator R
            tabItem(tabName = "r_calculator_tab",
                    numericInput("mean_si", "Mean SI",
                                 value = 4.8, min = 0),
                    numericInput("std_si", "SD SI",
                                 value = 2.3, min = 0),
                    
                    actionButton("r_button", "Generate R(t) plot"),
                    
                    create.box(title = "R plot",
                              width = 50,
                              collapsed = FALSE,
                              plotlyOutput("r_plot")),
                    reactableOutput("r_summary")),
            
            # Efetywność noszenia masek
            tabItem(tabName = "mask_tab",
                    numericInput("R0", "R0",
                                value = 2.7, min = 0.1, max = 10.0),
                    
                    actionButton("heatplot_button", "Generate heat plot"),
                    
                    numericInput("mask_percent","% share of mask wearers
                                 in the population",
                                 value = 70, min = 0, max = 100),
                        
                    create.box(title = "Effectiveness of mask wearing",
                               width = 50,
                               collapsed = TRUE,
                               plotlyOutput("mask_heatplot")),
                        
                    create.box(title = "Effectiveness of different types
                               of masks as a function of baseline R
                               and the frequency of mask wearers in
                               the population",
                               width = 50,
                               collapsed = TRUE,
                               plotlyOutput("mask_plot")),
                    
                    actionButton("maskplot_button", "Generate plots")
                    ),
            
            
            # Testowanie hipotez
            tabItem(tabName = "hypotheses_tab",
                    create.box(title = "Hypothesis testing - information",
                               width = 50, collapsed = TRUE,
                               withMathJax(includeMarkdown("hypotheses-info.md"))),
                    selectInput("col",
                                label = "Factor",
                                choices = factors,
                                selected = "new_cases_per_milion"),
                    selectInput("hypothesis",
                                label = "Hypothesis",
                                choices = c("Left-tailed" = "less",
                                            "Two-tailed" = "two.sided",
                                            "Right-tailed" = "greater"),
                                selected = "two.sided"),
                    verbatimTextOutput("stat_test"),
                    
                    create.box(title = "Box plot",
                               width = 50, collapsed = TRUE,
                               plotlyOutput("stat_test_boxplot"))),
            
            
            # Wykresy
            tabItem(tabName = "plots_tab",
                    box(title = "Country/Countries summary",
                        width = 12,
                        status = "warning",
                        collapsible = FALSE,
                        solidHeader = TRUE),
                    
                    fluidRow(
                        create.box(title = "New infections",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_cases_plot")),
                        create.box(title = "Nowe zgony",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_deaths_plot"))
                        ),
                    
                    fluidRow(
                        create.box(title = "Infections (cumulated)",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("cases_cum_plot")),
                        
                        create.box(title = "Deaths (cumulated)",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("deaths_cum_plot"))
                        ),
                    
                    fluidRow(
                        create.box(title = "New infections (7-day moving
                                   average",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_cases_7da_plot")),
                        
                        create.box(title = "New deaths (7-day moving average)",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_deaths_7da_plot"))
                    ),
                    
                    box(title = "Country comparision",
                        width = 12,
                        collapsible = FALSE,
                        solidHeader = TRUE,
                        status = "warning"),
                    
                    fluidRow(
                        create.box(title = "New infections per 1 mln people
                                   (7-day moving average)",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_cases_smoothed_7da_plot")),
                        
                        create.box(title = "New deaths per 1 mln people
                                   (7-day moving average)",
                                   width = 6,
                                   collapsed = FALSE,
                                   plotlyOutput("new_deaths_smoothed_7da_plot"))
                    )
            )
            )
        )
)