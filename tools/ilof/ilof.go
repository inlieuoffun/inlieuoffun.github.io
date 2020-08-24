// Package ilof provides support code for the In Lieu of Fun site.
package ilof

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"time"
)

// BaseURL is the base URL of the production site.
const BaseURL = "https://inlieuof.fun"

// An Episode records details about an episode of the webcast.
type Episode struct {
	Episode      Label    `json:"episode"`
	Date         Date     `json:"airDate"`
	Guests       []string `json:"guestNames,omitempty"`
	Topics       string   `json:"topics,omitempty"`
	Summary      string   `json:"summary,omitempty"`
	CrowdcastURL string   `json:"crowdcastURL,omitempty"`
	YouTubeURL   string   `json:"youTubeURL,omitempty"`
	Links        []Link   `json:"links,omitempty"`
}

// A Label holds the string encoding of an episode label, which can be either a
// number or a string.
type Label string

// Int returns the value of a as an integer, or -1.
func (a Label) Int() int {
	if v, err := strconv.Atoi(string(a)); err == nil {
		return v
	}
	return -1
}

func (a *Label) UnmarshalJSON(data []byte) error {
	var z int
	if err := json.Unmarshal(data, &z); err == nil {
		*a = Label(strconv.Itoa(z))
		return nil
	}
	var s string
	if err := json.Unmarshal(data, &s); err != nil {
		return err
	}
	*a = Label(s)
	return nil
}

func (a Label) MarshalJSON() ([]byte, error) {
	if _, err := strconv.Atoi(string(a)); err == nil {
		return []byte(a), nil
	}
	return json.Marshal(string(a))
}

// A Date records the date when an episode aired or will air.
// It is encoded as a string in the format "YYYY-MM-DD".
type Date time.Time

const dateFormat = "2006-01-02"

func (d Date) String() string { return time.Time(d).Format(dateFormat) }

func (d *Date) UnmarshalJSON(data []byte) error {
	var s string
	if err := json.Unmarshal(data, &s); err != nil {
		return err
	}
	ts, err := time.Parse(dateFormat, s)
	if err != nil {
		return err
	}
	*d = Date(ts)
	return nil
}

func (d Date) MarshalJSON() ([]byte, error) {
	return []byte(d.String()), nil
}

// A Link records the title and URL of a hyperlink.
type Link struct {
	Title string `json:"title,omitempty"`
	URL   string `json:"url"`
}

// LatestEpisode queries the site for the latest episode.
func LatestEpisode(ctx context.Context) (*Episode, error) {
	rsp, err := http.Get(BaseURL + "/latest.json")
	if err != nil {
		return nil, err
	}
	var buf bytes.Buffer
	io.Copy(&buf, rsp.Body)
	rsp.Body.Close()
	var ep struct {
		Latest *Episode `json:"latest"`
	}
	if err := json.Unmarshal(buf.Bytes(), &ep); err != nil {
		return nil, err
	}
	return ep.Latest, nil
}
