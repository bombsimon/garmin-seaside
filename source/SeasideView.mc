using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.WatchUi;

using Arms;

class SeasideView extends WatchUi.WatchFace {
    // Set a state to keep track of when the clock is asleep.
    var isAwake = false;

    // Declare the fonts.
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

        // Draw the background.
        drawBackground(dc);

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

        // Draw the second indicator if the device supports partial updates
        // (every second updates) or if the device is awake.
        if ( Toybox.WatchUi.WatchFace has :onPartialUpdate ) {
            onPartialUpdate(dc);
        }
        else if ( isAwake ) {
            drawSecondIndicator(dc);
        }
    }

    function onPartialUpdate(dc) {
        // Re-draw the seconds indicator.
        drawSecondIndicator(dc);
    }

    function drawBackground(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Draw the entire background yellow.
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the background black for 5/6 of the screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY);
        dc.fillRectangle(0, 0, width, height - (height / 6));
    }

    function drawSecondIndicator(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var clockTime = System.getClockTime();

        // Get the outer edge for each second.
        var outerEdge = Arms.circleOuterEdge(Arms.second(clockTime), width, height, 0);
        var x = outerEdge[0];
        var y = outerEdge[1];

        // TODO: Calculate new clipping area to know where to re-draw the
        // background. This can NOT overlap with any text.

        dc.setClip(0, 0, x, y);

        // Re-draw the background within the boundires.
        drawBackground(dc);

        // Draw a big circle to use as border.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 5);

        // Draw a smaller circle inside the bigger one.
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 3);

        // Restore the cliping.
        dc.clearClip();
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
        isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        isAwake = false;

        // Request update (to potentially hide second indicator)
        WatchUi.requestUpdate();
    }

}
