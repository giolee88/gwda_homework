// Earthquake url
var EarthquakeUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"

// Tectonic  url
var TectonicUrl = "https://raw.githubusercontent.com/fraxen/tectonicplates/master/GeoJSON/PB2002_boundaries.json"

// Perform a GET request to the Earthquake query URL
d3.json(EarthquakeUrl, function(data) {
    // Once we get a response, send the data.features object to the createFeatures function
    createFeatures(data.features);
});


function createFeatures(earthquakeData) {       

    // Create a GeoJSON layer containing the features array on the earthquakeData object
  // Run the onEachFeature function once for each piece of data in the array
// from the api documenytion 
var earthquakes = L.geoJson(earthquakeData, {
    onEachFeature: function (feature, layer){
      layer.bindPopup("<h3>" + feature.properties.place + "<br> Magnitude: " + feature.properties.mag +
      "</h3><hr><p>" + new Date(feature.properties.time) + "</p>");
    },
    pointToLayer: function (feature, latlng) {
      return new L.circle(latlng,
        {radius: getRadius(feature.properties.mag),
          fillColor: getColor(feature.properties.mag),
          fillOpacity: .6,
          stroke: true,
          color: "black",
          weight: .6
      })
    }
  });

  // Sending our earthquakes layer to the createMap function
  createMap(earthquakes)
}

function createMap(earthquakes) {

  // Define map layers
  var satelliteMap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lvbGVlODgiLCJhIjoiY2plYmpvdnl5MGF3bTJ4b2Q2Z2E3aXdmdSJ9.N4Pep-QJerXNb-Fq0BLnuA");
  var outdoorMap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/outdoors-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lvbGVlODgiLCJhIjoiY2plYmpvdnl5MGF3bTJ4b2Q2Z2E3aXdmdSJ9.N4Pep-QJerXNb-Fq0BLnuA");
  var lightMap = L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZ2lvbGVlODgiLCJhIjoiY2plYmpvdnl5MGF3bTJ4b2Q2Z2E3aXdmdSJ9.N4Pep-QJerXNb-Fq0BLnuA");

  

  // Define a baseMaps object to hold our base layers
  var baseMaps = {
    "Satellite Map": satelliteMap,
    "Outdoor Map": outdoorMap,
    "Light Map": lightMap
  };

  // Add a layer to hold tectonic plate details
  var tectonicPlates = new L.LayerGroup();

  // Create overlay object to hold our overlay layer
  var overlayMaps = {
    Earthquakes: earthquakes, // base layer
    "Tectonic Plates": tectonicPlates  // the tectonic plate layergroup
  };

  // Create our map, giving it the default map and  earthquakes layers to display on load
  var myMap = L.map("map", {
    center: [31.09, -95.71],
    zoom: 5,
    layers: [lightMap, earthquakes, tectonicPlates]  
  });

   // Add Fault lines data
   d3.json(TectonicUrl, function(tectonicplateData) {
     // Adding our geoJSON data, along with style information, to the tectonicPlates layer.
     L.geoJson(tectonicplateData, {
       color: "yellow",
       weight: 2
     })
     .addTo(tectonicPlates);
   });

  // Create a layer control
  // Pass in our baseMaps and overlayMaps Add the layer control to the map

  L.control.layers(baseMaps, overlayMaps, {
    collapsed: false
  }).addTo(myMap);


  // Setting up the legend
  var legend = L.control({position: 'bottomleft'});
  legend.onAdd = function (myMap) {

    var div = L.DomUtil.create('div', 'info legend'),
              grades = [0, 1, 2, 3, 4, 5],
              labels = [];

  // loop through our density intervals and generate a label with a colored square for each interval
    for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
            grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
    }
    return div;
  };

  legend.addTo(myMap);
}

function getColor(d) {
  return d > 5 ? '#F30' :
  d > 4  ? '#F50' :
  d > 3  ? '#F80' :
  d > 2  ? '#FB0' :
  d > 1   ? '#FE0' :
            '#9E3';
}

function getRadius(value){
  return value*50000
}


