// Program guestlist exports a CSV guest table to YAML.
//
// Usage: guestlist < input.csv > output.yaml
//
package main

import (
	"encoding/csv"
	"flag"
	"io"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"

	yaml "gopkg.in/yaml.v3"
)

type guest struct {
	Name     string `json:"name" yaml:"name"`
	Twitter  string `json:"twitter,omitempty" yaml:"twitter,omitempty"`
	URL      string `json:"url,omitempty" yaml:"url,omitempty"`
	Episodes []int  `json:"episodes" yaml:"episodes,flow"`
	Notes    string `json:"notes,omitempty" yaml:"notes,omitempty"`
}

func main() {
	flag.Parse()

	// The first row should include a header with fields for name, twitter,
	// website, episodes, and notes.
	//
	// Episodes is a comma-separated list of integer episode values.
	// Twitter and website are URL strings.
	// Notes is an arbitrary string.
	r := csv.NewReader(os.Stdin)
	header, err := r.Read()
	if err != nil {
		log.Fatalf("Reading header row: %v", err)
	}
	keys := make(map[string]int)
	for i, key := range header {
		keys[key] = i
	}
	field := func(name string, row []string) string {
		return row[keys[name]]
	}

	var nr int
	var guests []guest
	for {
		row, err := r.Read()
		nr++
		if err == io.EOF {
			break
		} else if err != nil {
			log.Fatalf("Reading row %d: %v", nr, err)
		}

		g := guest{
			Name:    field("name", row),
			Twitter: strings.TrimPrefix(field("twitter", row), "https://twitter.com/"),
			URL:     field("website", row),
			Notes:   field("notes", row),
		}
		eps := field("episodes", row)
		if eps != "" {
			for _, ep := range strings.Split(eps, ",") {
				v, err := strconv.Atoi(ep)
				if err != nil {
					log.Printf("Warning: invalid episode %q in row %d: %v", ep, nr, err)
					continue
				}
				g.Episodes = append(g.Episodes, v)
			}
		}
		sort.Ints(g.Episodes)
		guests = append(guests, g)
	}

	enc := yaml.NewEncoder(os.Stdout)

	if err := enc.Encode(struct {
		Guests []guest `yaml:"guests"`
	}{Guests: guests}); err != nil {
		log.Fatalf("Encoding to YAML failed: %v", err)
	}
	if err := enc.Close(); err != nil {
		log.Fatalf("Closing YAML stream failed: %v", err)
	}
}
