################
# Shiny web app which provides 
# insights about  Toronto Public Library
################
rm(list = ls())
################
# Libraries
################
packages <- c(
  'rjson','dplyr',
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','bslib','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
################
# Data
################
tpl_clc <- read.csv("Computer_Learning_Centres.csv",sep = ",")  
tpl_dih <- read.csv("Digital_Innovation_Hubs.csv",sep = ",")
tpl_kecl <- read.csv("KidsStop_Early_Literacy_Centres.csv",sep = ",")
tpl_nib <- read.csv("Neighbourhood_Improvement_Area_Branches.csv",sep = ",")
tpl <- read.csv("tpl-branch-general-information-2023.csv",sep = ",")
tpl_branch_card_registration <- read.csv("tpl-card-registrations-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_circulation <- read.csv("tpl-circulation-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_eventfeed <- read.csv("tpl-events-feed.csv",sep = ",")
tpl_branch_visit <- read.csv("tpl-visits-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_workstation <- read.csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv",sep = ",")
tpl_yag <- read.csv("Youth_Advisory_Groups_Locations.csv",sep = ",")
tpl_yh <- read.csv("Youth_Hubs_Locations.csv",sep = ",")

#=============
# Data setup
#=============

tpl_branch_code <- function(branchName){
  tpl_branch <- tpl %>%
    filter(BranchName == branchName) %>%
    select(BranchCode)
}

tpl_branch <- tpl %>%
  filter(PhysicalBranch == 1) %>%
  select(BranchName) %>%
  arrange()

tpl_branch_eventfeed$Month <- lubridate::month(tpl_branch_eventfeed$startdate,label=TRUE,abbr = FALSE)
tpl_branch_eventfeed$DOW <- lubridate::wday(tpl_branch_eventfeed$startdate,label=TRUE,abbr = FALSE)


month <- tpl_branch_eventfeed %>%
  mutate(Month = factor(Month, levels = month.name)) %>%
  select (Month) %>%
  arrange(Month)

#=============
# Text analytics
#=============
textcleaner <- function(x){
  x <- as.character(x)
  
  x <- x %>%
    str_to_lower() %>%  # convert all the string to low alphabet
    replace_contraction() %>% # replace contraction to their multi-word forms
    replace_internet_slang() %>% # replace internet slang to normal words
    #replace_emoji(replacement = " ") %>% # replace emoji to words
    #replace_emoticon(replacement = " ") %>% # replace emoticon to words
    replace_hash(replacement = "") %>% # remove hashtag
    replace_word_elongation() %>% # replace informal writing with known semantic replacements
    replace_number(remove = T) %>% # remove number
    replace_date(replacement = "") %>% # remove date
    #replace_time(replacement = "") %>% # remove time
    str_remove_all(pattern = "[[:punct:]]") %>% # remove punctuation
    str_remove_all(pattern = "[^\\s]*[0-9][^\\s]*") %>% # remove mixed string n number
    str_squish() %>% # reduces repeated whitespace inside a string.
    str_trim() # removes whitespace from start and end of string
  
  return(as.data.frame(x))
  
}


fix_contractions <- function(doc) {
  # "won't" is a special case as it does not expand to "wo not"
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", " not", doc)
  doc <- gsub("'ll", " will", doc)
  doc <- gsub("'re", " are", doc)
  doc <- gsub("'ve", " have", doc)
  doc <- gsub("'m", " am", doc)
  doc <- gsub("'d", " would", doc)
  # 's could be 'is' or could be possessive: it has no expansion
  doc <- gsub("'s", "", doc)
  return(doc)
}


remove_special_characters <- function(x) gsub("[^a-zA-Z0-9 ]", " ", x)

word_cloud <- function(x) {
  text <- x
  # Create a corpus  
  docs <- Corpus(VectorSource(text))
  docs <- docs %>%
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace)
  docs <- tm_map(docs, content_transformer(tolower))
  docs <- tm_map(docs, removeWords, stopwords("english"))
  
  dtm <- TermDocumentMatrix(docs) 
  matrix <- as.matrix(dtm) 
  words <- sort(rowSums(matrix),decreasing=TRUE) 
  df <- data.frame(word = names(words),freq=words)
  
  set.seed(1234)
  wordcloud2(data=df, size=1.6, color='random-dark')
  
}

sentiment_analysis <- function(x) {
  bing_word_counts <- x %>%
    inner_join(get_sentiments("bing")) %>%
    count(word, sentiment, sort = TRUE) %>%
    ungroup()
}

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(
    title = "TPL",
    tags$li(a(href = 'https://www.torontopubliclibrary.ca',
    img(src = 'https://upload.wikimedia.org/wikipedia/commons/4/47/Toronto_Public_Library_Logo.png',
    title = "Home", height = "30px"),
    style = "padding-top:10px; padding-bottom:10px;"),
    class = "dropdown")
    ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("Branch", tabName = "branch", icon = icon("book")),
      menuItem("Branch Events", tabName = "branch_event", icon = icon("book")),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(

    tabItems(
    #========  
    # Overview
    #========
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("libraryBox"),
                valueBoxOutput("clcBox"),
                valueBoxOutput("keclBox"),
                valueBoxOutput("dihBox"),
                valueBoxOutput("yagBox"),
                valueBoxOutput("yhBox")
              ),
              
              fluidRow(
                h2("Trends",style="text-align: center;text-style:bold"),
                radioButtons( 
                  inputId = "radioTrend", 
                  label = "", 
                  choices = list( 
                    "Annual Card Registrations" = 1, 
                    "Annual Circulation" = 2, 
                    "Annual Visits" = 3,
                    "Annual Workstation Usage" = 4 
                  ) ,
                  inline=T
                ),
                plotlyOutput("tplOverviewTrendPlot") 
              )
      ),
    #========  
    # Branch
    #========
      tabItem(tabName = "branch",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("branchInput", 
                                         label = "Branch",
                                         choices =tpl_branch)
                ),
                
                mainPanel (
                  fluidRow(
                    valueBoxOutput("branchCodeBox"),
                    valueBoxOutput("workStationsBox"),
                    #valueBoxOutput("serviceTierBox"),
                    valueBoxOutput("presentSiteBox")
                  ),
                  fluidRow(
                    valueBoxOutput("kidStopBox"),
                    valueBoxOutput("branchclcBox"),
                    #valueBoxOutput("branchdihBox"),
                    valueBoxOutput("teenCouncilBox")
                  ),
                  fluidRow(
                    dataTableOutput("branchTable")
                  ),
                  fluidRow(
                    h3("Branch Trends",style="text-align: center;text-style:bold"),
                    fluidRow(
                      radioButtons( 
                        inputId = "radioBranchTrend", 
                        label = "", 
                        choices = list( 
                          "Annual Card Registrations" = 1, 
                          "Annual Circulation" = 2, 
                          "Annual Visits" = 3,
                          "Annual Workstation Usage" = 4 
                        ) ,
                        inline=T
                      ),
                      plotlyOutput("tplBranchTrendPlot")
                    )
                  )
                )
      )
    ),
    #========  
    # Branch Events
    #========
    tabItem(tabName = "branch_event",
            sidebarLayout(
              sidebarPanel(width = 3,
                           selectInput("branchEventInput", 
                                       label = "Branch",
                                       choices =tpl_branch),
                           selectInput("monthEventInput", 
                                       label = "Month",
                                       choices =month)
              ),
              
              mainPanel (
                
                tabsetPanel(
                  tabPanel("Insights",
                           fluidRow(
                             h3("Events by Day of Week",style="text-align: center;text-style:bold"),
                             plotlyOutput("brancheventsDOWPlot"),
                           ),
                  ),
                  tabPanel("Text Analytics",
                           fluidRow(
                             h3("Sentiment Analysis",style="text-align: center;text-style:bold"),
                             plotlyOutput("sentimentPlot"),
                             h3("Word Cloud",style="text-align: center;text-style:bold"),
                             wordcloud2Output("wordCloudPlot",width = "150%", height = "400px"),
                             h3("Potential Topics",style="text-align: center;text-style:bold"),
                             dataTableOutput("topicTable")
                           )
                  ),
                  tabPanel("Table",
                           fluidRow(
                             dataTableOutput("branchEventTable")
                           )
                  )
                )
              )
            )
    ),
    #========  
    # About
    #========
      tabItem(tabName = "about",includeMarkdown("about.md"),hr())
  )
 )
)
################
# Server
################
server <- function(input, output, session) {
  #-----------
  # Overview
  #-----------
  # of libraries
  output$libraryBox <- renderValueBox({
    tpl_library <- tpl %>%
      filter(PhysicalBranch == 1) %>%
      select(BranchName)
    
    valueBox(
      value = tags$p("Libraries", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_library$BranchName)), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  # Computer_Learning_Centres
  output$clcBox <- renderValueBox({
    valueBox(
      value = tags$p("Computer Learning Centres", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(tpl_clc$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("computer"),    
      color = "aqua"
    )
  })  
  # of KidsStop_Early_Literacy_Centres
  output$keclBox <- renderValueBox({
    valueBox(
      value = tags$p("Early Literacy Centres", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_kecl$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("child"),  
      color = "aqua"
    )
  })  
  
  # of Neighbourhood_Improvement_Area_Branches
  output$nibBox <- renderValueBox({
    valueBox(
      value = tags$p("Improvement Branches", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(tpl_nib$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("thumbs-up"),  
      color = "aqua"
    )
  })  
  # of Digital_Innovation_Hubs
  output$dihBox <- renderValueBox({
    valueBox(
      value = tags$p("Digital Innovation Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_dih$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("lightbulb"),  
      color = "aqua"
    )
  })    
  # of Youth_Advisory_Groups_Locations
  output$yagBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Advisory", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_yag$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("person"),  
      color = "aqua"
    )
  })   
  # of Youth_Hubs_Locations
  output$yhBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_yh$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("person"), 
      color = "aqua"
    )
  }) 
  #-----------
  # Overview Trend
  #-----------
  output$tplOverviewTrendPlot <- renderPlotly({
    
    if (input$radioTrend == 1) {
      tpl_trend <- tpl_branch_card_registration %>%
        group_by(Year)%>%
        summarise(Total = sum(Registrations)) %>%
        select(Year, Total) 
    } else if (input$radioTrend == 2){
      
      tpl_trend <- tpl_branch_circulation%>%
        group_by(Year)%>%
        summarise(Total = sum(Circulation)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 3){
      
      tpl_trend <- tpl_branch_visit%>%
        group_by(Year)%>%
        summarise(Total = sum(Visits)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 4){
      
      tpl_trend <- tpl_branch_workstation%>%
        group_by(Year)%>%
        summarise(Total = sum(Sessions)) %>%
        select(Year, Total)
    }
    
    g <- ggplot(tpl_trend, aes(x = Year, y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='#0474ca') + theme_classic() + 
      labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) + 
      scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
    
    ggplotly(g)
    
  })
    
  
  #-----------
  # Branch boxes
  #-----------
  tpl_branch_info  <- reactive({
    tpl %>%
      filter(PhysicalBranch == 1, BranchName==input$branchInput) %>%
      select(BranchName,BranchCode,Workstations,ServiceTier,PresentSiteYear,KidsStop,CLC,DIH,TeenCouncil)
  }) 
  

  output$branchCodeBox <- renderValueBox({
    valueBox(
      value = tags$p("Branch Code", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$BranchCode), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$workStationsBox <- renderValueBox({
    valueBox(
      value = tags$p("Workstations", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$Workstations), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$serviceTierBox <- renderValueBox({
    valueBox(
      value = tags$p("Service Tier", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$ServiceTier), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$presentSiteBox <- renderValueBox({
    valueBox(
      value = tags$p("Available Since", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$PresentSiteYear), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$kidStopBox <- renderValueBox({
    valueBox(
      value = tags$p("Kid Stop", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$KidsStop), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$branchclcBox <- renderValueBox({
    valueBox(
      value = tags$p("CLC", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$CLC), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$branchdihBox <- renderValueBox({
    valueBox(
      value = tags$p("DIH", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$DIH), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$teenCouncilBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Council", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$TeenCouncil), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
# 
  #-----------
  # Branch Table
  #-----------
  tbl_branch_table <- reactive({
    tpl %>%
      filter(PhysicalBranch == 1, BranchName == input$branchInput) %>%
      select(Address,PostalCode,WardName,Website,Telephone,SquareFootage)
  })
  
  output$branchTable <- renderDataTable({
      tbl_branch_table()
  })

  #-----------
  # Branch Trend
  #-----------
    output$tplBranchTrendPlot <- renderPlotly({
      if (input$radioBranchTrend == 1) {
        #- tpl-card-registrations-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_card_registration %>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Registrations)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 2){
        #- tpl-circulation-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_circulation%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Circulation)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 3){
        #- tpl-visits-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_visit%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Visits)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 4){
        #- tpl-workstation-usage-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_workstation%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Sessions)) %>%
          select(Year, Total)
      }

      g <- ggplot(tpl_trend, aes(x = Year, y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='#0474ca') + theme_classic() +
        labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) +
        scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))

      ggplotly(g)

    })
  #-----------
  # Branch Events
  #-----------
  
  tpl_event_info  <- reactive({
    tpl_branch_eventfeed %>%
      filter(library==input$branchEventInput, Month == input$monthEventInput) %>%
      select(title, description,location,pagelink,eventtype1,eventtype2,eventtype3,agegroup1,Month,DOW)
  }) 
  
  #-----------
  # Sentiment analysis
  #-----------
  output$sentimentPlot <- renderPlotly({
    
    review_words <-  tpl_event_info() %>%
      unnest_tokens(word, description) %>%
      anti_join(stop_words) %>%
      distinct() %>%
      filter(nchar(word) > 3) 
    
    bing_word_counts <- sentiment_analysis(review_words)
    
    g <- bing_word_counts %>%
      group_by(sentiment) %>%
      top_n(10) %>%
      ggplot(aes(reorder(word, n), n, fill = sentiment)) +
      geom_bar(alpha = 0.9, stat = "identity", show.legend = FALSE) + theme_classic() +
      facet_wrap(~sentiment, scales = "free_y") +
      labs(y = "Contribution to sentiment", x = NULL) +
      coord_flip()
    
    tryCatch(ggplotly(g),
             error = function(e){
               message("No data available:\n", e)
             })
    
  })
  
  #-----------
  # word cloud
  #-----------
  output$wordCloudPlot <- renderWordcloud2({
    
    tryCatch(word_cloud( tpl_event_info()$title),
             error = function(e){
               message("No data available:\n", e)
             })
    
    
  })
  
  #-----------
  # topics
  #-----------
  output$topicTable <- renderDataTable({
    
    set.seed(1502)
    clean <- textcleaner(tpl_event_info()$description)
    clean <- clean %>% mutate(id = rownames(clean))
    
    # crete dtm
    dtm_r <- CreateDtm(doc_vec = clean$x,
                       doc_names = clean$id,
                       ngram_window = c(1,2),
                       stopword_vec = stopwords("en"),
                       verbose = F)
    
    dtm_r <- dtm_r[,colSums(dtm_r)>2]
    
    mod_lda <- FitLdaModel(dtm = dtm_r,
                           k = 10, # number of topic
                           iterations = 500,
                           burnin = 180,
                           alpha = 0.1,beta = 0.05,
                           optimize_alpha = T,
                           calc_likelihood = T,
                           calc_coherence = T,
                           calc_r2 = T)
    
    mod_lda$top_terms <- GetTopTerms(phi = mod_lda$phi,M = 15)
    mod_lda$prevalence <- colSums(mod_lda$theta)/sum(mod_lda$theta)*100
    
    mod_lda$labels <- LabelTopics(assignments = mod_lda$theta > 0.05, 
                                  dtm = dtm_r,
                                  M = 1)
    
    mod_lda$summary <- data.frame(topic = rownames(mod_lda$phi),
                                  labels = mod_lda$labels,
                                  coherence = round(mod_lda$coherence,3),
                                  prevalence = round(mod_lda$prevalence,3),
                                  top_terms = apply(mod_lda$top_terms,2,
                                                    function(x){paste(x,collapse = ", ")}))
    
    modsum <- mod_lda$summary %>%
      `rownames<-`(NULL)
    
    top_terms<- modsum %>% 
      rename(label = label_1, `top terms` = top_terms) %>%
      arrange(desc(coherence)) %>%
      slice(1:10)
    
   
    
    tryCatch( top_terms,
             error = function(e){
               message("No data available:\n", e)
             })
    
  })
  #-----------
  # Branch Events Insights
  #-----------
  output$brancheventsDOWPlot <- renderPlotly({
    
  })
  
  #-----------
  # Branch Events Table
  #-----------
  output$branchEventTable <- renderDataTable({
    
    tryCatch( tpl_event_info(),
              error = function(e){
                message("No data available:\n", e)
              })
    
    
  })
  
  

}

shinyApp(ui, server)