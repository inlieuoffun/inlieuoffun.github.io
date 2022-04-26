import { stem } from './wink-porter2-stemmer.js'

const keywordRE = /^(@|(is|has|tag|guest):)/;

function isKeyword(term) { return term.match(keywordRE); }

export class SearchIndex {
    #datap; // a promise for the index data

    constructor(url) {
        this.#datap = fetch(url)
            .then((rsp) => rsp.blob())
            .then((blob) => blob.text())
            .then((text) => JSON.parse(text));
    }

    // parseQuery splits the query string into terms, filters out any
    // stopwords, and stems each remaining term.
    async parseQuery(query) {
        // First pass: Split on spaces, and check for keyword prefixes.
        // Non-keyword arguments are split further.
        let terms = query.toLowerCase().trim().split(/\s+/).flatMap((t) => {
            if (isKeyword(t)) {
                return t;
            }
            return t.split(/\W+/).filter((x) => x != '');
        });
        let index = await this.#datap;
        let stops = index.index.stops;

        // Second pass: Filter out stopwords and remove duplicates.
        let unique = Array.from(new Set(terms.filter((t) => !stops.includes(t))));
        let stems = unique.map((term) => isKeyword(term) ? term : stem(term));
        return stems;
    }

    // matchTerms returns a set of document IDs matching all the given terms.
    async matchTerms(terms) {
        if (terms.length == 0) { return new Set(); } // simplify logic below

        let index = await this.#datap;
        let match = await this.matchOneTerm(terms[0]);
        for (const term of terms.slice(1)) {
            const next = await this.matchOneTerm(term);
            match.forEach((old) => {
                if (!next.has(old)) {
                    match.delete(old)
                }
            });
            if (match.size == 0) {
                return match;
            }
        }
        return match;
    }

    // matchOneTerm returns the set of document IDs matching a single term.
    async matchOneTerm(term) {
        let index = await this.#datap;
        let match = index.index.terms[term];
        if (match) {
            const result = new Set();
            for (const term in match) {
                match[term].forEach((ep) => { result.add(ep.toString()) });
            }
            return result;
        }
        return new Set();
    }
}
