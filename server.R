#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#   
#    http://shiny.rstudio.com/
#
library(googleVis)
require(shiny)
require(reshape2)
## Prepare data to be displayed
## Load demographic data
library(scales)

demographics <- read.csv("DP_LIVE_26092017133214583.csv")
codes <- read.csv("Country_List_ISO.csv")

names(demographics)[1] <- "LOCATION"
demographics2 <-  dcast(demographics,  TIME+LOCATION+SUBJECT~MEASURE, value.var = "Value")
codes$LOCATION <- codes$Alpha.3.code
demographicsTot <- demographics2[demographics2$SUBJECT == "TOT",]
demographicsMW <- demographics2[demographics2$SUBJECT == "MEN",]
demographicsWomen <- demographics[demographics2$SUBJECT == "WOMEN",]

data <- merge(x=  demographicsTot, y= codes, by = "LOCATION", all.y = FALSE)

maxPop <- max(demographicsTot$MLN_PER)
demoMW <- dcast(demographics2,  TIME+LOCATION~SUBJECT, value.var = "MLN_PER")
data2 <- merge(x=  demoMW, y= codes, by = "LOCATION", all.y = FALSE)

shinyServer(function(input, output) {
    myYear <- reactive({
        input$Year
    })
    output$year <- renderText({
        paste("Demographic data for year ", myYear())
    })
    output$worlMap <- renderLeaflet({
        myData <- subset(data, 
                         (TIME == myYear()))
        ScaleFactor <- 2000000
        myData$RADIUS <- (myData$MLN_PER / maxPop) * ScaleFactor
        myData$POPUP <- paste(myData$Country, "   ", round(myData$MLN_PER,1), " millions")
        myMap <- leaflet(myData) %>%
            addTiles() %>%
            addCircles(lat = ~Latitude..average. , lng = ~Longitude..average. 
                       , radius = ~RADIUS , popup = ~POPUP, weight = 1, color = 'green')
        myMap
        
    })
    output$genderMap <- renderLeaflet({
        myData <- subset(data2, 
                         (TIME == myYear()))
        myData$WOMEN[is.na(myData$WOMEN)] <- 0
        myData$MEN[is.na(myData$MEN)] <- 0
        
        myData$prevalence <- myData$WOMEN/myData$MEN-1
        myData <- myData[!is.na(myData$prevalence),]
        ScaleFactor <- 1000000
        scale <- c('blue','#FF69B4')
        myData$Color <- scale[((sign(myData$prevalence)+1)/2)+1]
        myData$RADIUS <- ((myData$prevalence / 0.33) * ScaleFactor)
        myData$POPUP <- paste(myData$Country, "  ", percent(myData$prevalence), " Female prevalence ")
        myMap <- leaflet(myData) %>%
            addTiles() %>%
            addCircles(lat = ~Latitude..average. , lng = ~Longitude..average. 
                       , radius = ~RADIUS , popup = ~POPUP, weight = 1, color = ~Color)
        myMap
        
    })
    output$centerMap <- renderLeaflet({
        myData <- subset(data2, 
                         (TIME == myYear()))
        myData$TOT[is.na(myData$TOT)] <- 0
        latTOT <- weighted.mean(myData$Latitude..average.,myData$TOT)
        longTOT <- weighted.mean(myData$Longitude..average.,myData$TOT)
        
        myMap <- leaflet() %>%
            addTiles() %>%
            setView(lat = latTOT, lng =longTOT, zoom = 2) %>%
            addMarkers(lat = latTOT, lng = longTOT
                       , popup = paste( "Center of mass for world population   lat : ",round(latTOT,2), " - lng : ", round(longTOT,2)) )
        myMap
        
    })
})