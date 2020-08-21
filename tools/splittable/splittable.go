// Program splittable explodes an episodes YAML into separate
// files with front matter.
//
// Usage: splittable -output dir -input episodes.yml
//
package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"

	yaml "gopkg.in/yaml.v3"
)

var (
	inputPath = flag.String("input", "", "Input episodes YAML (required)")
	outputDir = flag.String("output", "", "Output directory (required)")
)

type episodeTable struct {
	Episodes []*episode `yaml:"episodes"`
}

type episode struct {
	Episode intString `yaml:"episode"`
	Date    string    `yaml:"date"` // YYYY-MM-DD
	YouTube string    `yaml:"youtube,omitempty"`
	Topics  string    `yaml:"topics,omitempty"`
	Summary string    `yaml:"summary,omitempty"`
	Links   []link    `yaml:"links,omitempty"`
}

type link struct {
	Title string `yaml:"title,omitempty"`
	URL   string `yaml:"url"`
}

type intString string

func (s intString) MarshalYAML() (interface{}, error) {
	v, err := strconv.Atoi(string(s))
	if err == nil {
		return v, nil
	}
	return string(s), nil
}

func main() {
	flag.Parse()
	switch {
	case *outputDir == "":
		log.Fatal("You must provide a non-empty -output directory")
	case *inputPath == "":
		log.Fatal("You must providea non-empty -input file path")
	}

	table, err := loadEpisodeTable(*inputPath)
	if err != nil {
		log.Fatalf("Loading episode table: %v", err)
	}
	log.Printf("Loaded %d episodes from %q", len(table.Episodes), *inputPath)

	if err := os.MkdirAll(*outputDir, 0755); err != nil {
		log.Fatalf("Creating output directory: %v", err)
	}

	for _, ep := range table.Episodes {
		path := filepath.Join(*outputDir, episodeFileName(ep, ".md"))
		f, err := os.Create(path)
		if err != nil {
			log.Fatalf("Creating output file: %v", err)
		}

		fmt.Fprintln(f, "---")
		enc := yaml.NewEncoder(f)
		if err := enc.Encode(ep); err != nil {
			log.Fatalf("Encoding episode %q: %v", ep.Episode, err)
		} else if err := enc.Close(); err != nil {
			log.Printf("Warning: closing encoder: %v", err)
		}
		fmt.Fprintln(f, "---")
		if ep.Summary != "" {
			fmt.Fprint(f, "\n", ep.Summary, "\n")
		}
		if err := f.Close(); err != nil {
			log.Fatalf("Closing output file: %v", err)
		}
		log.Printf("Wrote %q", path)
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

func episodeFileName(ep *episode, ext string) string {
	return fmt.Sprintf("%s-%04s%s", ep.Date, ep.Episode, ext)
}
