#================================================================================
# Shiny web app which provides insights visualization for social good projects
#================================================================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}


#=============
# Load Data
#=============
charity_sdg <- read_excel("Charity - SDG.xlsx",sheet="SDG Goals")
charity_impact <- read_excel("Charity - SDG.xlsx",sheet="Impact Data")
partner_quotes <- read_excel("partner_quotes.xlsx")
linkedin <- read_excel("Linkedin Stats.xlsx",sheet="LI Metrics")
linkedin_posts <- read_excel("Linkedin Stats.xlsx",sheet="All posts")
project_nepal <- read_excel("projects/Build Up Nepal.xlsx")
project_india <- read_excel("projects/India Water Portal submissions.xlsx")
project_sunny <- read_excel("projects/Sunny Street Submissions.xlsx")
project_tap <- read_excel("projects/Tap Elderly Women_s Wisdom for Youth (TEWWY) Submissions.xlsx")
project_video <- read_excel("projects/Video Volunteers Submissions.xlsx")
project_who <- read_excel("projects/Who submissions.xlsx")


#=============
# Data Setup
#=============
charity <- sort(unique(charity_impact$`Name of charity/Project`))
linkedin$Date <- mdy(linkedin$Date)
projects <- sort(c('Project-Nepal', 'Project-India','Project-Sunny','Project-Tap','Project-WHO'))

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
  dashboardHeader(title = "VSFG Data Challenge"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Partners", tabName = "partner", icon = icon("list")),
        menuSubItem("Partner Feedback", tabName = "partner_quotes"),
        menuSubItem("Partner Insights", tabName = "partner_insights"),
      menuItem("Social Media", tabName = "social", icon = icon("list")),
      menuSubItem("Social Media Insights", tabName = "social_insights"),
      menuItem("Projects", tabName = "project", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
    #========  
    # Partners
    #========
      tabItem(tabName = "partner",
            fluidRow(
              valueBoxOutput("charityBox"),
              valueBoxOutput("countryBox"),
              valueBoxOutput("cityBox"),
              valueBoxOutput("topicBox"),
              valueBoxOutput("sdgBox"),
              valueBoxOutput("submissionBox")
            ),
            fluidRow(
                plotlyOutput("submissionOutput"),  
            ),
              
          ),
    tabItem(tabName = "partner_quotes",
            fluidRow(
              h4("Sentiment Analysis",style="text-align: center;"),
              plotlyOutput("sentimentPlot"),
              h4("Word Cloud",style="text-align: center;"),
              wordcloud2Output("wordCloudPlot",width = "150%", height = "400px"),
              h4("Partner Quotes",style="text-align: center;"),
              dataTableOutput("quoteTable"),
            ),
          ),
    tabItem(tabName = "partner_insights",
            sidebarLayout(
                sidebarPanel(width = 2,
                  selectInput("charityInput", label = "Charity/Project",choices =charity ),
                ),
            
              mainPanel (
                h4("Charity Insights",style="text-align: center;"),
                fluidRow(
                  valueBoxOutput("cityInsightBox"),
                  valueBoxOutput("countryInsightBox"),
                  valueBoxOutput("sdgInsightBox"), 
                ),
                fluidRow(
                  valueBoxOutput("submissionInsightBox"),
                  valueBoxOutput("topicInsightBox"),
                                 
                ),
                fluidRow(
                  dataTableOutput("charityTable")
                )
              )
            )
       ), 
    #========
    # social media
    #========
    tabItem(tabName = "social",
            h4("Linkedin Overview",style="text-align: center;"),
            fluidRow(
              valueBoxOutput("impressionBox"),
              valueBoxOutput("clicksBox"),
              valueBoxOutput("engagementBox"),
            ),
            fluidRow(
              valueBoxOutput("reactionBox"),
              valueBoxOutput("repostsBox"),
              valueBoxOutput("commentsBox"),
            ),
            fluidRow(
              plotlyOutput("linkedinPlot"),
            )
        ), 
    tabItem(tabName = 'social_insights',
            fluidRow(
              column(width = 12, 
                box(h4("Plotted by ",style="text-align: center;"),
                    plotlyOutput("plottedbyOutput"),),
                box(h4("Linkedin Metrics Correlation",style="text-align: center;"),
                    plotOutput("corrPlotOutput")),
              ),
            ),
              fluidRow(
                h4("Linkedin Metrics",style="text-align: center;"),
                plotlyOutput("linkedinPostPlot"),
                h4("Linkedin Engagement Metrics",style="text-align: center;"),
                plotlyOutput("linkedinPostPlot2"),
              ),
            fluidRow(
              h4("Sentiment Analysis",style="text-align: center;"),
              plotlyOutput("sentimentLinkedinPlot"),
              h4("Word Cloud",style="text-align: center;"),
              wordcloud2Output("wordCloudLinkedinPlot",width = "150%", height = "400px"),
              h4("Topic modeling",style="text-align: center;"),
              dataTableOutput("topicTable")
            )
        ),
    #========
    # Projects
    #========
    tabItem(tabName = "project",
            sidebarLayout(
              sidebarPanel(width = 2,
                           selectInput("projectInput", label = "Charity/Project",choices =projects),
              ),
              
              mainPanel (
                h4("Project Insights",style="text-align: center;"),
                fluidRow(
                )
              )
          
        )
      )
     )
   )
)






