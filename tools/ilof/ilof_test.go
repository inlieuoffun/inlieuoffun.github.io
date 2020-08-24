package ilof_test

import (
	"context"
	"os"
	"strings"
	"testing"

	"inlieuoffun.github.io/tools/ilof"
)

func TestLatestEpisode(t *testing.T) {
	token := os.Getenv("TWITTER_TOKEN")
	if token == "" {
		t.Fatal("No TWITTER_TOKEN is set")
	}
	cli := ilof.NewTwitter(token)

	ctx := context.Background()
	ep, err := ilof.LatestEpisode(ctx)
	if err != nil {
		t.Fatalf("LatestEpisode failed: %v", err)
	}
	t.Logf(`Latest episode %s:
Date:      %s
YouTube:   %s
Crowdcast: %s
Guests:    %s
Summary:
%s`, ep.Episode, ep.Date, ep.YouTubeURL, ep.CrowdcastURL,
		strings.Join(ep.Guests, ", "), ep.Summary)

	ups, err := cli.Updates(ctx, ep.Date)
	if err != nil {
		t.Fatalf("TwitterUpdates failed: %v", err)
	}

	for i, up := range ups {
		num := ep.Episode.Int() + len(ups) - i
		t.Logf(`Probable episode %d:
Date:      %s
YouTube:   %s
Crowdcast: %s
Guests:    %s`, num, up.Date.Format("2006-01-02"), up.YouTube, up.Crowdcast,
			strings.Join(up.Guests, ", "))
	}
}
