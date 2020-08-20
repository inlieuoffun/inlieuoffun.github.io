---
layout: page
title: Episode Log
---

Here is a list of all the episodes of *In Lieu of Fun*. They are listed in
reverse chronological order. Each episode date links to its stream on YouTube.

| # | Date | Guests | Topics | Links |
|---|------|--------|--------|-------|
{% for entry in site.data.episodes.episodes -%}
{%- assign raw_guests = site.data.guests.guests | sort: "name" -%}
{%- assign guests = '' | split: 'x' -%}
{%- for guest in raw_guests -%}
 {%- if guest.episodes contains entry.episode -%}
   {%- capture link -%}
     {%- if guest.twitter %}<a href="https://twitter.com/{{ guest.twitter }}">{{ guest.name }}</a>
     {%- elsif guest.url %}<a href="{{ guest.url }}">{{ guest.name }}</a>
     {%- endif -%}
   {%- endcapture -%}
   {%- assign guests = guests | push: link -%}
 {%- endif -%}
{%- endfor -%}
| <a name="ep{{ entry.episode }}"></a>{{ entry.episode }} | <a href="{{ entry.youtube }}">
  {{- entry.date | slice: 0, 10 | replace: "-", "‑" }}</a> |
  {%- if guests.size > 0 %}{{- guests | join: ", " }}{% else %}(your hosts){% endif %} |
  {{- entry.topics | strip | newline_to_br }} |
{%-  for link in entry.links -%}
  <a href="{{ link.url }}">{{ link.title }}</a>
  {%- unless forloop.last %}, {% endunless %}
  {%- endfor %} |
{% endfor %}
