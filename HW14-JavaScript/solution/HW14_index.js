// appends a table to your web page and then adds new rows of 
// data for each UFO sighting.
// data.js defines a single variable called dataSet
// dataSet contains an array of dictionaries, defining each 
// attribute of the sighting.  
// Set your sightings = the dataSet
var sightings = dataSet;

var $tbody = document.querySelector("tbody");
var $searchBtn = document.querySelector("#searchButton");
$searchBtn.addEventListener("click", handleSearchButtonClick);

var $resetBtn = document.querySelector("#resetButton");
$resetBtn.addEventListener("click", clearFilter);
var $dateTimeFilterInput = document.querySelector("#dateTimeFilterInput");

var $stateDropdown = document.querySelector("#stateDropdown");
var $countryDropdown = document.querySelector("#countryDropdown");

var $pageList = document.querySelector("#pageList");
var rowsPerPage = 1000;

// renderTable renders the filteredAddresses to the tbody
function renderTable(startIndex, endIndex) {
  console.log('rendering ',startIndex, endIndex);
  $tbody.innerHTML = "";
  var rowIndex = 0;

  if (endIndex>sightings.length){
    endIndex= sightings.length;
  }
  // for (var i = 0; i < sightings.length; i++) {
    for (var i=startIndex; i< endIndex; i++) {
    // Get get the current address object and its fields
    var rowData = sightings[i];
    var sightingDatetime = rowData.datetime;
    var city = rowData.city;
    var state = rowData.state;
    var country = rowData.country;
    var shape = rowData.shape;

    // continue
    // Create a new row in the tbody, set the index to be i + startingIndex
    var $row = $tbody.insertRow(rowIndex);

      // For every field in the address object, create a new cell at set its inner text to be the current value at the current address's field
      
      var $datetimecell = $row.insertCell(0);
      $datetimecell.innerText = sightingDatetime;

      var $citycell = $row.insertCell(1);
      $citycell.innerText = city;

      var $statecell = $row.insertCell(2);
      $statecell.innerText = state;

      var $countrycell = $row.insertCell(3);
      $countrycell.innerText = country;

      var $shapecell = $row.insertCell(4);
      $shapecell.innerText = shape;
      rowIndex++;
  }
}

function handleSearchButtonClick(){
	var dateTimeFilterTerm = $dateTimeFilterInput.value.trim().toLowerCase();
console.log("search by ", dateTimeFilterTerm);

var stateFilterTerm = $stateDropdown.value;
console.log("state filter", stateFilterTerm);

var countryFilterTerm = $countryDropdown.value;

	var filteredResult = sightings.filter(function(rowData){
		console.log('checking ', dateTimeFilterTerm,', data:' ,rowData.datetime)
		return (rowData.datetime===dateTimeFilterTerm 
      || rowData.state===stateFilterTerm
    || rowData.country===countryFilterTerm );

	})	;

	sightings = filteredResult;
  $pageList.innerHTML = "";
	renderTable(0,rowsPerPage);
  renderPageList();
}

function renderPageList(){
  var totalRows = sightings.length;
  
  var numberOfPages = Math.round(totalRows/rowsPerPage);
  console.log('totalRows', sightings.length, ', numberOfPages', numberOfPages);
  for (var i=0; i<numberOfPages;i++){
    var pageItem = document.createElement("li");
    var pageLink = document.createElement("a");
    var pageNumber = i+1;
    var textNode = document.createTextNode(pageNumber);
    pageLink.appendChild(textNode);
    pageLink.setAttribute('href', "#");
    pageItem.appendChild(pageLink);
    $pageList.appendChild(pageItem);
    // console.log('eventlistener param', pageNumber);
    pageLink.addEventListener("click", renderPage);
  }

  function renderPage(){
    console.log(this);
    var pageNumber = this.text;
    console.log('clicked on ', pageNumber);
    var startIndex = rowsPerPage*(pageNumber-1);
    var endIndex = rowsPerPage*(pageNumber);
    renderTable(startIndex, endIndex);
  }
}

function renderStateDropdown(){
  console.log(stateDataSet.length);
 for(var i=0; i<stateDataSet.length;i++){
  var option = document.createElement("option");
  option.text = stateDataSet[i].abbreviation.toLowerCase();
  option.value = stateDataSet[i].abbreviation.toLowerCase();
  $stateDropdown.add(option);
 }
}



function clearFilter(){
	sightings = dataSet;
  renderPageList();
	renderTable(0, rowsPerPage);
}


renderPageList();
renderStateDropdown();
renderTable(0, rowsPerPage);