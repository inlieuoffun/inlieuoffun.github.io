// Program episodelist exports a CSV episode table to YAML.
//
// Usage: episodelist < input.csv > output.yaml
//
package main

import (
	"encoding/csv"
	"flag"
	"io"
	"log"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	yaml "gopkg.in/yaml.v3"
)

type episode struct {
	Number int       `yaml:"episode"`
	Date   time.Time `yaml:"date"` // encodes as RFC 3339
	Guests []string  `yaml:"guests,flow,omitempty"`
	Topics string    `yaml:"topics,omitempty"`
	Stream string    `yaml:"youtube,omitempty"`
}

var usEastern *time.Location // where ILoF is recorded

func init() {
	var err error
	usEastern, err = time.LoadLocation("America/New_York")
	if err != nil {
		log.Panicf("Unable to load US Eastern location: %v", err)
	}
}

func main() {
	flag.Parse()

	// The first row should include a header with fields for episode, date,
	// guests, topics, polls, and a YouTube stream link.
	r := csv.NewReader(os.Stdin)
	header, err := r.Read()
	if err != nil {
		log.Fatalf("Reading header row: %v", err)
	}
	keys := make(map[string]int)
	for i, key := range header {
		keys[strings.ToLower(key)] = i
	}
	field := func(name string, row []string) string {
		return row[keys[name]]
	}

	var nr int
	var episodes []episode
	for {
		row, err := r.Read()
		nr++
		if err == io.EOF {
			break
		} else if err != nil {
			log.Fatalf("Reading row %d: %v", nr, err)
		}

		e := episode{
			Guests: guestList(field("guests", row)),
			Topics: strings.TrimSpace(field("topics", row)),
			Stream: field("stream", row),
		}
		ep, err := strconv.Atoi(field("episode", row))
		e.Number = ep
		if err != nil {
			log.Printf("Warning: invalid episode in row %d: %v", nr, err)
		}
		when, err := time.ParseInLocation("2-Jan-2006", field("date", row), usEastern)
		if err == nil {
			// Date without time pins to midnight; advance to 1700h.
			e.Date = when.Add(17 * time.Hour)
		} else {
			log.Printf("Warning: invalid date in row %d: %v", nr, err)
		}
		episodes = append(episodes, e)
	}

	enc := yaml.NewEncoder(os.Stdout)

	if err := enc.Encode(struct {
		Episodes []episode `yaml:"episodes"`
	}{Episodes: episodes}); err != nil {
		log.Fatalf("Encoding to YAML failed: %v", err)
	}
	if err := enc.Close(); err != nil {
		log.Fatalf("Closing YAML stream failed: %v", err)
	}
}

var tlink = regexp.MustCompile(`\(@\w+\)$`)

func guestList(s string) []string {
	var guests []string
	for _, name := range strings.Split(s, ",") {
		name = strings.TrimSpace(name)
		if name == "(none)" {
			continue // on "just us" episodes
		}

		// Remove embedded twitter handles.
		m := tlink.FindStringIndex(name)
		if m != nil {
			name = strings.TrimSpace(name[:m[0]])
		}

		guests = append(guests, name)
	}
	sort.Strings(guests)
	return guests
}
