(() => {
    function unit(count, base) {
        return count == 1 ? base : base+"s";
    }

    function episodeStatus() {
        var now = new Date();
        var nextStart = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), 21);
        var nextEnd = nextStart + 3600000;
        var nowTime = now.getTime();
        if (nowTime > nextEnd) {
            var day = 24 * 3600000;
            nextStart += day;
            nextEnd += day;
        } else if (nowTime > nextStart) {
            return "The current episode is streaming live.";
        }

        var timeLeft = (nextStart - nowTime) / 3600000
        var hrs = Math.floor(timeLeft);
        var min = Math.floor((timeLeft - hrs) * 60);
        var howLong = (hrs > 0 ?
                       `${hrs} ${unit(hrs, "hour")}, ` : "") +
            `${min} ${unit(min, "minute")}.`;
        return "The next show goes live in " + howLong;
    }

    var status = document.getElementById("countdown");
    if (status) {
        status.innerText = episodeStatus();
        setInterval(function() {
            status.innerText = episodeStatus();
        }, 60000);
    }
})()
