library(shiny)
library(leaflet)
library(plyr)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(markdown)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate

d <- subset(housingData, last.sale.date >= as.Date("2011-07-01") & last.sale.date <= Sys.Date())
set.seed(100)
d <- d[sample.int(nrow(d), 10000),]

shinyServer(function(input, output, session) {
  
    ## Interactive Map ###########################################

    # Create the map
    map <- createLeafletMap(session, "map")
  
    # A reactive expression that returns the set of zips that are
    # in bounds right now
    houseInBounds <- reactive({
        if (is.null(input$map_bounds))
            return(d[FALSE,])
        bounds <- input$map_bounds
        latRng <- range(bounds$north, bounds$south)
        lngRng <- range(bounds$east, bounds$west)
    
        subset(d,
               latitude >= latRng[1] & latitude <= latRng[2] &
                   longitude >= lngRng[1] & longitude <= lngRng[2]
               )
    })
  
    # Pre-assign the breaks we'll need for the two histograms

    priceBreaks <- seq(0, 3000000, 100000)
    priceSqftBreaks <- seq(0, 1500, 100)

    output$histPrice <- renderPlot({
    
        # If no houses are in view, don't plot
        if (nrow(houseInBounds()) == 0)
            return(NULL)
    
        par(mfrow=c(1,2),oma=c(0,0,0,0),mar=c(4,1,3,0))
        hist(subset(houseInBounds()$last.sale.price, houseInBounds()$last.sale.price < 3000000),
             breaks = priceBreaks,
             main = "Last Sale Price\n(visible houses)",
             xlab = "Price",
             xlim = c(0, 3000000),
             col = '#00DD00',
             border = 'white')

        hist(subset(houseInBounds()$price.sqft, houseInBounds()$price.sqft < 1500),
             breaks = priceSqftBreaks,
             main = "Price / Sq.Ft.\n(visible houses)",
             xlab = "price/sqft",
             xlim = c(0, 1500),
             col = '#00DD00',
             border = 'white')

    })
    
    output$tSeriesPrice <- renderPlot({
        # If no houses are in view, don't plot
        if (nrow(houseInBounds()) == 0)
            return(NULL)
    
        p <- ggplot(data = subset(houseInBounds())) + theme_bw()
        p <- p + geom_smooth(aes(x = as.Date(last.sale.date), y = last.sale.price, color = home.type))
        p <- p + scale_x_date(labels = date_format("%Y-%m"))
        p <- p + scale_y_continuous(labels = dollar)
        p <- p + scale_color_brewer(palette = "Set1", name = "Type", labels = c("Condo", "TH", "SFR", "Mobile", "Multi"))
        p <- p + theme(legend.position="top")
        p <- p + xlab("Last Sale Date") + ylab("Last Sale Price")
        print(p)
    })  
    
  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created.
    session$onFlushed(once=TRUE, function() {
        
        paintObs <- observe({
        colorBy <- input$color
        sizeBy <- input$size


        if (colorBy == "home.type") {
            colors <- brewer.pal(7, "Set1")[housingData$home.type]
        } else {
            colorData <- housingData[[colorBy]]
            colors <- brewer.pal(7, "Spectral")[cut_number(colorData, 7, labels = FALSE)]
        }
        
        colors <- colors[match(d$redfinUrl, housingData$redfinUrl)]
      
    # Clear existing circles before drawing
        map$clearShapes()

        try(

            map$addCircle(d$latitude, d$longitude,
                            (d[[sizeBy]] / max(d[[sizeBy]])) * 1000,
                            as.character(d$redfinUrl),
                            list(stroke=FALSE, fill=TRUE, fillOpacity=0.4),
                            list(color = colors)  
            )
        )
#       
        })
    
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
        session$onSessionEnded(paintObs$suspend)
    })
  
  # Show a popup at the given location
    showHousePopup <- function(url, lat, lng) {
        selectedUrl <- housingData[housingData$redfinUrl == url,]
        content <- as.character(tagList(
            tags$strong(HTML(sprintf("%s, %s, %s %s",selectedUrl$address, selectedUrl$city, selectedUrl$state, selectedUrl$zip))), tags$br(),
            sprintf("Home Type: %s", selectedUrl$home.type), tags$br(),
            sprintf("%s Bd/%s Ba", selectedUrl$beds, selectedUrl$baths), tags$br(),
            sprintf("Last Sale Price: %s", dollar(selectedUrl$last.sale.price)), tags$br(),
            sprintf("Square Feet: %s", selectedUrl$sqft), tags$br(),
            sprintf("Price/SqFt: %s", round(selectedUrl$price.sqft, 0)), tags$br(),
            sprintf("Last Sale Date: %s", selectedUrl$last.sale.date), tags$br(),
            sprintf(selectedUrl$redfinUrl)
        ))
        map$showPopup(lat, lng, content)

    }

    # When map is clicked, show a popup with city info
    clickObs <- observe({
        map$clearPopups()
        event <- input$map_shape_click
        if (is.null(event))
            return()
    
        isolate({
            showHousePopup(event$id, event$lat, event$lng)
        })
    })
  
    session$onSessionEnded(clickObs$suspend)
  
})
