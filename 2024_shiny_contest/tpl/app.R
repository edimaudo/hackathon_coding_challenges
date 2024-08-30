#========================================
# Shiny web app which provides insights
# about Toronto Public Library
#=========================================
rm(list = ls())
################
# Libraries
################
packages <- c(
  'rjson',
  'ggplot2',
  'corrplot',
  'tidyverse',
  'shiny',
  'shinydashboard',
  'DT',
  'readxl',
  'reshape2',
  'tidyr',
  'lubridate',
  'plotly',
  'RColorBrewer',
  'data.table',
  'scales',
  'dplyr'
)
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
################
# Load data
################
tpl_clc <- read_csv("Computer_Learning_Centres.csv")
tpl_dih <- read_csv("Digital_Innovation_Hubs.csv")
tpl_kecl <- read_csv("KidsStop_Early_Literacy_Centres.csv")
tpl_nib <- read_csv("Neighbourhood_Improvement_Area_Branches.csv")
tpl <- read_csv("tpl-branch-general-information-2023.csv")
tpl_branch_card_registration <- read_csv("tpl-card-registrations-annual-by-branch-2012-2022.csv")
tpl_branch_circulation <- read_csv("tpl-circulation-annual-by-branch-2012-2022.csv")
tpl_branch_eventfeed <- read_csv("tpl-events-feed.csv")
tpl_branch_visit <- read_csv("tpl-visits-annual-by-branch-2012-2022.csv")
tpl_branch_workstation <- read_csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv")
tpl_yag <- read_csv("Youth_Advisory_Groups_Locations.csv")
tpl_yh <- read_csv("Youth_Hubs_Locations.csv")
toronto_wellbeing <- read_csv("wellbeing-toronto-economics.csv")
toronto_neighborhood <- fromJSON("Neighbourhoods.geojson")


################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "Apra Data Science Challenge", tags$li(
    a(
      href = 'https://www.aprahome.org',
      img(
        src = 'https://www.aprahome.org/Portals/_default/skins/siteskin/images/logo.png',
        title = "Home",
        height = "30px"
      ),
      style = "padding-top:10px; padding-bottom:10px;"
    ),
    class = "dropdown"
  )),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("th")),
      menuSubItem("Interaction", tabName = "interaction"),
      menuSubItem("Gifts", tabName = "gift"),
      menuItem(
        "Customer Segmentation",
        tabName = "segment",
        icon = icon("list")
      ),
      menuItem(
        "Gift Forecasting Overview",
        tabName = "forecast_overview",
        icon = icon("list")
      ),
      menuSubItem("Gift Forecasting Analysis", tabName = "forecast_analysis"),
      menuSubItem("Gift Forecasting", tabName = "forecast")
    )
  ),
  dashboardBody(tabItems(
    #========
    # About
    #========
    tabItem(tabName = "about", includeMarkdown("about.md"), hr()),
    #========
    # Segmentation
    #========
    tabItem(tabName = "segment", sidebarLayout(
      sidebarPanel(
        width = 3,
        selectInput(
          "campaignInput",
          "Campaign",
          choices = campaign,
          selected = campaign,
          multiple = TRUE
        ),
        selectInput(
          "primaryUnitInput",
          "Primary Unit",
          choices = primary_unit,
          selected = primary_unit,
          multiple = TRUE
        ),
        selectInput(
          "giftTypeInput",
          "Gift Type",
          choices = gift_type,
          selected = gift_type,
          multiple = TRUE
        ),
        selectInput(
          "giftChannelInput",
          "Gift Channel",
          choices = gift_channel,
          selected = gift_channel,
          multiple = TRUE
        ),
        selectInput(
          "paymentTypeInput",
          "Payment Type",
          choices = payment_type,
          selected = payment_type,
          multiple = TRUE
        ),
        submitButton("Submit")
      ),
      mainPanel(fluidRow(DT::dataTableOutput("rfmTable")))
    ))
  ))
)



################
# Server
################
server <- function(input, output, session) {
}

shinyApp(ui, server)