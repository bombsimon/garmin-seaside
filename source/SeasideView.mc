import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Application.Properties;

import Arms;

class SeasideView extends WatchUi.WatchFace {
    var nunito90 as WatchUi.FontResource;
    var nunito36 as WatchUi.FontResource;
    var nunito18 as WatchUi.FontResource;
    var nunito12 as WatchUi.FontResource;
    var stepsIcon as Graphics.BitmapReference;

    var mBottomInfo as Number = 1;
    var mAccentColor as Number = Graphics.COLOR_YELLOW;
    var mAlwaysShowBattery as Boolean = false;

    function initialize() {
        nunito90 =
            WatchUi.loadResource(Rez.Fonts.nunitoBlack90) as
            WatchUi.FontResource;
        nunito36 =
            WatchUi.loadResource(Rez.Fonts.nunitoRegular36) as
            WatchUi.FontResource;
        nunito18 =
            WatchUi.loadResource(Rez.Fonts.nunitoRegular18) as
            WatchUi.FontResource;
        nunito12 =
            WatchUi.loadResource(Rez.Fonts.nunitoRegular12) as
            WatchUi.FontResource;
        stepsIcon =
            WatchUi.loadResource(Rez.Drawables.StepsIconYellow) as
            Graphics.BitmapReference;

        onSettingsChanged();

        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onSettingsChanged() as Void {
        mBottomInfo = getPropertyValue("BottomInfo") as Number;
        mAlwaysShowBattery = getPropertyValue("AlwaysShowBattery") as Boolean;
        var accentColor = getPropertyValue("AccentColor") as Number;

        switch (accentColor) {
            case 1:
                if (Graphics has :createColor) {
                    mAccentColor = Graphics.createColor(255, 254, 37, 80);
                } else {
                    // Best effort for devices not supporting API 4.0.0.
                    // This will most likely not render nice on the device.
                    mAccentColor = 0xfe2546;
                }

                stepsIcon =
                    WatchUi.loadResource(Rez.Drawables.StepsIconRed) as
                    Graphics.BitmapReference;

                break;
            case 2:
                if (Graphics has :createColor) {
                    mAccentColor = Graphics.createColor(255, 37, 254, 202);
                } else {
                    // Best effort for devices not supporting API 4.0.0.
                    // This will most likely not render nice on the device.
                    mAccentColor = 0x25feca;
                }

                stepsIcon =
                    WatchUi.loadResource(Rez.Drawables.StepsIconMint) as
                    Graphics.BitmapReference;

                break;
            default:
                mAccentColor = Graphics.COLOR_YELLOW;
                stepsIcon =
                    WatchUi.loadResource(Rez.Drawables.StepsIconYellow) as
                    Graphics.BitmapReference;
        }

        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {}

    // Update the view
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var clockTime = System.getClockTime();

        var currentHour = clockTime.hour.format("%02d");
        var currentMinute = clockTime.min.format("%02d");
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var currentDateString = Lang.format("$1$ $2$ $3$", [
            dateInfo.day,
            getMonth(dateInfo.month as Number),
            dateInfo.year,
        ]);

        var batteryInfo = System.getSystemStats().battery;

        var accentColorStart = (height / 6) * 5;
        var accentColorHeight = height - accentColorStart;
        var halfAccentColor = accentColorHeight / 2;
        var midOfAccentColor = height - halfAccentColor;

        var info = ActivityMonitor.getInfo();
        var steps = info.steps;

        // Draw the entire background in the accent color.
        dc.setColor(mAccentColor, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the background black for 5/6 of the screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height - height / 6);

        // Draw the hour digits.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            width / 2 + 20,
            height / 2 - 80,
            nunito90,
            currentHour,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // Draw the minute digits.
        dc.setColor(mAccentColor, Graphics.COLOR_BLACK);
        dc.drawText(
            width / 2 + 25,
            height / 2 - 38,
            nunito36,
            currentMinute,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Draw the current day.
        dc.drawText(
            width / 2,
            height / 2 + 2,
            nunito12,
            getDayOfWeek(dateInfo.day_of_week as Number),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (mAlwaysShowBattery || batteryInfo <= 20) {
            var batteryTextColor = Graphics.COLOR_WHITE;
            if (batteryInfo <= 20) {
                batteryTextColor = Graphics.COLOR_ORANGE;
            }

            var batteryText = Lang.format("$1$%", [batteryInfo.format("%2d")]);
            dc.setColor(batteryTextColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                height / 2 + 20,
                nunito18,
                batteryText,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // Current steps
        if (mBottomInfo == 1) {
            dc.drawBitmap(width / 2 - 25, accentColorStart - 25, stepsIcon);
            dc.setColor(mAccentColor, Graphics.COLOR_BLACK);
            dc.drawText(
                width / 2,
                accentColorStart - 25,
                nunito18,
                Lang.format("$1$", [steps]),
                Graphics.TEXT_JUSTIFY_LEFT
            );
        }

        // Draw the current date.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            midOfAccentColor - 10,
            nunito18,
            currentDateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );

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
        dc.setColor(mAccentColor, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 3);
    }

    function getDayOfWeek(dayOfWeek as Number) as String {
        switch (dayOfWeek) {
            case Time.Gregorian.DAY_MONDAY:
                return "MONDAY";
            case Time.Gregorian.DAY_TUESDAY:
                return "TUESDAY";
            case Time.Gregorian.DAY_WEDNESDAY:
                return "WEDNESDAY";
            case Time.Gregorian.DAY_THURSDAY:
                return "THURSDAY";
            case Time.Gregorian.DAY_FRIDAY:
                return "FRIDAY";
            case Time.Gregorian.DAY_SATURDAY:
                return "SATURDAY";
            case Time.Gregorian.DAY_SUNDAY:
                return "SUNDAY";
        }

        return "UNKNOWN";
    }

    function getMonth(month as Number) as String {
        switch (month) {
            case Time.Gregorian.MONTH_JANUARY:
                return "JAN";
            case Time.Gregorian.MONTH_FEBRUARY:
                return "FEB";
            case Time.Gregorian.MONTH_MARCH:
                return "MAR";
            case Time.Gregorian.MONTH_APRIL:
                return "APR";
            case Time.Gregorian.MONTH_MAY:
                return "MAY";
            case Time.Gregorian.MONTH_JUNE:
                return "JUN";
            case Time.Gregorian.MONTH_JULY:
                return "JUL";
            case Time.Gregorian.MONTH_AUGUST:
                return "AUG";
            case Time.Gregorian.MONTH_SEPTEMBER:
                return "SEP";
            case Time.Gregorian.MONTH_OCTOBER:
                return "OCT";
            case Time.Gregorian.MONTH_NOVEMBER:
                return "NOV";
            case Time.Gregorian.MONTH_DECEMBER:
                return "DEC";
        }

        return "UNKNOWN";
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {}

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {}

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {}
}
