using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi;

using Arms;

class SeasideView extends WatchUi.WatchFace {
    var nunito90 = null;
    var nunito36 = null;
    var nunito18 = null;
    var nunito12 = null;

    function initialize() {
        nunito90 = WatchUi.loadResource(Rez.Fonts.nunitoBlack90);
        nunito36 = WatchUi.loadResource(Rez.Fonts.nunitoRegular36);
        nunito18 = WatchUi.loadResource(Rez.Fonts.nunitoRegular18);
        nunito12 = WatchUi.loadResource(Rez.Fonts.nunitoRegular12);

        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var clockTime = System.getClockTime();

        var currentHour = clockTime.hour.format("%02d");
        var currentMinute = clockTime.min.format("%02d");
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var currentDay = getFullDayName(dateInfo.day_of_week);
        var currentDateString = Lang.format("$1$ $2$ $3$", [dateInfo.day, dateInfo.month.toUpper(), dateInfo.year]);

        // Draw the entire background yellow.
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the background black for 5/6 of the screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY);
        dc.fillRectangle(0, 0, width, height - (height / 6));

        // Draw the hour digits.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(width / 2 + 20, height / 2 - (height * 0.25), nunito90, currentHour, Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw tne minute digits.
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
        dc.drawText(width / 2 + 25, height / 2 - 20, nunito36, currentMinute, Graphics.TEXT_JUSTIFY_LEFT);

        // Draw the current day.
        dc.drawText(width / 2, height / 1.65, nunito12, currentDay, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw the current date.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_YELLOW);
        dc.drawText(width / 2, height - 30, nunito18, currentDateString, Graphics.TEXT_JUSTIFY_CENTER);

        // To draw a seconds indicator we need to figure out the outer circle of
        // the watch face for each second.
        //
        // Usually in mathematics an angle is calcualted from the X axis and
        // counter clockwize. This means that 0,1 in a grid would be 0 degrees
        // whereas we want 1,0 to be zero degrees and 0,-1 to be 90 degrees.
        //
        //          0 sec
        //          0
        //          +
        //          |
        // 45 sec   |     15 sec
        // 270+----0,0----+90
        //          |
        //          |
        //          +
        //         30 sec
        //         180
        //
        // Y angle is the angle from the Y-axis calculated by taking 360 degrees
        // divided by 60 seconds multiplied by the current second.
        // 00 => 0 degrees
        // 15 => 90 degrees
        // 30 => 180 degrees
        // 45 => 270 degrees
        var yAngle = Arms.second(clockTime);

        // Since we want to calculate our coordinates by conventional algorithms
        // we just add 270 degrees to spin the coordinate 3/4 forward. We can't
        // reduce the value from 90 because even though the cos and sin result
        // would be the same we would not be able to calcualte the radiant.
        var xAngle = yAngle + 270;

        // The radius is half the screen - given a round screen that is.
        var radius = width / 2;

        // Calculate cos (width) and sin (height) for each given angle. Since
        // the cos and sin functions in the Maths library takes radiants we must
        // convert our angle from X to radiant. The formulate to convert into
        // rad is 1° × π/180 = 0,01745rad
        var cos = Math.cos(xAngle * (Math.PI / 180));
        var sin = Math.sin(xAngle * (Math.PI / 180));

        // To get the edge of the circle where we would draw we multiply the
        // result with our radius.
        var xDot = cos * radius;
        var yDot = sin * radius;

        // And since the watch face doesn't have it's center at 0,0 but rather
        // (width / 2),(height / 2), we must add an offset which in this case is
        // the radius (meaning the center of the clock would be at 0,0 if we
        // moved it one radius to the left and one radius down).
        //
        //    ^
        //    |  X X
        //    | X   X
        //    |X     X
        //    | X   X
        //    |   X
        // +-0,0-------->
        //    |
        //    +
        var x = radius + xDot;
        var y = radius + yDot;

        // Draw a big circle to use as border.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 5);

        // Draw a smaller circle inside the bigger one.
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 3);
    }

    function getFullDayName(short) {
        var long = "";

        switch (short) {
            case "Mon":
                long = "MONDAY";
                break;
            case "Tue":
                long = "TUESDAY";
                break;
            case "Wed":
                long = "WEDNESDAY";
                break;
            case "Thu":
                long = "THURSDAY";
                break;
            case "Fri":
                long = "FRIDAY";
                break;
            case "Sat":
                long = "SATURDAY";
                break;
            case "Sun":
                long = "SUNDAY";
                break;
        }

        return long;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
