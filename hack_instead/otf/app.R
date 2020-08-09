#otf analysis
rm(list = ls())
#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny','shinydashboard',
              'SnowballC','wordcloud','dplyr','tidytext','readxl','DT',
              'scales','tm')
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#load data
df <- read_excel("otf.xlsx")

#df$year_update <- as.integer(df$year_update)
yearInfo <- length(unique(df$year_update))
grantInfo <- length(unique(df$grant_program))
organizationInfo <- length(unique(df$organization_name))
amountAwardedInfo <- formatC(sum(df$amount_awarded), format="f", big.mark=",", digits=1) 
ageGroupInfo <- length(unique(df$age_group_update))
budgetInfo <- length(unique(df$budget_fund_update))
cityInfo <- length(unique(df$receipient_org_city_update))
yearSliderInput <- sort(as.vector(unique(as.integer(df$year_update))))
yearData = as.array(yearSliderInput)
grantSliderInput <- sort(as.vector(unique(df$grant_program)))
grantData = as.array(grantSliderInput)
programSliderInput <- sort(as.vector(unique(df$program_area)))
programData = as.array(programSliderInput)
ageGroupInfo1 <- sort(as.vector(unique(df$age_group_update)))
populationServedInfo <- sort(as.vector(unique(df$population_served_update)))
geoAreaInfo <- sort(as.vector(unique(df$geographical_area_served_update)))
budgetFundInfo <- sort(as.vector(unique(df$budget_fund_update)))

#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Foundation"),
    #add image
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Summary", tabName = "Summary", icon = icon("th")),
            menuItem("Yearly Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Text Mining", tabName = "TextMining", icon = icon("th")), #text minings
            menuItem("Word Cloud", tabName = "WordCloud", icon = icon("th")),
            menuItem("OTF Search tool", tabName = "OTFSearch", icon = icon("th")),
            menuItem("OTF Grant Estimator", tabName = "OTFGrantEstimator", icon = icon("th"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",includeMarkdown("readme.md"),hr()),
            tabItem(tabName = "Summary",
                    fluidRow(
                        infoBoxOutput("yearInfo"),
                        infoBoxOutput("grantInfo")
                    ),
                    fluidRow(
                        infoBoxOutput("organizationalInfo"),
                        infoBoxOutput("amountAwardedInfo")
                    ), 
                    fluidRow(
                        infoBoxOutput("areaInfo"),
                        infoBoxOutput("budgetInfo")
                    )
            ),
            tabItem(tabName = "Trends",
                    sidebarLayout(
                        sidebarPanel(
                            sliderInput("Years", "Years:", min = 1999, max = 2019, 
                                        value = yearSliderInput, step=1, ticks = TRUE, sep=""),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Grants and Amount Awarded",style="text-align: center;"),
                                plotOutput("grantAwarded")
                            ),
                            fluidRow(
                                h2("Budget areas and Amount Awarded",style="text-align: center;"),
                                plotOutput("budgetAwarded")
                            ), 
                            fluidRow(
                                h2("Program areas and Amount Awarded",style="text-align: center;"),
                                plotOutput("programAwarded")
                            )
                        )
                    )
            ),
            tabItem(tabName = "TextMining",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year:",choices=yearData),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Text mining insights",style="text-align: center;"),
                            )
                        )
                    )
                    
            ),
            tabItem(tabName = "WordCloud",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year:",choices=yearData),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("English Descrption Word cloud",style="text-align: center;"),
                                plotOutput("generateWordCloud")
                            )
                        )
                    )
                    
            ),
            tabItem(tabName = "OTFSearch",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year",choices=yearData),
                            selectInput("budgetFundInput", "Stream",choices=budgetFundInfo),#sbudget fund
                            selectInput("areaInput", "Area",choices=geoAreaInfo),#geographical area served
                            selectInput("populationInput", "Population Served",choices=populationServedInfo),#population
                            selectInput("ageInput", "Age Group",choices=ageGroupInfo1),#age group
                            selectInput("programInput", "Program Area",choices=programSliderInput),#program area
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Grant Information",style="text-align: center;"),
                                DT::dataTableOutput("searchOTF")
                            )
                        )
                    )
                    
            ),
            tabItem(tabName = "OTFGrantEstimator",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year",choices=yearData),
                            selectInput("budgetFundInput", "Stream",choices=budgetFundInfo),#sbudget fund
                            selectInput("areaInput", "Area",choices=geoAreaInfo),#geographical area served
                            selectInput("populationInput", "Population Served",choices=populationServedInfo),#population
                            selectInput("ageInput", "Age Group",choices=ageGroupInfo1),#age group
                            selectInput("programInput", "Program Area",choices=programSliderInput),#program area
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Estimated Grant in CAD",style="text-align: center;"),
                                DT::dataTableOutput("estimator")
                            )
                        )
                    )
                    
            )
            
            
        )
    )
)


