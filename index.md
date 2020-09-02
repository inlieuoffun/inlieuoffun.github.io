---
layout: home
---

There's a coronavirus pandemic on. We aren't allowed to have fun anymore; but
*in lieu of fun*, you can grab a beverage of your choice and come hang out with
us, your hosts [Ben Wittes][ben] and [Kate Klonick][kate], every day at 5:00pm
US Eastern time.

![In Lieu of Fun Logo](/assets/ilof-logo.jpg)
<span style="font-size: 60%">Logo created by Kevin Thorn of
[NuggetHead Studioz](https://nuggethead.net/), used here with gratitude and
permission.</span>

**In Lieu of Fun** is a casual, unstructured webcast that has been broadcasting
daily since March 25, 2020.  We talk about news, law, life, art, squirrels,
murder hornets, Baby Cannons, and whatever else may come up. On most weekdays
there are pre-announced guests, while Saturdays are just Ben & Kate planning
the upcoming week. Sundays usually include an unannounced Mystery Guest.

Episodes are streamed live on [Crowdcast](https://www.crowdcast.io/lawfareblog),
[YouTube][yt], and a variety of other streaming platforms. You can find links
to recordings of past episodes from the [Episode Log](episodes.html).

### &#x1F389; New for September: ILoF Merch!

**Join the Order of the Baby Cannon!** You can now get your own *In Lieu of Fun*
mugs, clothing, and more from the [Revolution Art Shop][ras]!
All proceeds from ILoF paraphernalia go to support [World Central Kitchen][wck].

## Recent Episodes

{% capture newline %}
{% endcapture %}
{% assign rev = site.episodes | reverse %}
{% for ep in rev limit:2 -%}
{% capture url %}{{ site.url }}/stream/{{ ep.episode }}{% endcapture %}
- [Episode {{ ep.episode }}]({{ site.url}}/episode/{{ ep.episode }})
   | {{ ep.date | date: "%B %d, %Y" }}
   | [stream]({{ url }}){% if ep.guests %}
   | *Guests:* {{ ep.guests | map: "name" | join: ", " }}{% else %}
   | Just Ben & Kate{% endif %}
{%- if ep.summary %}
    - {{ ep.summary | strip | replace: newline, " " }}
{%- elsif ep.topics %}
    - *Topics:* {{ ep.topics | strip | replace: newline, " " }}{% endif %}
{% endfor %}

## Quick Reference

- Visit the [Episode Log](episodes.html) or the [Guest List](guests.html).

- Get you some [ILoF merchandise][ras]! &#x1F60E;  

- **See something wrong?** Please [file an issue](http://issues.inlieuof.fun/new)
  describing the problem, and one of our loyal volunteers will look into it.

   - You can also [view or send pull requests](http://repo.inlieuof.fun) for this
     site, or [check the build status](http://build.inlieuof.fun).


[ben]: https://twitter.com/benjaminwittes
[kate]: https://twitter.com/klonick
[yt]: https://www.youtube.com/channel/UC8lKFNnYE1War3a41Q41fMw
[wck]: https://wck.org/
[ras]: https://revolutionartshop.com/collections/order-of-the-baby-cannon-in-lieu-of-fun
