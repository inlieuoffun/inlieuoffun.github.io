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

    function daysUntil(date) {
        var then = new Date(date).getTime();
        var now = new Date().getTime();
        return Math.floor((then - now) / oneDay);
    }

    var status = document.getElementById("countdown");
    if (status) {
        status.innerHTML = episodeStatus();
        setInterval(function() {
            status.innerHTML = episodeStatus();
        }, oneMinute);
    }
    var dti = document.getElementById("dti");
    if (dti) {
        dti.innerText = daysUntil("2021-01-20T12:00:00-0400");
    }
    var dte = document.getElementById("dte");
    if (dte) {
        dte.innerText = daysUntil("2020-11-04T00:00:00-0400");
    }
})()