################
# Server logic 
################
server <- function(input, output,session) {
  
  #================
  # Partner
  #================
  output$charityBox <- renderValueBox({
    valueBox(
      "Charities", paste0(length(unique(charity_impact$`Name of charity/Project`))), icon = icon("list"),
      color = "aqua"
    )
  })

  output$countryBox <- renderValueBox({
    valueBox(
      "Countries", paste0(length(unique(charity_impact$`Charity Country`))), icon = icon("list"),
      color = "aqua"
    )
  })  
  
  output$cityBox <- renderValueBox({
    valueBox(
      "Cities", paste0(length(unique(charity_impact$`Charity City`))), icon = icon("list"),
      color = "aqua"
    )
  }) 
  
  output$topicBox <- renderValueBox({
    valueBox(
      "Topics", paste0(length(unique(charity_impact$Topic))), icon = icon("thumbs-up"),
      color = "aqua"
    )
  }) 

  output$sdgBox <- renderValueBox({
      valueBox(
        "SDG", paste0(length(unique(charity_sdg$`SDG Goals`))), icon = icon("thumbs-up"),
        color = "aqua"
      )
    })     
  
  output$submissionBox <- renderValueBox({
    valueBox(
      "Submissions", paste0(sum(charity_impact$`Number of Submissions`)), icon = icon("thumbs-up"),
      color = "aqua"
    )
  }) 

  output$submissionOutput <- renderPlotly({
    
    g<- charity_impact %>% 
      group_by(`Date of project`) %>%
      summarize(total_submissions = sum(`Number of Submissions`)) %>%
      select(`Date of project`,total_submissions) %>%
      ggplot( aes(x=`Date of project`, y=total_submissions)) +
      geom_line() + theme_classic() + 
      labs(x ="Dates", y = "# of Submissions") +
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))  
    
    ggplotly(g)
  })
  
  output$sentimentPlot <- renderPlotly({
    
    review_words <- partner_quotes %>%
      unnest_tokens(word, Quote) %>%
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
    
    ggplotly(g)
    

    
  })
  
  output$wordCloudPlot <- renderWordcloud2({
    word_cloud(partner_quotes$Quote)
  })
    
  output$quoteTable <- renderDataTable({
    partner_quotes
  })
  
  
  df <- reactive({
    charity_impact %>%
      filter(`Name of charity/Project` == input$charityInput)
  }) 
  
  df_sdg <- reactive({
    charity_sdg %>%
      filter(`Name of charity/Project` == input$charityInput)
  })
  
  output$countryInsightBox <- renderValueBox({
    valueBox(
      "Country", paste0( df()$`Charity Country`), icon = icon("list"),
      color = "aqua"
    )
  })  
  
  output$cityInsightBox <- renderValueBox({
    valueBox(
      "City", paste0(df()$`Charity City` ), icon = icon("list"),
      color = "aqua"
    )
  }) 
  
  output$topicInsightBox <- renderValueBox({
    valueBox(
      "Topic", paste0(df()$Topic), icon = icon("thumbs-up"),
      color = "aqua"
    )
  }) 
  
  output$sdgInsightBox <- renderValueBox({
    
    
    if (!is.null( length(df_sdg()$`SDG Goals`))) {
      output <- length(df_sdg()$`SDG Goals`)
    } else {
      output <- 0
    }
    
    valueBox(
      "SDGs", paste0(output), icon = icon("thumbs-up"),
      color = "aqua"
    )
  })     
  
  output$submissionInsightBox <- renderValueBox({
    valueBox(
      "Submissions", paste0(sum(df()$`Number of Submissions`)), icon = icon("thumbs-up"),
      color = "aqua"
    )
  })
  
  
  
  output$charityTable <- renderDataTable({
    df() %>%
      mutate(`Date of project` = lubridate::ymd(`Date of project`)) %>%
      select(`Name of charity/Project`,`Mission Statement`,`Charity City`, `Charity Country`,Topic, `Date of project`, `Number of Submissions`)
  })
  
  
  #================
  # Social Media
  #================
  output$impressionBox <- renderValueBox({
    valueBox(
      "Impressions", paste0(median(linkedin$`Impressions (total)`)), icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  output$clicksBox <- renderValueBox({
    valueBox(
      "Clicks", paste0(median(linkedin$`Clicks (total)`)), icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  output$engagementBox <- renderValueBox({
    valueBox(
      "Engagement", paste0(scales::percent(round(median(linkedin$`Engagement rate (total)`),2))), 
      icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  output$reactionBox <- renderValueBox({
    valueBox(
      "Reactions", paste0(median(linkedin$`Reactions (total)`)), icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  output$repostsBox <- renderValueBox({
    valueBox(
      "Reposts", paste0(median(linkedin$`Reposts (total)`)), icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  output$commentsBox <- renderValueBox({
    valueBox(
      "Impressions", paste0(median(linkedin$`Comments (total)`)), icon = icon("list"),
      color = "aqua"
    )
    
  })
  
  
  output$linkedinPlot <- renderPlotly({
    
    temp_df <- linkedin %>%
      group_by(Date)%>%
      summarise(
        Impressions = sum(`Impressions (total)`),
        Clicks = sum(`Clicks (total)`),
        Reactions = sum(`Reactions (total)`),
        Comments = sum(`Comments (total)`),
        Reposts = sum(`Reposts (total)`)
      ) %>%
      select(Date, Impressions, Clicks, Reactions, Comments, Reposts)
    
    d <- reshape2::melt(temp_df, id.vars="Date")
    
    plot_output <- ggplot(d, aes(Date,value, col=variable)) + 
      geom_line()  + theme_classic() +
      labs(x ="Date", y = "Metric Count",col='Linkedin Metrics') + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12)) 
    
    ggplotly(plot_output)
    
  })
  
  output$plottedbyOutput <- renderPlotly({
    
    df <- linkedin_posts %>%
      group_by(`Posted by`) %>%
      summarise(Total = n()) %>%
      select(`Posted by`,Total)
    
    g <- ggplot(df, aes(x = `Posted by`, ,y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='blue') + theme_classic() + 
      labs(x ="Posted By", y = "Total Posts") + coord_flip() +
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
    
    ggplotly(g)
    
    
  })
  
  output$corrPlotOutput <- renderPlot({
    corr_df <- linkedin_posts %>%
      select(Impressions,Clicks, Likes, Comments, Reposts, `Click through rate (CTR)`,`Engagement rate`)
    
    corrplot(cor(corr_df),method="number")
  })
  
  output$linkedinPostPlot <- renderPlotly({
    
    linkedin_posts$`Created date` <- dmy(linkedin_posts$`Created date`)
    temp_df <- linkedin_posts %>%
      group_by(`Created date`) %>%
      summarise(
        Impressions = sum(Impressions),
        Clicks = sum(Clicks),
        Likes = sum(Likes),
        Comments = sum(Comments),
        Reposts = sum(Reposts)
      ) %>%
      select(`Created date`, Impressions, Clicks, Likes, Comments, Reposts) %>%
      na.omit()
    
    d <- reshape2::melt(temp_df, id.vars="Created date")
    
    plot_output <- ggplot(d, aes(`Created date`,value, col=variable)) + 
      geom_line()  + theme_classic() +
      labs(x ="Date", y = "Metric Count",col='Linkedin Metrics') + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12)) 
    
    ggplotly(plot_output)
  })
  
  output$linkedinPostPlot2 <- renderPlotly({
    
    linkedin_posts$`Created date` <- dmy(linkedin_posts$`Created date`)
    temp_df <- linkedin_posts %>%
      group_by(`Created date`) %>%
      summarise(
        `Engagement Rate` = round(sum(`Engagement rate`) * 100,2),
        `Click Through Rate` = round(sum(`Click through rate (CTR)`) * 100,2),
        
      ) %>%
      select(`Created date`, `Engagement Rate`,`Click Through Rate`) %>%
      na.omit()
    
    d <- reshape2::melt(temp_df, id.vars="Created date")
    
    
    plot_output <- ggplot(d, aes(`Created date`,value, col=variable)) + 
      geom_line()  + theme_classic() +
      labs(x ="Date", y = "Engagement %",col='Linkedin Metrics') + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12)) 
    
    
    ggplotly(plot_output)
  })
  
  output$sentimentLinkedinPlot <- renderPlotly({
    review_words <- linkedin_posts %>%
      unnest_tokens(word, `Post title`) %>%
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
    
    ggplotly(g)
  })

  output$wordCloudLinkedinPlot <- renderWordcloud2({
    word_cloud(linkedin_posts$`Post title`)
  })
  
  output$topicTable <- renderDataTable({
    
    set.seed(1502)
    clean <- textcleaner(linkedin_posts$`Post title`)
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
    
    top_terms
    
  })

  
  #================
  # Projects
  #================
}

shinyApp(ui, server)

