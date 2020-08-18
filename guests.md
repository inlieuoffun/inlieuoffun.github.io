---
layout: page
title: Guest List
---

The following guests have appeared on *In Lieu of Fun*.

| Guest | Episodes |
|-------|----------|
{%- for guest in site.data.guests.guests %}
| {% if guest.twitter -%}
    <a href="https://twitter.com/{{ guest.twitter }}">{{ guest.name }}</a>
  {%- elsif guest.url -%}
    <a href="https://twitter.com/{{ guest.url }}">{{ guest.name }}</a>
  {%- else -%}
    {{ guest.name }}
  {%- endif %} | {{ guest.episodes | join: ", " }} |
{%- endfor %}
