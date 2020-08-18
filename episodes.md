---
layout: page
title: Episode Log
---

Here is a list of all the episodes of *In Lieu of Fun*.

| Episode | Date | Guests | Topics | Stream |
|---------|------|--------|--------|--------|
{% for entry in site.data.episodes.episodes -%}
| {{ entry.episode }} | {{ entry.date | slice: 0, 10 | replace: "-", "‑" }} |
  {{- entry.guests | join: ", " }} | {{ entry.topics | strip | newline_to_br -}}
  | <a href="{{ entry.youtube }}">YouTube</a> |
{% endfor %}
