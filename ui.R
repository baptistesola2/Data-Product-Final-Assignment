require(shiny)
library(leaflet)

shinyUI(pageWithSidebar(
    headerPanel("World Demographics Evolution from 1950 to 2013"),
    sidebarPanel(
        h4("Please move the slider or press Play to see the evolution of demographic data from year to year"),
        sliderInput("Year", "Year to be displayed:", 
                    min=1950, max=2013, value=2013,  step=1,
                    animate=TRUE)
    ),
    mainPanel(
        tabsetPanel(type = "tabs",
            tabPanel(h4("World map"), h3(textOutput("year")), 
                     h4("This panel lets you see the population for each country (in million)"),
                     h5("Size is related to population (in millions). Click on the circle to for more information"),
                     leafletOutput("worlMap")),
            tabPanel(h4("Population center of mass")
                     , h4("This panel lets you see the population center of mass on a given year.")
                     , h5("Ths is computed as the weighted mean of countrys coordinates by countrys population")
                     ,leafletOutput("centerMap")),
            tabPanel(h4("Gender Prevalence")
                     ,h4("This panel lets you see the prevalence of Gender for each country")
                     ,h5("Pink indicates a Female prevalence, blue for Male prevalence, the size is related to the amount of prevalence")
                     , leafletOutput("genderMap"))
        )
    )
)
)