# In Lieu of Fun

This repository contains the website for the [In Lieu of Fun](https://inlieuof.fun) webcast.

## Site Data

Episode metadata are stored in [`_data/episodes.yaml`](./_data/episodes.yaml)
and presented by [`episodes.md`](./episodes.md).  Guest metadata are stored in
[`_data/guests.yaml`](./_data/guests.yaml) and presented by
[`guests.md`](./guests.md).  The structure is fairly simple; use the existing
data as examples.  At present, these data are presented in a simple tabular
format.

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






