# In Lieu of Fun

This repository contains the website for the [In Lieu of Fun](https://inlieuof.fun) webcast.

## Site Data

Episodes are stored in Markdown files in the `_episodes` directory, with each
file named like `YYYY-MM-DD-NNNN.md`. Here `NNNN` is the episode number, padded
with zeroes on the left (e.g., `0014`, `0143`). Each file has a YAML front
matter section giving episode metadata:

 - `episode`: The episode number [integer]
 - `date`: The date when the episode aired [string, "YYYY-MM-DD"]
 - `youtube`: The URL of the episode stream on YouTube [string]
 - `crowdcast`: The URL of the episode stream on Crowdcast [string]
 - `summary`: A brief summary of the episode [string, optional]
 - `topics`: A comma-separated list of topics [string, optional]
 - `links`: A list of related hyperlinks [optional]

The body of the episode is arbitrary markdown text that will be displayed on
the episode detail page. The episode log table is rendered by the Liquid
template in [`episodes.html`](./episodes.html).

To add a new episode, create a new file in the `_episodes` directory following
the format of the existing files, and update the guest list as necessary.

Guests are recorded in [`_data/guests.yaml`](./_data/guests.yaml), and the
guest list is rendered by the Liquid template in [`guests.md`](./guests.md).


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

## URL Structure

- Episode Log (HTML): https://inlieuof.fun/episodes.html
    - Episode Log (JSON): https://inlieuof.fun/episodes.json
- Guest List (HTML): https://inlieuof.fun/guests.html
    - Guest List (HTML): https://inlieuof.fun/guests.json
- Episode N stream redirect (ex. N=25): https://inlieuof.fun/stream/25
- Episode N detail redirect (ex. N=25): https://inlieuof.fun/detail/25

## Peculiarities

Because this site is hosted from a github.io repository, the generated site
data must be published from the branch named `master`. Thus, this repository
uses the `source` branch as its default branch.
