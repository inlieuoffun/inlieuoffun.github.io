(() => {
    function unit(count, base) {
        return count == 1 ? base : base+"s";
    }

    const oneMinute = 60*1000;
    const oneHour = 60*oneMinute;
    const oneDay = 24*oneHour;

    function episodeStatus() {
        // For testing:
        //var now = new Date("2020-09-19T20:53:11Z")
        var now = new Date();
        var nextStart = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), 21);
        var nextEnd = nextStart + oneHour;
        var nowTime = now.getTime();
        if (nowTime > nextEnd) {
            if (nowTime < nextEnd + 15*oneMinute) {
                return "The latest episode just finished streaming.";
            }
            nextStart += oneDay;
            nextEnd += oneDay;
        } else if (nowTime > nextStart) {
            return "The current episode is streaming live.";
        }

        var timeLeft = (nextStart - nowTime) / oneHour;
        var hrs = Math.floor(timeLeft);
        var min = Math.floor((timeLeft - hrs) * 60);
        var tag = hrs == 0 ? "🔜 " : "";
        var howLong =
            (hrs > 0 ?
             ` ${hrs} ${unit(hrs, "hour")}` : "") +
            (min > 0 ?
             ` ${min} ${unit(min, "minute")}.` :
             (hrs > 0 ? "." : " just a moment!"));
        return tag + "The next show goes live in" + howLong;
    }

    var status = document.getElementById("countdown");
    if (status) {
        status.innerText = episodeStatus();
        setInterval(function() {
            status.innerText = episodeStatus();
        }, oneMinute);
    }
})()
