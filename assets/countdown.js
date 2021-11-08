(() => {
    const oneMinute = 60*1000;
    const oneHour = 60*oneMinute;
    const oneDay = 24*oneHour;
    const showTimeUTC = 22*oneHour;
    const FRIDAY = 5;
    const SATURDAY = 6;
    const SUNDAY = 0;

    function todayUTC() { return dateInUTC(null); }

    function dateInUTC(date) {
        var now = date ? new Date(date) : new Date();  // stub here for testing
        return {
            now:     now.getTime(),
            weekDay: now.getDay(), // 0=Sunday, ...
            start:   Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()),
        };
    }

    function todayShowTime(today) {
        var nextStart = today.start;
        if (today.weekDay == SATURDAY) {
            nextStart += 2*oneDay;
        } else if (today.weekDay == SUNDAY) {
            nextStart += 1*oneDay;
        }
        return nextStart + showTimeUTC;
    }

    function episodeStatus() {
        var today     = todayUTC();
        var nextStart = todayShowTime(today);
        var nextEnd   = nextStart + oneHour;

        if (today.now > nextEnd) {
            if (today.now < nextEnd + 15*oneMinute) {
                return '🕕 The <a href="/episode/latest">latest episode</a> just finished streaming.';
            } else if (today.weekDay == FRIDAY) {
                nextStart += 3*oneDay;
            } else {
                nextStart += 1*oneDay;
            }
        } else if (today.now > nextStart) {
            return 'The current episode is <a href="/stream/latest">streaming live</a>. 👀';
        }

        var diff = new TimeDiff(nextStart, today.now);
        var tag = (diff.days == 0 && diff.hours == 0) ? "🔜 " : "";
        var howLong = [];
        if (diff.days > 0) {
            howLong.push(diff.daysLabel());
        }
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
            if (diff.days == 0 && diff.hours > 0) {
                parts.push(diff.minutesLabel({terse: true}));
            }
        }
        return parts.join(" ")+(diff.past ? " ago" : "");
    }

    var status = document.getElementById("countdown");
    function update() {
        status.innerHTML = episodeStatus();
    }

    update();
    setInterval(update, oneMinute);
})()
