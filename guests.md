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
    <a href="{{ guest.url }}">{{ guest.name }}</a>
  {%- else -%}
    {{ guest.name }}
  {%- endif %} |
  {%- for n in guest.episodes -%}
    <a href="episodes.html#ep{{ n }}">{{ n }}</a>
    {%- unless forloop.last %}, {% endunless %}
  {%- endfor %}
{%- endfor %}