server <- function(input, output, session) {
    
    # of years
    output$yearInfo <- renderInfoBox({
        infoBox(
            "# of Years", paste0(yearInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # grant information
    output$grantInfo <- renderInfoBox({
        infoBox(
            "Grant Types", paste0(grantInfo), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    # of organizations
    output$organizationalInfo <- renderInfoBox({
        infoBox(
            "# of Organizations", paste0(organizationInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # dollar amount
    output$amountAwardedInfo <- renderInfoBox({
        infoBox(
            "Grants awarded", paste0(amountAwardedInfo, " CAD"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    #types of budget
    output$budgetInfo <- renderInfoBox({
        infoBox(
            "Budget Types", paste0(budgetInfo), icon = icon("list"),
            color = "blue",fill = TRUE
        )
    })    
    
    # of cities for summary page
    output$areaInfo <- renderInfoBox({
        infoBox(
            "# of Grant areas", paste0(cityInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    #visualizations
    

    
    #grants
    output$grantAwarded <- renderPlot({
        
        #data <- df %>%
        #    dplyr::filter(year_update %in% input$Years)
        data <- df[df$year_update >= input$Years[[1]] & df$year_update <= input$Years[[2]],]
        #data <- df[which(df$year_update<=input$Years[[2]] & df$year_update>=input$Years[[1]]),]
        
        yearAwardedGrantProgram <- data %>% 
            #dplyr::filter(year_update %in% input$Years)%>%
            dplyr::group_by(year_update,grant_program) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
            
        
        ggplot(data=yearAwardedGrantProgram, aes(x=as.factor(year_update), 
                                                 y=total_awarded, fill=grant_program)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Grant Programs") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))
    })
    
    #budget fund
    output$budgetAwarded <- renderPlot({
        data<-df[df$year_update >= input$Years[[1]] & df$year_update <= input$Years[[2]],]
        
        yearAwardedBudget <- data %>%
            #dplyr::filter(year_update %in% input$Years)%>%
            dplyr::group_by(year_update,budget_fund_update) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        
        ggplot(data=yearAwardedBudget, aes(x=as.factor(year_update), y=total_awarded, fill=budget_fund_update)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Budget funds") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))       
    })
    
    #programs
    output$programAwarded <- renderPlot({
        data<-df[df$year_update >= input$Years[[1]] & df$year_update <= input$Years[[2]],]
        
        yearAwardedProgram <- data %>%
            #dplyr::filter(year_update %in% input$Years)%>%
            dplyr::group_by(year_update,program_area) %>%
            dplyr::summarise(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedProgram, aes(x=as.factor(year_update), y=total_awarded, fill=program_area)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Program Areas") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))       
    }) 
    
    #population served update
    
    #age group served update
    
    #year vs amount
    
    output$generateWordCloud <- renderPlot({
        wordcloudData <- df %>%
            dplyr::filter(year_update == input$yearInput) %>%
            dplyr::select(english_description)
        
        docs <- Corpus(VectorSource(wordcloudData$english_description))
        
        toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
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
        v <- sort(rowSums(m),decreasing=TRUE)
        d <- data.frame(word = names(v),freq=v)
        head(d, 10)
        
        set.seed(1234)
        wordcloud(words = d$word, freq = d$freq, min.freq = 1,
                  max.words=50, random.order=FALSE, rot.per=0.35, 
                  colors=brewer.pal(8, "Dark2"))
        
    })
    
    output$searchOTF <- DT::renderDataTable(DT::datatable({
        
    })) 
    
    #word cloud by geographical area served
    
    #word cloud of organization
    
    
    
    
}

shinyApp(ui, server)