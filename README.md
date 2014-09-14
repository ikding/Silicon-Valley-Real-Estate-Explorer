## Documentation for Silicon Valley Real Estate Explorer

This shiny app explores the historial housing transaction data in Santa Clara County, California, U.S.A. (colloquially known as "Silicon Valley") from 07/01/2011 to 09/01/2014. The raw data is downloaded from real estate websites. The data set only includes 10,000 transactions, which represents less than 30% of all the trasactions during this time frame. The reduction in sample size was necessary to speed up the rendering of circles on map.

Each circle on the map indicates a particular transaction at a specific address. There are two attributes, color and size, for the circle; each attribute can be mapped to one of the four variables:

1. Home Type: there are five levels in this factor: Condo, Townhouse, Single Family Residential, Mobile/Manufacturered Home, and Multi-Family. This variable is only available for mapping to the "color" attribute, not for "size".

2. Sale Price: Last sale price as listed on the transaction record. Currency is in US Dollars. 

3. Square Foot: The area, in square foot, of the house.

4. Price per Sq.Ft.: price (in dollars) per square foot of the house area.

For variable #2-4 (which are continuous variables), if they are used to map "color" attribute, the continuous variable will first be converted into 7 factor levels, each containing approximately same number of observations. If they are used to map "size" attribute, the size will be a continuous value that scales from 0 to the maximum value of the selected variable.

The side panel also contains three additional graphs:
- Histogram of last sale price
- Histogram of price per sq.ft
- Smooth fit (Loess) of the last sale price versus date, broken down by home type.

The graphs are reactive to the map boundaries - the data used in these three graphs only include the visilbe houses on the map.

Lastly, the good folks at RStudio are acknowledged for making the code of ["SuperZip" shiny app](http://shiny.rstudio.com/gallery/superzip-example.html) available. This Housing Explorer shiny app borrowed a significant portion from of the SuperZip code structure.