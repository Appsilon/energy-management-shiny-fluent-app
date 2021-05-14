library(dplyr)
library(ggplot2)
library(glue)
library(leaflet)
library(plotly)
library(sass)
library(shiny)
library(shiny.fluent)
library(shiny.router)

#shiny.react::enableReactDebugMode()

source("questions_and_results.R")

makeCard <- function(title, content, size = 10, style = "") {
  div(class = glue("card ms-depth-8 ms-sm{size} ms-xl{size}"),
      style = style,
      Stack(
        tokens = list(childrenGap = 5),
        if (!is.null(title)) Text(variant = "xLarge", title, block = TRUE) else NULL,
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
  makeCard(title, questionsInputs, size = 10, style = "maxHeight: 320px")
}

bodyQuestionsCard <- makeQuestionsCard("Body", bodyQuestions)
mindQuestionsCard <- makeQuestionsCard("Mind", mindQuestions)
emotionsQuestionsCard <- makeQuestionsCard("Emotions", emotionsQuestions)
spiritQuestionsCard <- makeQuestionsCard("Spirit", spiritQuestions)

analysis_page <- makePage(
  "Are You Headed for An Energy Crisis?",
  "Take the test to find out.",
  Stack(
    tokens = list(childrenGap = 12),
    reactOutput("page"),
    reactOutput("nextPageButton")
  )
)

sass(
  sass_file("my_style.scss"),
  output = "www/my_style.css"
)

header <- tagList(
  img(src = "appsilon-logo.png", class = "logo"),
  div(Text(variant = "xLarge", "Managing Energy, Not Time, Is the Key to High Performance and Personal Renewal"), class = "title"))


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
                        Text(variant = "mediumPlus",
                          p("Many of us struggle with juggling all of the important areas of life. We often try to manage our time better to avoid burnout, but it’s often the case that energy management is more critical than time management. This app helps you take a quick test to see how you're doing with managing your energy. The app also provides suggestions and action points for improving your energy management."),
                          p("As Tony Schwartz and Catherine McCarthy wrote in their famous ",
                            a("HBR article,", href="https://hbr.org/2007/10/manage-your-energy-not-your-time")),
                          Text(variant = "xxLarge", block = TRUE, tags$em("The core problem with working longer hours is that time is a finite resource. Energy is a different story. Defined in physics as the capacity to work, energy comes from four main wellsprings in human beings: the body, emotions, mind, and spirit. '")),
                          p("It turns out that managing your energy, not your time, is the key to a happy and productive life. Take this test to find out where you are currently and which areas you can improve.")
                        ),
                        size = 10, style = "maxHeight: 320px")
                        

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
    score <- min(which(totalScoreGuideThresholds > totalChecked))
    totalScoreDescription <- totalScoreGuide[score]
    title <- resultsTitles[score]
    recommendation <- recommendations[score]
    
    
    categoryResults <- purrr::map(categories, function(category) {
      values <- purrr::map(1:4, function(id) { input[[questionInputId(category, id)]] } )
      score <- sum(unlist(values))
      description <- categoryScoreGuide[score + 1]
      Text(variant="mediumPlus", strong(category, ": ", score, " - "), description, block=TRUE)
    })
    
    summary <- Stack(
      tokens = list(childrenGap = 20),
      Text(variant="mega", title),
      Text(variant="mediumPlus", "Your total score is ", Text(variant="xLarge", paste0(totalChecked, " out of 16."))),
      Text(variant="mediumPlus", "This means you have ", Text(variant="xLarge", totalScoreDescription)),
      Text(variant="xxLarge", "Recommendation"),
      Text(variant="mediumPlus", recommendation),
      Text(variant="xxLarge", "What areas do you need to work on?"),
      div(categoryResults)
    )
    
    makeCard(NULL, summary)
  })
}

shinyApp(ui, server)