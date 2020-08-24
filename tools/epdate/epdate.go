// Program epdate checks for new episodes since the most recent
// visible on the main web site, and creates new episode files for them with
// stream URLs populated.
//
// You must provide a TWITTER_TOKEN environment variable with a Twitter API v2
// bearer token.
package main

import (
	"bytes"
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/creachadair/atomicfile"
	yaml "gopkg.in/yaml.v3"
	"inlieuoffun.github.io/tools/ilof"
)

var (
	doDryRun = flag.Bool("dry-run", false, "Do not create or modify any files")
)

func main() {
	flag.Parse()
	token := os.Getenv("TWITTER_TOKEN")
	if token == "" {
		log.Fatal("No TWITTER_TOKEN is set in the environment")
	}

	if _, err := cdRepoRoot(); err != nil {
		log.Fatalf("Changing directory to repo root: %v", err)
	}

	ctx := context.Background()

	latest, err := ilof.LatestEpisode(ctx)
	if err != nil {
		log.Fatalf("Looking up latest episode: %v", err)
	}
	log.Printf("Latest episode is %s, airdate %s", latest.Episode, latest.Date)

	updates, err := ilof.NewTwitter(token).Updates(ctx, latest.Date)
	if err != nil {
		log.Fatalf("Finding updates on twitter: %v", err)
	}
	log.Printf("Found %d updates on twitter since %s", len(updates), latest.Date)

	for i, up := range updates {
		epNum := latest.Episode.Int() + len(updates) - i
		epFile := fmt.Sprintf("%s-%04d.md", up.Date.Format("2006-01-02"), epNum)
		epPath := filepath.Join("_episodes", epFile)
		exists := fileExists(epPath)

		log.Printf("Update %d: episode %d, posted %s, exists=%v",
			i+1, epNum, up.Date.Format(time.RFC822), exists)
		if exists {
			continue
		}
		if err := createEpisodeFile(epNum, up, epPath); err != nil {
			log.Fatalf("Creating episode file for %d: %v", epNum, err)
		}
	}
}

func createEpisodeFile(num int, up *ilof.TwitterUpdate, path string) error {
	var buf bytes.Buffer
	fmt.Fprintln(&buf, "---")

	enc := yaml.NewEncoder(&buf)
	if err := enc.Encode(&ilof.Episode{
		Episode:      ilof.Label(strconv.Itoa(num)),
		Date:         ilof.Date(up.Date),
		CrowdcastURL: up.Crowdcast,
		YouTubeURL:   up.YouTube,
	}); err != nil {
		return fmt.Errorf("encoding episode: %v", err)
	}
	enc.Close()
	fmt.Fprintln(&buf, "---")
	if *doDryRun {
		log.Printf("Prepared %d bytes to write to %q (dry run, no file will be written)\n%s",
			buf.Len(), path, buf.String())
	} else if nw, err := atomicfile.WriteAll(path, &buf, 0644); err != nil {
		return err
	} else {
		log.Printf("Wrote %d bytes to %q", nw, path)
	}
	return nil
}

func cdRepoRoot() (string, error) {
	data, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		return "", err
	}
	root := strings.TrimSpace(string(data))
	return root, os.Chdir(root)
}

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}
