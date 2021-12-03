# In Lieu of Fun

This repository contains the website for the [In Lieu of Fun](https://inlieuof.fun) webcast.

- If you have a question or want to report a problem, please consider [filing an issue][issues].
- If you are looking for the webcast itself, please visit https://inlieuof.fun.
- This repository: http://repo.inlieuof.fun
    - Site build status: http://build.inlieuof.fun
- The tools repository: http://tools.inlieuof.fun

[issues]: http://issues.inlieuof.fun

## Episode Metadata

Episodes are stored in Markdown files in the `_episodes` directory, with each
file named like `YYYY-MM-DD-NNNN.md`. Here `NNNN` is the episode number, padded
with zeroes on the left (e.g., `0014`, `0143`). Each file has a YAML front
matter section giving episode metadata:

 - `episode`: The episode number [number; required]
 - `date`: The date when the episode aired [string, "YYYY-MM-DD"; required]
 - `season`: The season number [integer]
 - `youtube`: The URL of the episode stream on YouTube [string]
 - `crowdcast`: The URL of the episode stream on Crowdcast [string]
 - `acast`: The URL of the episode audio on Acast [string]
 - `summary`: A brief summary of the episode [string, optional]. If this is
   provided, it is shown in the Episode Log.
 - `topics`: A comma-separated list of topics [string, optional]. If this is
   provided and there is not a summary, it is shown in the Episode Log.
 - `links`: A list of related hyperlinks [optional]. Shown on the Episode Log.
 - `special`: If true, cosmetically flag this episode as interesting in the Episode Log.

The body of the episode is arbitrary markdown text that will be displayed on
the episode detail page. Episode detail pages are rendered using the layout
defined in [`_layouts/episode.html`](./_layouts/episode.html). The episode log
table is rendered by the Liquid template in [`episodes.html`](./episodes.html).

To add a new episode, create a new file in the `_episodes` directory following
the format of the existing files, and update the guest list as necessary.

## Guest Metadata

All guests are recorded in a single YAML file, [`_data/guests.yaml`](./_data/guests.yaml).
The HTML guest list is rendered by the Liquid template in [`guests.html`](./guests.html).
The following data are recorded for each guest:

 - `name`: Guest name (required)
 - `episodes`: List of episode numbers attended (required)
 - `twitter`: Twitter handle (optional)
 - `url`: Personal website URL (optional)
 - `notes`: A brief biographical synopsis (optional)

## Updates

The site content is generated with [Jekyll](https://jekyllrb.com).  To test
changes locally, run `bundle exec jekyll serve` and visit the local server in
your browser. You can leave this running while you work, it will detect file
changes and rebuild as needed. The only caveat is that if you edit the root
`_config.yml` file, you will need to restart it.

### First-Time Setup

After cloning the repository for the first time, you will need to install the
toolchain, which is not checked in. This is, roughly:

```bash
# One-time setup instructions for a fresh clone.

# Install Jekyll and Bundler. On macOS, you may want to include --user-install
gem install jekyll bundler

# Install vendored gems.
git clone https://github.com/inlieuoffun/inlieuoffun.github.io.git ilof
cd ilof
bundle install
```

### Daily Updates

To simplify the process of setting up new episodes, we have written a
[command-line tool that primes a new episode][epdate] from its announcement on Twitter.
To use it you need to have (or install) [Go](https://golang.org), then run:

[epdate]: https://github.com/inlieuoffun/tools/tree/default/epdate

```shell
go install github.com/inlieuoffun/tools/epdate@latest
```

To use the tool, you will need:

- A [Twitter API v2 bearer token](https://developer.twitter.com/en/portal/dashboard),
  in the environment variable `TWITTER_TOKEN`.

- A [YouTube Data API key](https://console.developers.google.com/apis/credentials),
  in the environment variable `YOUTUBE_API_KEY`.

Once you have these set up, change directory into a clone of this repository
and run:

```shell
epdate -edit
```

If there are new episodes scheduled, this will create one or more new files in
the `_episodes` directory and update `_data/guests.yaml`. Inspect these and
correct any errors or other missing data (the tool is imperfect), then commit
and push them up to GitHub.

To make the tool wait and poll until an update is made, run:

```shell
epdate -edit -poll-one
```

The [`scripts/poll.sh`](./scripts/poll.sh) script shows how you can combine
this with other tools to post an alert when a new episode comes around.

### Audio Updates

The Acast channel is updated separately from the main feed, and is usually
around one to two weeks behind the main show. Older shows are being backfilled
on an ad hoc basis.

New audio episodes can be found from the [Acast RSS feed][acast-feed], but it
is not currently practical to automatically integrate them. The publication
date of the audio episode is after the original, but not by any fixed amount,
and the episode numbering in the title is usually incorrect (it is probably
being filled in by hand based on the previous entries).

To update these episodes, install `scancast` from the tools repository:

```shell
go install github.com/inlieuoffun/tools/scancast@latest
```

This tool does not require any credentials. When you run `scantest`, it will
fetch the Acast RSS feed and the ILoF episode log, and print out a summary of
all the audio episodes listed in the feed whose URLs are not recorded in the
episode log. You can (manually) update the episodes based on this output and
commit the changes to Git.

[acast-feed]: https://feeds.acast.com/public/shows/in-lieu-of-fun


## URL Structure

- Root: https://inlieuof.fun
- Episode Log (HTML): https://inlieuof.fun/episodes.html
    - Episode Log (JSON): https://inlieuof.fun/episodes.json
    - Latest episode (JSON): https://inlieuof.fun/latest.json
    - Episode N (JSON), e.g., N=25: https://inlieuof.fun/episode/25.json
- Guest List (HTML): https://inlieuof.fun/guests.html
    - Guest List (JSON): https://inlieuof.fun/guests.json
- Episode N stream redirect (ex. N=25): https://inlieuof.fun/stream/25
    - Latest episode stream redirect: https://inlieuof.fun/stream/latest
    - These redirects prefer Crowdcast if available, and fall back to YouTube.
- Episode N replay redirect (ex. N=25): https://inlieuof.fun/replay/25
    - These redirects go to YouTube unconditionally (if set).
- Episode N audio redirect (ex. N=25) https://inlieuof.fun/audio/25
    - These redirects go to ACast for episodes that set it.
- Episode N detail redirect (ex. N=25): https://inlieuof.fun/episode/25
- Merch store redirects: https://inlieuof.fun/merch, https://inlieuof.fun/store

## Peculiarities

Because this site is hosted from a github.io repository, the generated site
data must be published from the branch named `master`. Thus, this repository
uses the `source` branch as its default branch.
