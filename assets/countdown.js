(() => {
    function unit(count, base) {
        return count == 1 ? base : base+"s";
    }

    const oneMinute = 60*1000;
    const oneHour = 60*oneMinute;
    const oneDay = 24*oneHour;

    function episodeStatus() {
        // For testing:
        //var now = new Date("2020-09-19T21:00:00Z")
        var now = new Date();
        var nextStart = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), 21);
        var nextEnd = nextStart + oneHour;
        var nowTime = now.getTime();
        if (nowTime > nextEnd) {
            if (nowTime < nextEnd + 15*oneMinute) {
                return '🕕 The <a href="/episode/latest">latest episode</a> just finished streaming.';
            }
            nextStart += oneDay;
            nextEnd += oneDay;
        } else if (nowTime > nextStart) {
            return 'The <a href="/stream/latest">current episode</a> is streaming live. 👀';
        }

        var timeLeft = (nextStart - nowTime) / oneHour;
        var hrs = Math.floor(timeLeft);
        var min = Math.floor((timeLeft - hrs) * 60);
        var tag = hrs == 0 ? "🔜 " : "";

        var howLong = [];
        if (hrs > 0) {
            howLong.push(`${hrs} ${unit(hrs, "hour")}`);
        }
        if (min > 0) {
            howLong.push(`${min} ${unit(min, "minute")}`);
        } else if (hrs == 0) {
            howLong.push("just a moment");
        }
        return tag + "🕔 The next show goes live in " + howLong.join(", ") + ".";
    }

    function timeUntil(date) {
        var then = new Date(date).getTime();
        var now = new Date().getTime();
        var diff = Math.abs(then - now);
        var out = {past: then <= now};

        var days = diff/oneDay;
        out.days = Math.floor(days);
        var hours = (days - out.days) * (oneDay / oneHour);
        out.hours = Math.floor(hours);
        var mins = (hours - out.hours) * (oneHour / oneMinute);
        out.minutes = Math.round(mins);
        return out;
    }

    function describeTimeUntil(date) {
        var time = timeUntil(date);
        var parts = [];
        if (time.days > 0) {
            parts.push(time.days + "d");
        }
        if (time.days < 7) {
            if (time.hours > 0) {
                parts.push(time.hours + "h");
            }
            if (time.hours < 5) {
                parts.push(time.minutes + "m");
            }
        }
        return parts.join(" ")+(time.past ? " ago" : "");
    }

    const inaguruation = "2021-01-20T12:00:00-0400";
    const pollsOpen = "2020-11-03T05:00:00-0400"; // Earliest: VT

    var status = document.getElementById("countdown");
    status.innerHTML = episodeStatus();
    var dti = document.getElementById("dti");
    dti.innerText = describeTimeUntil(inaguruation);
    var dte = document.getElementById("dte");
    dte.innerText = describeTimeUntil(pollsOpen);

    setInterval(function() {
        status.innerHTML = episodeStatus();
        dti.innerText = describeTimeUntil(inaguruation);
        dte.innerText = describeTimeUntil(pollsOpen);
    }, oneMinute);
})()
