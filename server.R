library(shiny)
library(ggmap)
library(dplyr)
library(lubridate)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # create data subset based on specified condition
    # and then create subset of max 1000 points
    myFilteredData <- reactive({
        minyear <- input$year[1]
        maxyear <- input$year[2]
        
        subdata <- data %>%
            filter(
                year(Week) >= minyear,
                year(Week) <= maxyear
            )
        
        if (input$category != "All") {
            subdata <- subdata %>% filter(Category == input$category)
        }
        
        if (input$descript != "All") {
            subdata <- subdata %>% filter(Descript == input$descript)
        }
        
        if (input$dayOfWeek != "All") {
            subdata <- subdata %>% filter(DayOfWeek == input$dayOfWeek)
        }
        
        if (input$district != "All") {
            subdata <- subdata %>% filter(PdDistrict == input$district)
        }
        
        if (input$resolution != "All") {
            subdata <- subdata %>% filter(Resolution == input$resolution)
        }
        
        if (input$partOfDay != "All") {
            subdata <- subdata %>% filter(PartOfDay == input$partOfDay)
        }
        
        subdata
    })
    
    myColoredData <- reactive({
        # create color column
        clr <- input$colorBy
        smpl <- myFilteredData()
        smpl$clr <- smpl[[clr]]
        
        # leave top7 categories and mark other as other
        smpl$clr <- factor(smpl$clr, c(levels(smpl$clr), "Other"))     # add new factor level
        other <- (smpl %>% group_by(clr) %>% dplyr::summarise(n=n()) %>% arrange(-n))[-(1:7),]$clr
        if(length(other)>1) {                                          # replace less frequents ctgs by "Other"
            smpl[smpl$clr %in% other, "clr"] <- "Other"
        }
        smpl
    })
    
    myColoredSample <- reactive({
        subdata <- myColoredData()
        n <- min(nrow(subdata), 1000)
        dplyr::sample_n(subdata, n)
    })
    
    # generates the map with cases
    output$mapPlot <- renderPlot({
        ggmap(map, extent='normal', darken=c(0.5,"black")) +
            geom_point(aes(x=X, y=Y, color=clr), size=2, data=myColoredSample()) +
            scale_color_brewer(type="qual", palette = 1)
    })
    
    # generates time-series plot
    output$timePlot <- renderPlot({
        d <- myColoredData() %>% select(Week,clr)
        
        # this will add 1 to every /week/clr summary
        # we will then subtract it from n()
        # as a result we will add a zero measurement
        m <- merge( unique(data$Week), unique(d$clr) ) %>%
                filter(
                    year(x) >= input$year[1],
                    year(x) <= input$year[2]
                )
        names(m) <- c("Week", "clr")
        d <- rbind(d,m)
        d <- d %>% group_by(Week,clr) %>% dplyr::summarise(n=n()-1)
        
        ggplot(aes(x=Week, y=n, color=clr), data=d) + geom_line() +
            scale_color_brewer(type="qual", palette = 1)
    })
})