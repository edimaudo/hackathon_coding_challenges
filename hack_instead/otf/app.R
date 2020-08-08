#otf analysis
rm(list = ls())
#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny','shinydashboard',
              'SnowballC','wordcloud','dplyr','tidytext')
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

# #load data
# df <- read.csv("otf.csv")
# 
# 
# yearInfo <- length(unique(df$year))
# grantInfo <- length(unique(df$grant_program2))
# organizationInfo <- length(unique(df$organization_name))
# amountAwardedInfo <- sum(df$amount_awarded)
# ageGroupInfo <- length(unique(df$age_group2))
# budgetInfo <- length(unique(df$budget_fund))
# cityInfo <- length(unique(df$city2))
# 
# yearSliderInput <- sort(as.vector(unique(df$year)))
# yearData = as.array(yearSliderInput)
# 
# grantSliderInput <- sort(as.vector(unique(df$grant_program2)))
# grantData = as.array(grantSliderInput)
# 
# programSliderInput <- sort(as.vector(unique(df$program_area)))
# programData = as.array(programSliderInput)


#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Fund analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Summary", tabName = "Summary", icon = icon("dashboard")),
            menuItem("Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Description Analysis", tabName = "TextAnalysis", icon = icon("th"))
            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",includeMarkdown("intro.md"),hr()),
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
                                        value = yearSliderInput, step=1, ticks = FALSE, sep="")
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
            tabItem(tabName = "TextAnalysis",
                    sidebarLayout(
                        sidebarPanel(
                            selectInput("yearInput", "Year:",choices=yearData),
                            br(),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            fluidRow(
                                plotOutput("generateWordCloud")
                            )
                        )
                    )
                    
            )
            
        )
    )
)


server <- function(input, output) {
    
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
            "Type of Grants", paste0(grantInfo), icon = icon("list"),
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
            "$ value of grants awarded", paste0(amountAwardedInfo, " CAD"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    #types of budget
    output$budgetInfo <- renderInfoBox({
        infoBox(
            "Types of budget", paste0(budgetInfo), icon = icon("list"),
            color = "blue",fill = TRUE
        )
    })    
    
    # of cities for summary page
    output$areaInfo <- renderInfoBox({
        infoBox(
            "# of places covered by grants", paste0(cityInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    #visualizations
    #grants
    output$grantAwarded <- renderPlot({
        
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedGrantProgram <- data %>%
            dplyr::group_by(year,grant_program2) %>%
            dplyr::summarize(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedGrantProgram, aes(x=as.factor(year), y=total_awarded, fill=grant_program2)) +
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
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedBudget <- data %>%
            dplyr::group_by(year,budget_fund) %>%
            dplyr::summarize(total_awarded = sum(amount_awarded))
        
        
        ggplot(data=yearAwardedBudget, aes(x=as.factor(year), y=total_awarded, fill=budget_fund)) +
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
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedProgram <- data %>%
            dplyr::group_by(year,program_area) %>%
            dplyr::summarize(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedProgram, aes(x=as.factor(year), y=total_awarded, fill=program_area)) +
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
    
    output$generateWordCloud <- renderPlot({
        wordcloudData <- df %>%
            dplyr::filter(year == input$yearInput) %>%
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
    
    
    
    
}

shinyApp(ui, server)