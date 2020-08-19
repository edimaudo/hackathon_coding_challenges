#otf analysis
rm(list = ls())
#packages
packages <-
    c(
        'ggplot2',
        'corrplot',
        'tidyverse',
        'shiny',
        'shinydashboard',
        'SnowballC',
        'wordcloud',
        'dplyr',
        'tidytext',
        'readxl',
        'DT',
        'scales',
        'tm',
        'xgboost',
        'caret',
        'dummies',
        'mlbench',
        'tidyr',
        'Matrix',
        'data.table',
        'vtreat', 
        'rsample'
    )
#load packages
for (package in packages) {
    if (!require(package, character.only = T, quietly = T)) {
        install.packages(package)
        library(package, character.only = T)
    }
}

CatchupPause <- function(Secs){
    Sys.sleep(Secs) #pause to let connection work
    #closeAllConnections()
    #gc()
}

#load data
df <- read_excel("otf.xlsx")

df$year_update <- as.integer(df$year_update)
yearInfo <- length(unique(df$year_update))
grantInfo <- length(unique(df$grant_program))
organizationInfo <- length(unique(df$organization_name))
amountAwardedInfo <-
    formatC(
        sum(df$amount_awarded),
        format = "f",
        big.mark = ",",
        digits = 0
    )
ageGroupInfo <- length(unique(df$age_group_update))
budgetInfo <- length(unique(df$budget_fund_update))
cityInfo <- length(unique(df$receipient_org_city_update))
yearSliderInput <-
    sort(as.vector(unique(as.integer(df$year_update))))
yearData = as.array(yearSliderInput)
grantSliderInput <- sort(as.vector(unique(df$grant_program)))
grantData = as.array(grantSliderInput)
programSliderInput <- sort(as.vector(unique(df$program_area)))
programData = as.array(programSliderInput)
ageGroupInfo1 <- sort(as.vector(unique(df$age_group_update)))
populationServedInfo <-
    sort(as.vector(unique(df$population_served_update)))
geoAreaInfo <-
    sort(as.vector(unique(df$geographical_area_served_update)))
budgetFundInfo <- sort(as.vector(unique(df$budget_fund_update)))

df$organization_name <- as.character(df$organization_name)
organizationInfo1 <- sort(unique(df$organization_name))


generate_prediction <- function(df){
    #data prep
    set.seed(123)
    split <- initial_split(df, prop = .7)
    train <- training(split)
    test  <- testing(split)
    
    # variable names
    features <- setdiff(names(train), c('year_update',"amount_awarded"))
    
    # Create the treatment plan from the training data
    treatplan <- vtreat::designTreatmentsZ(train, features, verbose = FALSE)
    
    # Get the "clean" variable names from the scoreFrame
    new_vars <- treatplan %>%
        magrittr::use_series(scoreFrame) %>%        
        dplyr::filter(code %in% c("clean", "lev")) %>% 
        magrittr::use_series(varName) 
    
    # Prepare the training data
    features_train <- vtreat::prepare(treatplan, train, varRestriction = new_vars) %>% 
        as.matrix()
    response_train <- train$amount_awarded
    
    # Prepare the test data
    features_test <- vtreat::prepare(treatplan, test, 
                                     varRestriction = new_vars) %>% as.matrix()
    response_test <- test$amount_awarded
    
    # parameter list
    params <- list(
        eta = 0.01,
        max_depth = 5,
        min_child_weight = 5,
        subsample = 0.65,
        colsample_bytree = 1
    )
    
    # train final model
    xgb.fit.final <- xgboost(
        params = params,
        data = features_train,
        label = response_train,
        nrounds = 100,
        objective = "reg:linear",
        verbose = 0,
        early_stopping_rounds = 10 
    )
    pred <- predict(xgb.fit.final, features_test)
    
    return (mean(pred))
}

