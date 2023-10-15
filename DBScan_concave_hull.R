##input data: sho_1314 has a column (Clusters) that reocrd the cluster fo reach observation

shp_1314$Clusters

group <- unique(shp_1314$Clusters)
group <- group[which(group>0)]

## create concave hull for each cluster
tot_hull_after <- list()
for(g in 1:length(group)){
  concave <- concaveman(subset(shp_1314, Clusters == g),concavity = 1.4)
  tot_hull_after[[g]] <- concave
}

## create the title for leaftlet interactive map
tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 10px; 
    padding-right: 10px; 
    background: rgba(255,180,255,0.75);
    font-weight: bold;
    font-size: 20px;
  }
"))



outliers_after <- as.numeric(table(st_drop_geometry(shp_1314[,'Clusters']))[1])
title <- tags$div(
  tag.map.title, HTML(c("total points:",nrow(shp_1314),
                        "distance:2700",
                        "minPts:3",
                        "outliers:",outliers_after)))  

## leaflet requires all spatial data to be supplied in lonitude and latitude using WGS84 (EPSG:4326)
a <- leaflet() %>%
  addCircles(data = shp_1314,
             color = "grey",
             radius = 0.1,fillColor = "transparent") %>%
  addPolygons(data = tot_hull_after[[30]],
              color = "red",
              fill = "red",
              fillColor = "transparent",weight = 3
              # label=as.charCacter(tot_hull_after[[30]]$cluster),
              # labelOptions = labelOptions(noHide = T,direction = "top",
              # offsCet = c(0, -15))
  )%>%
  addPolygons(data = new_boundary,
              color = "black",
              fill = "black",
              fillColor = "transparent",
              weight = 2)%>%
  addTiles() %>%
  addControl(title, position = "topleft", className="map-title")%>%
  addProviderTiles(providers$CartoDB.Positron)

a