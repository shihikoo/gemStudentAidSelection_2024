function(request) {
  sidebar <- dashboardSidebar(hr(), sidebarMenu(
    id = "side",
    menuItem(
      "Summary of Applicants",
      tabName = "summary",
      icon = icon("pie-chart")), 
    menuItem(
      "Selected Graduates",
      tabName = "selectedGraduate",
      icon = icon("table") ), 
    menuItem(
      "Selected International",
      tabName = "selectedInternatinal",
      icon = icon("table") ), 
    menuItem(
      "Selected Undergraudates",
      tabName = "selectedUndergraduate",
      icon = icon("table") ), 
    menuItem(
      "Selected Postdoc",
      tabName = "selectedPostdoc",
      icon = icon("table") )
  ),
  hr(),
  conditionalPanel("input.side == 'selectedGraduate'",
                   fluidRow(
                     column(1),
                     column(10,
                            # h4("Number of awardees"),
                            sliderInput("number", "Number of awardees", value = 84, min = 1, max = 84, step = 1),
                     )
                   )
  ))
  
  body <- dashboardBody(tabItems(
    tabItem(tabName = "summary",
            fluidRow(
              column(
                width = 12,
                box(
                  width = 4,
                  plotlyOutput("Degree"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("NumGEM"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("DegreeYears"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("Pronouns"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("inNeed"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("AffiliationCountry"),
                  solidHeader = TRUE,
                  status = "primary"
                ),
                box(
                  width = 4,
                  plotlyOutput("NumAdvisor"),
                  solidHeader = TRUE,
                  status = "primary"
                ) 
              )
            )),
    tabItem(tabName = "selectedGraduate",
            fluidRow(
              box(
                width = NULL,
                status = "primary",
                solidHeader = TRUE,
                br(),
                DT::dataTableOutput("selectedGraduateDf")
              )
            ))
    ,
    tabItem(tabName = "selectedInternatinal",
            fluidRow(
              box(
                width = NULL,
                status = "primary",
                solidHeader = TRUE,
                br(),
                DT::dataTableOutput("selectedintergraduateDf")
              )
            )),
    tabItem(tabName = "selectedUndergraduate",
            fluidRow(
              box(
                width = NULL,
                status = "primary",
                solidHeader = TRUE,
                br(),
                DT::dataTableOutput("selectedUndergraduateDf")
              )
            )),
    tabItem(tabName = "selectedPostdoc",
            fluidRow(
              box(
                width = NULL,
                status = "primary",
                solidHeader = TRUE,
                br(),
                DT::dataTableOutput("selectedPostdocDf")
              )
            ))
    
  ))
  
  dashboardPage(dashboardHeader(title = "2023 GEM Financial Aid Application"),
                sidebar,
                body)
  
  
}