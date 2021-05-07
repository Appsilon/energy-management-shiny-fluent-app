library(dplyr)
library(ggplot2)
library(glue)
library(leaflet)
library(plotly)
library(sass)
library(shiny)
library(shiny.fluent)
library(shiny.router)

shiny.react::enableReactDebugMode()

makeCard <- function(title, content, size = 12, style = "") {
  div(class = glue("card ms-depth-8 ms-sm{size} ms-xl{size}"),
      style = style,
      Stack(
        tokens = list(childrenGap = 5),
        Text(variant = "large", title, block = TRUE),
        content
      ))
}

makePage <- function (title, subtitle, contents) {
  tagList(div(
    class = "page-title",
    span(title, class = "ms-fontSize-32 ms-fontWeight-semibold", style =
           "color: #323130"),
    span(subtitle, class = "ms-fontSize-14 ms-fontWeight-regular", style =
           "color: #605E5C; margin: 14px;")
  ),
  contents)
}

questionInputId <- function(title, i) {
  paste0("question_", title, "_", i)
}
makeQuestionsCard <- function(title, questions){
  questionsInputs <- purrr::map(1:4, function(i){
    inputId <- questionInputId(title, i)
    Checkbox.shinyInput(inputId, label=questions[i], key = inputId)
  })
  makeCard(title, questionsInputs, size = 12, style = "maxHeight: 320px")
}

bodyQuestions <- c(
  "I don’t regularly get at least seven to eight hours of sleep, and I often wake up feeling tired.",
  "I frequently skip breakfast, or I settle for something that isn’t nutritious.",
  "I don’t work out enough (meaning cardiovascular training at least three times a week and strength training at least once a week).",
  "I don’t take regular breaks during the day to truly renew and recharge, or I often eat lunch at my desk, if I eat it at all.")
mindQuestions <- c(
  "I have difficulty focusing on one thing at a time, and I am easily distracted during the day, especially by e-mail.",
  "I spend much of my day reacting to immediate crises and demands rather than focusing on activities with longer-term value and high leverage.",
  "I don’t take enough time for reflection, strategizing, and creative thinking.",
  "I work in the evenings or on weekends, and I almost never take an e-mail–free vacation."
)
emotionsQuestions <- c(
  "I frequently find myself feeling irritable, impatient, or anxious at work, especially when work is demanding.",
  "I don’t have enough time with my family and loved ones, and when I’m with them, I’m not always really with them.",
  "I have too little time for the activities that I most deeply enjoy.",
  "I don’t stop frequently enough to express my appreciation to others or to savor my accomplishments and blessings."
)
spiritQuestions <- c(
  "I don’t spend enough time at work doing what I do best and enjoy most.",
  "There are significant gaps between what I say is most important to me in my life and how I actually allocate my time and energy.",
  "My decisions at work are more often influenced by external demands than by a strong, clear sense of my own purpose.",
  "I don’t invest enough time and energy in making a positive difference to others or to the world."
)

totalScoreGuide <- c(
  "Excellent energy management skills",
  "Reasonable energy management skills",
  "Significant energy management deficits",
  "A full-fledged energy management crisis")
totalScoreGuideThresholds <- c(4, 7, 11, 1000000)
  
categoryScoreGuide <- c(
  "Excellent energy management skills",
  "Strong energy management skills",
  "Significant deficits",
  "Poor energy management, skills",
  "A full-fledged energy crisis")

categories <- c("Body", "Mind", "Emotions", "Spirit")
bodyQuestionsCard <- makeQuestionsCard("Body", bodyQuestions)
mindQuestionsCard <- makeQuestionsCard("Mind", mindQuestions)
emotionsQuestionsCard <- makeQuestionsCard("Emotions", emotionsQuestions)
spiritQuestionsCard <- makeQuestionsCard("Spirit", spiritQuestions)

