(() => {
    const oneMinute = 60*1000;
    const oneHour = 60*oneMinute;
    const oneDay = 24*oneHour;

    function todayUTC() {
        var now = new Date(); // stub here for testing
        return {
            now:   now.getTime(),
            start: Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()),
        };
    }

    function episodeStatus() {
        var today     = todayUTC();
        var nextStart = today.start + 22*oneHour;
        var nextEnd   = nextStart + oneHour;

        if (today.now > nextEnd) {
            if (today.now < nextEnd + 15*oneMinute) {
                return '🕕 The <a href="/episode/latest">latest episode</a> just finished streaming.';
            }
            nextStart += oneDay;
            nextEnd += oneDay;
        } else if (today.now > nextStart) {
            return 'The current episode is <a href="/stream/latest">streaming live</a>. 👀';
        }

        var diff = new TimeDiff(nextStart, today.now);
        var tag = diff.hours == 0 ? "🔜 " : "";
        var howLong = [];
        if (diff.hours > 0) {
            howLong.push(diff.hoursLabel());
        }
        if (diff.minutes > 0) {
            howLong.push(diff.minutesLabel());
        } else if (diff.hours == 0) {
            howLong.push('<a href="/stream/latest">just a moment</a>');
        }
        return tag + "🕔 The next show goes live in " + howLong.join(", ") + ".";
    }

    class TimeDiff {
        constructor(then, now) {
            var diff = Math.abs(then - now);
            this.past = then <= now;

            var days = diff/oneDay;
            this.days = Math.floor(days);
            var hours = (days - this.days) * (oneDay / oneHour);
            this.hours = Math.floor(hours);
            var mins = (hours - this.hours) * (oneHour / oneMinute);
            this.minutes = Math.round(mins);
        }

        static label(n, base, terse=false) {
            var tag = terse ? base[0] : " " + (n == 1 ? base : base+"s");
            return n.toString() + tag;
        }

        daysLabel(opt={})    { return TimeDiff.label(this.days, "day", opt.terse); }
        hoursLabel(opt={})   { return TimeDiff.label(this.hours, "hour", opt.terse); }
        minutesLabel(opt={}) { return TimeDiff.label(this.minutes, "minute", opt.terse); }
    }

    function describeTimeUntil(date) {
        var diff = new TimeDiff(new Date(date).getTime(), todayUTC().now);
        var parts = [];
        if (diff.days > 0) {
            if (diff.days >= 14 && diff.hours > 0) { diff.days += 1; }
            parts.push(diff.daysLabel({terse: true}));
        }
        if (diff.days < 14) {
            if (diff.hours > 0) {
                parts.push(diff.hoursLabel({terse: true}));
            }
            if (diff.days == 0 && diff.hours < 12) {
                parts.push(diff.minutesLabel({terse: true}));
            }
        }
        return parts.join(" ")+(diff.past ? " ago" : "");
    }

    const inauguration = "2021-01-20T12:00:00-0500";
    const anniversary = "2021-03-25T17:00:00-0500";

    var status = document.getElementById("countdown");
    var dti = document.getElementById("dti");
    var dta = document.getElementById("dta");
    function update() {
        status.innerHTML = episodeStatus();
        dti.innerText = describeTimeUntil(inauguration);
	dta.innerText = describeTimeUntil(anniversary);
    }

    update();
    setInterval(update, oneMinute);
})()
