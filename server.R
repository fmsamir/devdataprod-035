library(shiny)
library(ggplot2)
library(manipulate)

bmi <- function(system, height, weight){
    if (system == "inch, pound"){
        weight/height^2 * 703
    } else {
        weight/height^2
    }
}

func1 <<- function(x){sqrt(703 * x/18.5)}
func2 <<- function(x){sqrt(703 * x/25)}
func3 <<- function(x){sqrt(703 * x/30)}


shinyServer(function(input, output){
    output$bmi <- renderText({
      input$goButton
      isolate(round(bmi(input$system, input$height, input$weight), digits = 3))
      })
    
    dfworld <- eventReactive(input$goButton, 
                           {data.frame(weight = seq(10, 250, length = 1000), 
                                       height = seq(0, 3, length = 1000))
                           })
    
    dfusa <- eventReactive(input$goButton, 
                           {data.frame(weight = seq(20, 500, length = 1000), 
                                       height = seq(20, 100, length = 1000))
                           })
    
    pf <- eventReactive(input$goButton,
                        {data.frame(w = input$weight,
                                    h = input$height)
                        })
    
    output$message <- renderText({
      input$goButton
      isolate(if (18.5 <= bmi(input$system, input$height, input$weight) 
               & bmi(input$system, input$height, input$weight) < 25){
      "Your weight is good!"}
      else if (25 <= bmi(input$system, input$height, input$weight)){
          if (input$system == "inch, pound"){ 
          paste("You should lose ", 
                round(input$weight - 25/703*input$height^2, 3), "pounds.")}
          else if (input$system == "meter, kilogram") {
          paste("You should lose ", 
                round(input$weight - 25*input$height^2, 3), "kilograms.")}}
      else if (0 < bmi(input$system, input$height, input$weight) 
               & bmi(input$system, input$height, input$weight) < 18.5){
          if (input$system == "inch, pound"){ 
              paste("You should gain ", 
                    round(18.5/703*input$height^2 - input$weight, 3), "pounds.")}
          else if (input$system == "meter, kilogram") {
              paste("You should gain ", 
                    round(18.5*input$height^2 - input$weight, 3), "kilograms.")}}
    )
    })
    
    output$plotworld <- renderPlot({ggplot(dfworld(), aes(x = weight, y = height)) + 
            geom_blank() +
            geom_point(data = pf(), aes(x = w, y = h), size = 3) +
            stat_function(fun = function(x)(sqrt(x/18.5)), lwd = 1.25) + 
            stat_function(fun = function(x)(sqrt(x/25)), lwd = 1.25) + 
            stat_function(fun = function(x)(sqrt(x/30)), lwd = 1.25) + 
            geom_ribbon(aes(ymin = (1/sqrt(703)) * func3(weight), 
                            ymax = (1/sqrt(703)) * func2(weight)), 
                        fill = "orangered", alpha = 0.7) + 
            geom_ribbon(aes(ymin = (1/sqrt(703)) * func1(weight), ymax = 3), 
                        fill = "seagreen", alpha = 0.7) + 
            geom_ribbon(aes(ymin = 0, ymax = (1/sqrt(703)) * func3(weight)), 
                        fill = "red", alpha = 0.7) + 
            scale_x_continuous(limits = c(10, 250)) + 
            scale_y_continuous(limits = c(0, 3)) + 
            xlab("weight (kilograms)") + 
            ylab("height (meters)")
    })
    
    output$plotusa <- renderPlot({ggplot(dfusa(), aes(x = weight, y = height)) + 
            geom_blank() +
            geom_point(data = pf(), aes(x = w, y = h), size = 3) +
            stat_function(fun = func1, lwd = 1.25) + 
            stat_function(fun = func2, lwd = 1.25) + 
            stat_function(fun = func3, lwd = 1.25) + 
            geom_ribbon(aes(ymin = func3(weight), ymax = func2(weight)), 
                        fill = "orangered", alpha = 0.7) + 
            geom_ribbon(aes(ymin = func1(weight), ymax = 97), 
                        fill = "seagreen", alpha = 0.7) + 
            geom_ribbon(aes(ymin = 22, ymax = func3(weight)), 
                        fill = "red", alpha = 0.7) + 
            scale_x_continuous(limits = c(20, 400)) + 
            scale_y_continuous(limits = c(20, 97)) +
            xlab("weight (pounds)") + 
            ylab("height (inches)")
    })
})