#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Foundation"),
    #add image
    dashboardSidebar(
        sidebarMenu(
            menuItem(
                "Introduction",
                tabName = "Introduction",
                icon = icon("dashboard")
            ),
            menuItem("Summary", tabName = "Summary", icon = icon("th")),
            menuItem("Yearly Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Word Cloud", tabName = "WordCloud", icon = icon("th")),
            menuItem("OTF Search tool", tabName = "OTFSearch", icon = icon("th")),
            menuItem("OTF Grant Estimator",
                     tabName = "OTFGrantEstimator",icon = icon("th")
            )
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction", 
                    includeMarkdown("readme.md"), hr()),
            tabItem(
                tabName = "Summary",
                fluidRow(infoBoxOutput("yearInfo"),
                         infoBoxOutput("grantInfo")),
                fluidRow(
                    infoBoxOutput("organizationalInfo"),
                    infoBoxOutput("amountAwardedInfo")
                ),
                fluidRow(infoBoxOutput("areaInfo"),
                         infoBoxOutput("budgetInfo"))
            ),
            tabItem(tabName = "Trends",
                    sidebarLayout(
                        sidebarPanel(
                            sliderInput(
                                "Years",
                                "Years:",
                                min = 1999,
                                max = 2019,
                                value = yearSliderInput,
                                step = 1,
                                ticks = TRUE,
                                sep = ""
                            ),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Grants and Amount Awarded", 
                                   style = "text-align: center;"),
                                plotOutput("grantAwarded")
                            ),
                            fluidRow(
                                h2("Budget areas and Amount Awarded", 
                                   style = "text-align: center;"),
                                plotOutput("budgetAwarded")
                            ),
                            fluidRow(
                                h2("Program areas and Amount Awarded", 
                                   style = "text-align: center;"),
                                plotOutput("programAwarded")
                            ),
                            fluidRow(
                                h2("Population Served and Amount Awarded", 
                                   style = "text-align: center;"),
                                plotOutput("populationServed")
                            ),
                            fluidRow(
                                h2("Age Served and Amount Awarded", 
                                   style = "text-align: center;"),
                                plotOutput("ageServed")
                            ),
                            fluidRow(
                                h2("Amount Awarded", style = "text-align: center;"),
                                plotOutput("yearAmount")
                            )
                        )
                    )),
            tabItem(tabName = "TextMining",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year:", choices = yearData),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(fluidRow(
                            h2("Text mining insights", style = "text-align: center;"),
                            plotOutput("generateProgramSentiment")
                        ))
                    )),
            tabItem(tabName = "WordCloud",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year:", choices = yearData),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                            h2("English Descrption Word cloud", 
                               style = "text-align: center;"),
                            plotOutput("generateWordCloud")
                            ),
                            fluidRow(
                                h2("Organization Word cloud", 
                                   style = "text-align: center;"),
                                plotOutput("generateWordCloudorg")
                            )
                        )
                    )),   
            tabItem(tabName = "OTFSearch",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year", choices = yearData),
                            selectInput("budgetFundInput", "Stream", choices =
                                            budgetFundInfo),
                            selectInput("areaInput", "Area", choices = geoAreaInfo),
                            # selectInput("populationInput", 
                            #"Population Served", choices =
                            #                 populationServedInfo),
                            # selectInput("ageInput", "Age Group", choices =
                            #                 ageGroupInfo1),
                            # selectInput("programInput", "Program Area", choices =
                            #                 programSliderInput),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(fluidRow(
                            h2("Grant Information", style = "text-align: center;"),
                            DT::dataTableOutput("searchOTF")
                        ))
                    )),
            tabItem(tabName = "OTFGrantEstimator",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("organizationInput", "Organization", 
                                        choices = organizationInfo1),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(fluidRow(
                            h2("Estimated Grant in CAD", 
                               style = "text-align: center;"),
                            DT::dataTableOutput("estimatorOTF")
                        ))
                    ))
        )
    )
)


