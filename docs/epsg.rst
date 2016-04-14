EPSG code refers to a standard code that identifies the projection of a 
geospatial dataset,  a raster or vector dataset depicting values on the earth.  
Geospatial data must have a ‘projection’ in order to represent a round earth on 
a flat map.  Different projections are appropriate for different areas  of the 
world and the sizes of those areas.  We use a simple “longitude-latitude” 
projection, with an EPSG code of 4326.  This is not a true projection, but 
flattens the earth as if every degree of latitude and longitude were exactly 
the same size (when actually, one degree of latitude at the north/south pole is 
much smaller than one degree at the equator).   

Here are some links about projections and EPSG codes:
https://en.wikipedia.org/wiki/World_Geodetic_System
http://www.epsg.org/
http://spatialreference.org/ref/epsg/4326/

If you specify EPSG 4326 and make sure the longitude and latitude of your data 
is in decimal degrees, you will be able to use the default climate layersets 
that we make available.  

Further information about the data we expect can be found at the “Lifemapper 
Tools” (upper right), “Web Services” (left menu) section of the Lifemapper 
website, http://lifemapper.org/?page_id=578.  Here is the page on Occurrence Set 
data, in case you have trouble with the expected format:  
http://lifemapper.org/?page_id=117 .  Layersets are more complex, so I suggest 
that you use those available (EPSG 4326, Worldclim and predicted future layers) 
until you are more comfortable with the data.  
