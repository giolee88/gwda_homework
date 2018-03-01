selectSample();

function selectSample() {
    var route = "/names";

    d3.json(route, function(error, response) {
        if (error) return console.warn(error);

        var data = response;

        var dropdown = d3.select("#dropdown");
        dropdown
            .append("select")
            .attr("id", "selDataset")
            .on("change", optionChanged)
            .selectAll("option")
            .data(data)
            .enter()
            .append("option")
            .attr("value", d => d)
            .text(d => d);
    });
}

function optionChanged() {
    let value = document.getElementById(this.id).value;

    metadataPanel(value);
    piePlot(value);
    bubblePlot(value);
}

function metadataPanel(sample) {
    let element = document.getElementById("infopanel");
    element.innerHTML = "";

    var route = "/metadata/"+ sample;

    d3.json(route, function(error, response) {
        if (error) return console.warn(error);

        var data = response;
        var panel = d3.select("#infopanel");

        panel.append("p").text("AGE: " + data.AGE);
        panel.append("p").text("BBTYPE: " + data.BBTYPE);
        panel.append("p").text("ETHNICITY: " + data.ETHNICITY);
        panel.append("p").text("GENDER: " + data.GENDER);
        panel.append("p").text("LOCATION: " + data.LOCATION);
        panel.append("p").text("SAMPLEID: " + data.SAMPLEID);
    });
}

function piePlot(sample) {
    let element = document.getElementById("pie");
    element.innerHTML = "";

    var route = "/samples/" + sample;

    Plotly.d3.json(route, function(error, response) {
        if (error) return console.warn(error);

        var vals = response.sample_values;
        var ids = response.otu_ids;

        var data = [{
            values: vals,
            labels: ids,
            type: "pie"
        }];

        var layout = {
            title: "Top 10 Belly Button Bacteria",
            height: 600,
            width: 800
        };

        var PIE = document.getElementById("pie");
        Plotly.newPlot(PIE, data, layout);

    })
}

function bubblePlot(sample) {
    let element = document.getElementById("bubble");
    element.innerHTML = "";

    var route = "/samples/" + sample;

    Plotly.d3.json(route, function(error, response) {
        if (error) return console.warn(error);

        var vals = response.sample_values;
        var val_size = vals.map(x => x+10);
        var ids = response.otu_ids;

        var trace1 = {
            x: ids,
            y: vals,
            mode: "markers",
            marker: {
                size: val_size,
                color: ids,
                colorscale: "Portland"
            }
        };

        var data = [trace1];

        var layout = {
            title: "Top 10 Bacteria",
            showlegend: false
        };

        var BUBBLE = document.getElementById("bubble");
        Plotly.newPlot(BUBBLE, data, layout);
    })
}
