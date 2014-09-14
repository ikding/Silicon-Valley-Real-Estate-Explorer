library(shiny)
library(leaflet)
library(markdown)

vars1 <- c(
  "Home Type" = "home.type",
  "Sale Price" = "last.sale.price",
  "Square Foot" = "sqft",
  "Price per Sq.Ft." = "price.sqft"
)

vars2 <- c(
  "Sale Price" = "last.sale.price",
  "Square Foot" = "sqft",
  "Price per Sq.Ft." = "price.sqft"
)


shinyUI(navbarPage("Silicon Valley Real Estate Explorer", id="nav",

    tabPanel("Interactive map",
        div(class="outer",
      
        tags$head(
        # Include our custom CSS
            includeCSS("styles.css"),
            includeScript("gomap.js")
        ),
      
        leafletMap("map", width="100%", height="100%",
            initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
            initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
            options=list(center = c(37.32, -121.9),
                zoom = 11,
                maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481))
            )
        ),
      
        absolutePanel(id = "controls", class = "modal", fixed = TRUE, draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",width = 330, height = "auto",
        
            h2("Housing Explorer"),
            
            selectInput("color", "Color", vars1, selected = "last.sale.price"),
            selectInput("size", "Size", vars2, selected = "sqft"),
            
            plotOutput("histPrice", height = 250),
            plotOutput("tSeriesPrice", height = 300)
        ),
        
        tags$div(id="cite", 'Data compiled for ', tags$em('Developing Data Products - Coursera class'), ' by I-Kang Ding.'
        )
    )
),
# 
    tabPanel("Documentation",
             includeMarkdown("instruction.md")
#              includeText("instruction.txt")
             ),
  
    conditionalPanel("false", icon("crosshair"))
))