server <- function(input, output, session) {
    # of years
    output$yearInfo <- renderInfoBox({
        infoBox("# of Years",
                paste0(yearInfo),
                icon = icon("list"),
                color = "blue")
    })
    
    # grant information
    output$grantInfo <- renderInfoBox({
        infoBox(
            "Grant Types",
            paste0(grantInfo),
            icon = icon("list"),
            color = "blue",
            fill = TRUE
        )
    })
    
    # of organizations
    output$organizationalInfo <- renderInfoBox({
        infoBox(
            "# of Organizations",
            paste0(organizationInfo),
            icon = icon("list"),
            color = "blue"
        )
    })
    
    # dollar amount
    output$amountAwardedInfo <- renderInfoBox({
        infoBox(
            "Grants awarded",
            paste0(amountAwardedInfo, " CAD"),
            icon = icon("list"),
            color = "blue",
            fill = TRUE
        )
    })
    
    #types of budget
    output$budgetInfo <- renderInfoBox({
        infoBox(
            "Budget Types",
            paste0(budgetInfo),
            icon = icon("list"),
            color = "blue",
            fill = TRUE
        )
    })
    
    # of cities for summary page
    output$areaInfo <- renderInfoBox({
        infoBox(
            "# of Grant areas",
            paste0(cityInfo),
            icon = icon("list"),
            color = "blue"
        )
    })
    
    #visualizations
    #grants
    output$grantAwarded <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearAwardedGrantProgram <- data %>%
            dplyr::group_by(year_update, grant_program) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        
        ggplot(data = yearAwardedGrantProgram,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
                   fill = grant_program
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)",
                 fill  = "Grant Programs") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    #budget fund
    output$budgetAwarded <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearAwardedBudget <- data %>%
            dplyr::group_by(year_update, budget_fund_update) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        
        ggplot(data = yearAwardedBudget,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
                   fill = budget_fund_update
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)",
                 fill  = "Budget funds") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    #programs
    output$programAwarded <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearAwardedProgram <- data %>%
            dplyr::group_by(year_update, program_area) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        ggplot(data = yearAwardedProgram,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
                   fill = program_area
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)",
                 fill  = "Program Areas") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    #population served update
    output$populationServed <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearPopulationServed <- data %>%
            dplyr::group_by(year_update, population_served_update) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        ggplot(data = yearPopulationServed,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
                   fill = population_served_update
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)",
                 fill  = "Population Served") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    
    #age group served update
    output$ageServed <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearAgeServed <- data %>%
            dplyr::group_by(year_update, age_group_update) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        ggplot(data = yearAgeServed,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
                   fill = age_group_update
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)",
                 fill  = "Age Served") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    #year vs amount
    output$yearAmount <- renderPlot({
        data <-
            df[df$year_update >= input$Years[[1]] &
                   df$year_update <= input$Years[[2]], ]
        
        yearAmt <- data %>%
            dplyr::group_by(year_update) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        ggplot(data = yearAmt,
               aes(
                   x = as.factor(year_update),
                   y = total_awarded,
               )) +
            geom_bar(stat = "identity", width = 0.4) + theme_classic() +
            labs(x = "Years",
                 y = "Amount awarded (CAD)") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 10),
                axis.title = element_text(size = 15),
                axis.text = element_text(size = 10),
                axis.text.x = element_text(angle = 45, hjust = 1)
            )
    })
    
    
    output$generateWordCloud <- renderPlot({
        wordcloudData <- df %>%
            dplyr::filter(year_update == input$yearInput) %>%
            dplyr::select(english_description)
        
        docs <-
            Corpus(VectorSource(wordcloudData$english_description))
        
        toSpace <-
            content_transformer(function (x , pattern)
                gsub(pattern, " ", x))
        docs <- tm_map(docs, toSpace, "/")
        docs <- tm_map(docs, toSpace, "@")
        docs <- tm_map(docs, toSpace, "\\|")
        
        # Convert the text to lower case
        docs <- tm_map(docs, content_transformer(tolower))
        # Remove numbers
        docs <- tm_map(docs, removeNumbers)
        # Remove english common stopwords
        docs <- tm_map(docs, removeWords, stopwords("english"))
        # Remove your own stop word
        # specify your stopwords as a character vector
        docs <- tm_map(docs, removeWords, c("blabla1", "blabla2"))
        # Remove punctuations
        docs <- tm_map(docs, removePunctuation)
        # Eliminate extra white spaces
        docs <- tm_map(docs, stripWhitespace)
        
        dtm <- TermDocumentMatrix(docs)
        m <- as.matrix(dtm)
        v <- sort(rowSums(m), decreasing = TRUE)
        d <- data.frame(word = names(v), freq = v)
        head(d, 10)
        
        set.seed(1234)
        wordcloud(
            words = d$word,
            freq = d$freq,
            min.freq = 1,
            max.words = 100,
            random.order = FALSE,
            rot.per = 0.35,
            colors = brewer.pal(8, "Dark2")
        )
        
    })

    #word cloud by Org name
    output$generateWordCloudorg <- renderPlot({
        wordcloudData <- df %>%
            dplyr::filter(year_update == input$yearInput) %>%
            dplyr::select(organization_name)
        
        docs <-
            Corpus(VectorSource(wordcloudData$organization_name))
        
        toSpace <-
            content_transformer(function (x , pattern)
                gsub(pattern, " ", x))
        docs <- tm_map(docs, toSpace, "/")
        docs <- tm_map(docs, toSpace, "@")
        docs <- tm_map(docs, toSpace, "\\|")
        
        # Convert the text to lower case
        docs <- tm_map(docs, content_transformer(tolower))
        # Remove numbers
        docs <- tm_map(docs, removeNumbers)
        # Remove english common stopwords
        docs <- tm_map(docs, removeWords, stopwords("english"))
        # Remove your own stop word
        # specify your stopwords as a character vector
        docs <- tm_map(docs, removeWords, c("blabla1", "blabla2"))
        # Remove punctuations
        docs <- tm_map(docs, removePunctuation)
        # Eliminate extra white spaces
        docs <- tm_map(docs, stripWhitespace)
        
        dtm <- TermDocumentMatrix(docs)
        m <- as.matrix(dtm)
        v <- sort(rowSums(m), decreasing = TRUE)
        d <- data.frame(word = names(v), freq = v)
        head(d, 10)
        
        set.seed(1234)
        wordcloud(
            words = d$word,
            freq = d$freq,
            min.freq = 1,
            max.words = 100,
            random.order = FALSE,
            rot.per = 0.35,
            colors = brewer.pal(8, "Dark2")
        )
        
    })
    
    
    #search
    output$searchOTF <- DT::renderDataTable(DT::datatable({
        
        data <- df %>%
            filter(year_update == input$yearInput) %>%
            filter(budget_fund_update == input$budgetFundInput) %>%
            filter(geographical_area_served_update == input$areaInput) %>%
            select(organization_name, amount_awarded, program_area, 
                   recipient_org_city, age_group, 
                   geographical_area_served_update, budget_fund, population_served)
    }))
    
    #prediction model
    output$estimatorOTF <- DT::renderDataTable({
        df1 <- df %>%
            filter(organization_name == input$organizationInput) 
        
        df2 <- df1 %>%
            select(program_area, budget_fund_update, 
                   geographical_area_served_update, receipient_org_city_update,
                   population_served_update, age_group_update, year_update, amount_awarded)
        
        CatchupPause(150)
        output <- generate_prediction(df2)
        CatchupPause(150)
        output <- data.frame(output)
        DT::datatable(output)
    }
    )
    
    
    
    
}

shinyApp(ui, server)