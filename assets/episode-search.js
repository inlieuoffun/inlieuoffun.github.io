import { SearchIndex } from './modules/search.js';

const searchIndex = new SearchIndex('textindex.json');

// filterSet indicates which episodes should be shown.  If it is empty all
// episodes should be shown; otherwise it contains a set of episode numbers to
// be made visible as search results.
var filterSet = new Set();
var rawQuery = "";

// numMatches is the number of matching (visible) results.
var numMatches = 0;

// isSelected reports whether the given episode tag should be visible given the
// current filter set.
function isSelected(ep) {
    return filterSet.size == 0 || filterSet.has(ep);
}

// updateVisible updates the visibility of each episode row according to the
// current state of the filter set.
function updateVisible() {
    numMatches = 0;
    for (const row of document.getElementsByClassName('erow')) {
        const ok = isSelected(row.dataset.tag);
        row.style.display = ok ? '' : 'none';
        if (ok) { numMatches += 1; }
    }
}

const queryInput  = document.getElementById("query-input");
const clearButton = document.getElementById("clear-filter");
const showQuery   = document.getElementById("show-query");
const queryText   = document.getElementById("show-query-content");
const rawText     = document.getElementById("raw-query");

async function updateQueryOnEnter(e) {
    if (e.key == 'Enter') {
        updateQuery(queryInput.value.trim());
    }
}

// updateQuery checks the contents of the query input and updates the current
// filter state.
async function updateQuery(query) {
    if (query == "") {
        clearQuery();
        return;
    }
    const terms = await searchIndex.parseQuery(query);
    const match = await searchIndex.matchTerms(terms);
    if (match.size == 0) {
        alert("No results matching '"+query+"'");
    } else {
        filterSet = match;
        rawQuery = terms.join(' ');
        updateVisible();
        updateUI();
    }
}

// clearQuery resets the current query to empty and removes the filter.
async function clearQuery() {
    queryInput.value = '';
    if (filterSet.size > 0) {
        filterSet = new Set();
        rawQuery = '';
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
    queryText.innerHTML = isFiltered ?
        `${queryInput.value} (${numMatches} results)` :
        'none';
    rawText.value = rawQuery;
}

// checkURLQuery checks for a query parameter in the URL and, if set, populates
// the initial query value from it.
async function checkURLQuery() {
    const url = new URL(document.location.href);
    const query = url.searchParams.get("q") || "";
    if (query) {
        queryInput.value = query;
        updateQuery(query);
    }
}

// Hook up event listeners and initialize the UI.
clearButton.addEventListener("click", clearQuery);
queryInput.addEventListener("keyup", updateQueryOnEnter);
checkURLQuery();
updateUI();
