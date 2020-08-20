// Program wikihack extracts links from description strings lifted out of
// MediaWiki markup, which itself is a huge pile of gross hacks.
//
// Usage: wikihack < input.json > output.json
//
package main

import (
	"encoding/json"
	"flag"
	"io"
	"log"
	"os"
	"regexp"
	"strings"
	"time"
)

type wikiObj struct {
	Actual      int    `json:"actual"`
	Label       int    `json:"episode"`
	Guests      string `json:"guests"`
	Date        string `json:"date"` // Month DD, YYYY
	Description string `json:"description"`
}

type episodeData struct {
	Episode     int    `json:"episode"`
	Date        string `json:"date,omitempty"` // as a coherence check
	Description string `json:"description"`
	Links       []link `json:"links,omitempty"`
}

func main() {
	flag.Parse()

	r := json.NewDecoder(os.Stdin)
	w := json.NewEncoder(os.Stdout)
	for {
		var next wikiObj
		if err := r.Decode(&next); err == io.EOF {
			break
		} else if err != nil {
			log.Fatalf("Decoding object at offset %d failed: %v", r.InputOffset(), err)
		}

		rest, refs, err := extractRefs(next.Description)
		if err != nil {
			log.Printf("Extracting refs: %v", err)
			continue
		}
		var date string
		if ts, err := time.Parse(humanDate, next.Date); err == nil {
			date = ts.Format("2006-01-02")
		}

		if rest == "" && len(refs) == 0 {
			continue
		}
		if err := w.Encode(&episodeData{
			Episode:     next.Actual,
			Date:        date,
			Description: rest,
			Links:       refs,
		}); err != nil {
			log.Fatalf("Encoding to JSON: %v", err)
		}
	}
}

type link struct {
	Type  string `json:"-"`
	Title string `json:"title,omitempty"`
	URL   string `json:"url"`
}

var (
	humanDate = "January 2, 2006"
	refBlock  = regexp.MustCompile(`(?i)<ref>{{Cite (\w+\|.*?)}}</ref>`)
	linkBlock = regexp.MustCompile(`\[(?:\[(.+?)\]|(http.+?) (.+?))\]`)
	commonEsc = strings.NewReplacer("<nowiki/>", "", "{{!}}", "|")
)

func extractRefs(s string) (string, []link, error) {
	var rest strings.Builder
	var refs []link
	for {
		m := refBlock.FindStringSubmatchIndex(s)
		if m == nil {
			rest.WriteString(s)
			break
		}
		rest.WriteString(s[:m[0]])
		guts := s[m[2]:m[3]]
		s = s[m[1]:]

		attrs := strings.Split(guts, "|")
		ref := link{Type: attrs[0]}
		for _, attr := range attrs[1:] {
			parts := strings.SplitN(attr, "=", 2)
			switch parts[0] {
			case "title":
				ref.Title = commonEsc.Replace(parts[1])
			case "url":
				ref.URL = parts[1]
			}
		}
		refs = append(refs, ref)
	}
	out, more := stripLinks(rest.String())
	return out, append(refs, more...), nil
}

func stripLinks(s string) (string, []link) {
	var rest strings.Builder
	var refs []link

	for {
		m := linkBlock.FindStringSubmatchIndex(s)
		if m == nil {
			rest.WriteString(s)
			break
		}

		rest.WriteString(s[:m[0]])
		match := s[m[0]:m[1]]
		if strings.HasPrefix(match, "[[") {
			hunk := s[m[2]:m[3]]
			if i := strings.Index(hunk, "|"); i > 0 {
				hunk = hunk[i+1:]
			}
			rest.WriteString(hunk)
		} else {
			title := commonEsc.Replace(s[m[6]:m[7]])
			refs = append(refs, link{
				Title: title,
				URL:   s[m[4]:m[5]],
			})
			rest.WriteString(title)
		}

		s = s[m[1]:]
	}
	return commonEsc.Replace(rest.String()), refs
}
