using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

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
        var currentDay = getFullDayName(Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day_of_week);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY);
        dc.fillRectangle(0, 0, width, height - (height / 6));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(width / 2 + 20, height / 2 - (height * 0.25), nunito90, currentHour, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK);
        dc.drawText(width / 2 + 25, height / 2 - 20, nunito36, currentMinute, Graphics.TEXT_JUSTIFY_LEFT);

        dc.drawText(width / 2, height / 1.65, nunito12, currentDay, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_YELLOW);
        dc.drawText(width / 2, height - 30, nunito18, "1 JUN 2019", Graphics.TEXT_JUSTIFY_CENTER);

        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);
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
