// Program splicedata combines episode YAML with JSON objects
// extracted from the Wikipedia draft.
//
// Usage: splicedata episodes.yml wikidata.json > output.yml
//
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	yaml "gopkg.in/yaml.v3"
)

type episodeTable struct {
	Episodes []*episode `yaml:"episodes"`
}

type episode struct {
	Episode string `yaml:"episode"`
	Date    string `yaml:"date"` // RFC 3339
	YouTube string `yaml:"youtube,omitempty"`
	Topics  string `yaml:"topics,omitempty"`
	Summary string `yaml:"summary,omitempty"`
	Links   []link `yaml:"links,omitempty"`
}

type link struct {
	Title string `yaml:"title,omitempty"`
	URL   string `yaml:"url"`
}

type wikiData struct {
	Episode     int    `json:"episode"`
	Date        string `json:"date,omitempty"` // as a coherence check
	Description string `json:"description"`
	Links       []link `json:"links,omitempty"`
}

func main() {
	flag.Parse()
	if flag.NArg() != 2 {
		log.Fatalf("Usage: %s episodes.yml wikidata.json", filepath.Base(os.Args[0]))
	}

	table, err := loadEpisodeTable(flag.Arg(0))
	if err != nil {
		log.Fatalf("Loading episode table: %v", err)
	}
	log.Printf("Loaded %d episodes from %q", len(table.Episodes), flag.Arg(0))

	wiki, err := loadWikiData(flag.Arg(1))
	if err != nil {
		log.Fatalf("Loading wiki data: %v", err)
	}
	log.Printf("Loaded %d episodes from %q", len(wiki), flag.Arg(1))

	for _, ep := range table.Episodes {
		detail, ok := wiki[ep.Episode]
		if !ok {
			continue // no additional data for this episode
		}
		if !strings.HasPrefix(ep.Date, detail.Date) {
			log.Printf("Warning: episode %q date mismatch: %s ≠ %s", ep.Episode, ep.Date, detail.Date)
		}

		ep.Summary = detail.Description
		ep.Links = append(ep.Links, detail.Links...)
		sort.Slice(ep.Links, func(i, j int) bool {
			return ep.Links[i].Title < ep.Links[j].Title
		})
	}

	if err := yaml.NewEncoder(os.Stdout).Encode(table); err != nil {
		log.Fatalf("Encoding output: %v", err)
	}
}

func loadEpisodeTable(path string) (episodeTable, error) {
	f, err := os.Open(path)
	if err != nil {
		return episodeTable{}, err
	}
	defer f.Close()

	var out episodeTable
	err = yaml.NewDecoder(f).Decode(&out)
	return out, err
}

func loadWikiData(path string) (map[string]wikiData, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	m := make(map[string]wikiData)
	r := json.NewDecoder(f)
	for {
		var next wikiData
		if err := r.Decode(&next); err == io.EOF {
			break
		} else if err != nil {
			return nil, fmt.Errorf("decoding JSON: %v", err)
		}

		key := strconv.Itoa(next.Episode)
		if _, ok := m[key]; ok {
			log.Printf("Warning: Duplicate episode key %q", key)
		}
		m[key] = next
	}
	return m, nil
}
