package ilof_test

import (
	"context"
	"testing"

	"inlieuoffun.github.io/tools/ilof"
)

func TestLatestEpisode(t *testing.T) {
	ep, err := ilof.LatestEpisode(context.Background())
	if err != nil {
		t.Fatalf("LatestEpisode failed: %v", err)
	}

	t.Logf("Latest: %+v", ep)
}
