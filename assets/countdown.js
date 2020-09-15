(() => {
    function unit(count, base) {
        return count == 1 ? base : base+"s";
    }

    const oneMin = 60*1000;
    const oneHour = 60*oneMin;
    const oneDay = 24*oneHour;

    function episodeStatus() {
        var now = new Date();
        var nextStart = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), 21);
        var nextEnd = nextStart + oneHour;
        var nowTime = now.getTime();
        if (nowTime > nextEnd) {
            if (nowTime < nextEnd + 20*oneMin) {
                return "The latest episode just finished streaming.";
            }
            nextStart += oneDay;
            nextEnd += oneDay;
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