# ---- analysis-page ----
analysis_page <- makePage(
  "Are You Headed for An Energy Crisis?",
  "Take the test to find out.",
  Stack(
    tokens = list(childrenGap = 12),
    reactOutput("page"),
    reactOutput("nextPageButton")
  )
)

# ---- basic-layout-ui ----

sass(
  sass_file("my_style.scss"),
  output = "www/my_style.css"
)

# ---- header ----
header <- tagList(
  img(src = "appsilon-logo.png", class = "logo"),
  div(Text(variant = "xLarge", "Manage Your Energy!"), class = "title"))


footer <- Stack(
  horizontal = TRUE,
  horizontalAlign = 'space-between',
  tokens = list(childrenGap = 20),
  Text(variant = "medium", "Built with ❤ by Appsilon", block=TRUE),
  Text(variant = "medium", nowrap = FALSE, "Based on Tony Schwartz & Catherine McCarthy, HBR, 10/2017, and the 'Get Connected' book"),
  Text(variant = "medium", nowrap = FALSE, "All rights reserved.")
)


layout <- function(mainUI){
  div(class = "grid-container",
      div(class = "header", header),
      div(class = "main", mainUI),
      div(class = "footer", footer)
  )
}

ui <- fluentPage(
  layout(analysis_page),
  tags$head(
    tags$link(href = "my_style.css", rel = "stylesheet", type = "text/css")
  ))

welcomeCard <- makeCard("Manage Your Energy, Not Your Time",
                        div(
                          p("As Tony Schwartz and Catherine McCarthy wrote in their famous ",
                            a("HBR article,", href="https://hbr.org/2007/10/manage-your-energy-not-your-time")),
                          Text(variant = "large", block = TRUE, tags$em("The core problem with working longer hours is that time is a finite resource. Energy is a different story. Defined in physics as the capacity to work, energy comes from four main wellsprings in human beings: the body, emotions, mind, and spirit. '")),
                          p("It turns out that managing your energy, not time, is key to happy and productive life. Take this test to find out where you are currently and which areas you can improve.")
                        ),
                        size = 12, style = "maxHeight: 320px")
                        

PAGE_COUNT = 6
server <- function(input, output, session) {

  vals <- reactiveValues(page = 0)
  
  output$page <- renderReact({
    list(welcomeCard, bodyQuestionsCard, mindQuestionsCard, emotionsQuestionsCard, spiritQuestionsCard, uiOutput("analysis"))[[vals$page + 1]]
  })
  output$nextPageButton <- renderReact({
    texts = c("Take the test!", "Next", "Next", "Next", "View Results", "Start over")
    icons = c("OpenEnrollment", "ChevronRight", "ChevronRight", "ChevronRight", "PollResults", "Refresh")
    DefaultButton.shinyInput("nextPage", iconProps = list("iconName" = icons[vals$page + 1]), text = texts[vals$page + 1], size=5)
  })
  
  observeEvent(input$nextPage, { vals$page <- (vals$page + 1) %% PAGE_COUNT })
  
  output$analysis <- renderUI({
    totalChecked <- sum(unlist(purrr::map(categories, function(category) {
      values <- purrr::map(1:4, function(id) { input[[questionInputId(category, id)]] } )
      sum(unlist(values))
    })))
    score <- min(which(totalScoreGuideThresholds >= totalChecked))
    totalScoreDescription <- totalScoreGuide[score]
    
    
    categoryResults <- purrr::map(categories, function(category) {
      values <- purrr::map(1:4, function(id) { input[[questionInputId(category, id)]] } )
      score <- sum(unlist(values))
      description <- categoryScoreGuide[score + 1]
      div(strong(category, ": ", score, " - "), description)
    })
    
    summary <- Stack(
      h2("How is your overall energy?"),
      paste("Your total score:", totalChecked),
      p(totalScoreDescription),
      h2("What do you need to work on?"),
      categoryResults
    )
    
    makeCard("Your results", summary)
  })
}

shinyApp(ui, server)