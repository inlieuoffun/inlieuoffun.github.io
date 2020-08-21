---
layout: page
title: Episode Log
---

Here is a list of all the episodes of *In Lieu of Fun*. They are listed in
reverse chronological order. Each episode date links to its stream on YouTube.
Note that the labels on some of the early episodes on YouTube are incorrect.
Rest assured the topics and guests will match even if the numbers do not.

{% capture newline %}
{% endcapture %}
| # | Date | Guests | Topics | Links |
|---|------|--------|--------|-------|
{% for entry in site.episodes reversed -%}
{%- assign raw_guests = site.data.guests.guests | sort: "name" -%}
{%- assign guests = '' | split: 'x' -%}
{%- for guest in raw_guests -%}
 {%- if guest.episodes contains entry.episode -%}
   {%- capture link -%}
     {%- if guest.twitter %}<a href="https://twitter.com/{{ guest.twitter }}">{{ guest.name }}</a>
     {%- elsif guest.url %}<a href="{{ guest.url }}">{{ guest.name | replace: " ", " " }}</a>
     {%- else %}{{ guest.name | replace: " ", " " }}
     {%- endif -%}
   {%- endcapture -%}
   {%- assign guests = guests | push: link -%}
 {%- endif -%}
{%- endfor -%}
| <a name="ep{{ entry.episode }}"></a>{{ entry.episode -}}
  | <a href="{{ site.config.url }}/stream/{{ entry.episode}}">
      {{- entry.date | date: "%Y‑%m‑%d" }}</a> {{" " -}}
  | {% if guests.size > 0 %}{{- guests | join: ", " }} {% else %}(your hosts) {% endif -%}
  | {{ entry.topics | strip | replace: newline, " " -}} |
{%- for link in entry.links -%}
  <a href="{{ link.url }}" target=_blank>{{ link.title | replace: "|", "\|" }}</a>
  {%- unless forloop.last %}, {% endunless %}
  {%- endfor %} |
{% endfor %}
