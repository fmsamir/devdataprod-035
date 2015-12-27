library(shiny)
library(markdown)

shinyUI(
    pageWithSidebar(
    headerPanel("Body Mass Index Calculator"), 
    sidebarPanel(
        p("You can input your body statistics and measurement unit preference 
          below then click the 'Submit' button to calculate your 
          body mass index (BMI)."),
        selectizeInput("system", label = "Please select your measurement units.", 
                       choices = c("meter, kilogram", "inch, pound"), 
                       options = list(placeholder = "", 
                        onInitialize = I('function() { this.setValue(""); }'))),
        numericInput("height", "Please input your height.", 1, min = 1, max = 100),
        numericInput("weight", "Please input your weight.", 0, min = 0, max = 400),
        actionButton("goButton", "Submit")), 
    mainPanel(tabsetPanel(
        tabPanel("Results", h3("Your BMI is:"),
              textOutput("bmi"),
              br(),
              textOutput("message"),
              br(),
              conditionalPanel(condition = "input.system == 'meter, kilogram'",
                  plotOutput("plotworld")),
              conditionalPanel(condition = "input.system == 'inch, pound'",
                  plotOutput("plotusa"))),
        tabPanel("Help", includeMarkdown("help.Rmd"))))))