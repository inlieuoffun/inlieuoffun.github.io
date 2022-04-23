import { SearchIndex } from './modules/search.js';

var searchIndex = new SearchIndex('textindex.json');  

// filterSet indicates which episodes should be shown.  If it is empty all
// episodes should be shown; otherwise it contains a set of episode numbers to
// be made visible as search results.
var filterSet = new Set();

// isSelected reports whether the given episode tag should be visible given the
// current filter set.
function isSelected(ep) {
    return filterSet.size == 0 || filterSet.has(ep);
}

// updateVisible updates the visibility of each episode row according to the
// current state of the filter set.
function updateVisible() {
    for (const row of document.getElementsByClassName('erow')) {
        row.style.display = isSelected(row.dataset.tag) ? '' : 'none';
    }
}

const queryInput  = document.getElementById("query-input"); 
const clearButton = document.getElementById("clear-filter");
const showQuery   = document.getElementById("show-query");
const queryText   = document.getElementById("show-query-content");

// updateQuery checks the contents of the query input and updates the current
// filter state.
async function updateQuery(e) {
    if (e.key != 'Enter') { return; }
    
    const query = queryInput.value.trim();
    if (query == "") {
        clearQuery(e);
        return;
    }
    const terms = await searchIndex.parseQuery(query);
    const match = await searchIndex.matchTerms(terms);
    if (match.size == 0) {
        alert("No results matching '"+query+"'");
    } else {
        filterSet = match;
        updateUI();
        updateVisible();
    }
}

// clearQuery resets the current query to empty and removes the filter.
async function clearQuery(e) {
    queryInput.value = '';
    if (filterSet.size > 0) {
        filterSet = new Set();
        updateVisible();
    }
    updateUI();
}

// updateUI updates the state of the search UI components to reflect the
// current state of the query.
function updateUI() {
    const isFiltered = filterSet.size > 0;
    clearButton.disabled = !isFiltered
    showQuery.style.visibility = isFiltered ? 'visible' : 'hidden';
    queryText.innerHTML = isFiltered ? queryInput.value : 'none';
}

// Hook up event listeners and initialize the UIL.
clearButton.addEventListener("click", clearQuery);
queryInput.addEventListener("keyup", updateQuery);
updateUI();
