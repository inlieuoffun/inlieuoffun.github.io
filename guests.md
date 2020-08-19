---
layout: page
title: Guest List
---

The following guests have appeared on *In Lieu of Fun*. They are listed in
order of first appearance.

| Guest | Episodes |
|-------|----------|
{%- for guest in site.data.guests.guests %}
| {% if guest.url %}<a href="{{ guest.url }}">{% endif -%}
  {{ guest.name }}
  {%- if guest.url %}</a>{% endif %}
  {%- if guest.twitter %} (<a href="https://twitter.com/{{ guest.twitter }}">@
      {{- guest.twitter }}</a>){% endif -%} |
  {%- for n in guest.episodes -%}
    <a href="episodes.html#ep{{ n }}">{{ n }}</a>
    {%- unless forloop.last %}, {% endunless %}
  {%- endfor %}
{%- endfor %}
