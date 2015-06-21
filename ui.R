library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("San Francisco Crime"),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("year", "Year:", 2003, 2015, value = c(2003, 2015)),
            selectInput("category", "Category:",
                        c("All", levels(data$Category))
            ),
            selectInput("descript", "Description:",
                        c("All", levels(data$Descript))
            ),
            selectInput("dayOfWeek", "Day of Week:",
                        c("All", levels(data$DayOfWeek))
            ),
            selectInput("district", "District:",
                        c("All", levels(data$PdDistrict))
            ),
            selectInput("resolution", "Resolution:",
                        c("All", levels(data$Resolution))
            ),
            selectInput("partOfDay", "Part of Day:",
                        c("All", levels(data$PartOfDay))
            ),
            selectInput("colorBy", "Color by:",
                        c("Category", "Descript", "DayOfWeek", "PdDistrict", "Resolution", "PartOfDay")
            )
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            includeMarkdown("doc.Rmd"),
            plotOutput("mapPlot"),
            plotOutput("timePlot")
        )
    )
))
