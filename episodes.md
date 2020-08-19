---
layout: page
title: Episode Log
---

Here is a list of all the episodes of *In Lieu of Fun*. They are listed in
reverse chronological order.

| Episode | Date | Guests | Topics | Stream |
|---------|------|--------|--------|--------|
{% for entry in site.data.episodes.episodes -%}
{%- assign guests = '' | split: 'x' -%}
{%- for guest in site.data.guests.guests -%}
 {%- if guest.episodes contains entry.episode -%}
   {%- assign guests = guests | push: guest.name -%}
 {%- endif -%}
{%- endfor -%}
| <a name="ep{{ entry.episode }}"></a>{{ entry.episode }} |
  {{- entry.date | slice: 0, 10 | replace: "-", "‑" }} |
  {%- if guests.size > 0 %}{{- guests | sort | join: ", " }}{% else %}(your hosts){% endif %} |
  {{- entry.topics | strip | newline_to_br -}}
  | <a href="{{ entry.youtube }}">YouTube</a> |
{% endfor %}
