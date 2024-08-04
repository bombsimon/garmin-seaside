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
    var largeFont as WatchUi.FontResource;
    var mediumFont as WatchUi.FontResource;
    var smallFont as WatchUi.FontResource;
    var tinyFont as WatchUi.FontResource;

    var mBottomInfo as Number = 1;
    var mAccentColor as Number = 0xffcc00;
    var mAlwaysShowBattery as Boolean = false;

    function initialize() {
        largeFont =
            WatchUi.loadResource(Rez.Fonts.large) as WatchUi.FontResource;
        mediumFont =
            WatchUi.loadResource(Rez.Fonts.medium) as WatchUi.FontResource;
        smallFont =
            WatchUi.loadResource(Rez.Fonts.small) as WatchUi.FontResource;
        tinyFont = WatchUi.loadResource(Rez.Fonts.tiny) as WatchUi.FontResource;

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
        mAccentColor = getPropertyValue("AccentColor") as Number;

        var accentColorHex = getPropertyValue("AccentColorHex") as String;
        if (!accentColorHex.equals("")) {
            mAccentColor = accentColorHex.toNumberWithBase(0x10) as Number;
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

        var activityInfo = ActivityMonitor.getInfo();

        // Draw the entire background in the accent color.
        dc.setColor(mAccentColor, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the background black for 5/6 of the screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height - height / 6);

        // Settings
        var showDebugLines = getPropertyValue("ShowDebugLines") as Boolean;
        var hourWidthScale = getPropertyValue("HourWidthScale") as Float;
        var hourHeightScale = getPropertyValue("HourHeightScale") as Float;
        var minuteWidthScale = getPropertyValue("MinuteWidthScale") as Float;
        var minuteHeightScale = getPropertyValue("MinuteHeightScale") as Float;
        var dotHeightScale = getPropertyValue("DotHeightScale") as Float;
        var firstDotWidthScale =
            getPropertyValue("FirstDotWidthScale") as Float;
        var secondDotWidthScale =
            getPropertyValue("SecondDotWidthScale") as Float;
        var dayHeightScale = getPropertyValue("DayHeightScale") as Float;
        var batteryHeightScale =
            getPropertyValue("BatteryHeightScale") as Float;
        var bottomInfoHeightScale =
            getPropertyValue("BottomInfoHeightScale") as Float;
        var dateHeightScale = getPropertyValue("DateHeightScale") as Float;

        var debugHourValue = getPropertyValue("DebugHourValue") as String;
        var debugMinuteValue = getPropertyValue("DebugMinuteValue") as String;
        var debugDayValue = getPropertyValue("DebugDayValue") as String;
        var debugDateValue = getPropertyValue("DebugDateValue") as String;
        var debugBottomInfoValue =
            getPropertyValue("DebugBottomInfoValue") as String;

        // Draw the hour digits.
        if (!debugHourValue.equals("")) {
            currentHour = debugHourValue;
        }

        var hourDimentions = dc.getTextDimensions("0", largeFont);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2 + hourDimentions[0] / hourWidthScale,
            height / 2 - hourDimentions[1] / hourHeightScale,
            largeFont,
            currentHour,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // Draw the minute digits.
        if (!debugMinuteValue.equals("")) {
            currentMinute = debugMinuteValue;
        }

        var minuteDimentions = dc.getTextDimensions("0", mediumFont);

        dc.setColor(mAccentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2 + minuteDimentions[0] * minuteWidthScale,
            height / 2 - minuteDimentions[1] / minuteHeightScale,
            mediumFont,
            currentMinute,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Draw the two dots above the minute digits.
        dc.setColor(mAccentColor, mAccentColor);
        dc.fillRectangle(
            width / 2 + minuteDimentions[0] * firstDotWidthScale,
            height / 2 - minuteDimentions[1] / dotHeightScale,
            width / 90,
            width / 90
        );

        dc.fillRectangle(
            width / 2 + minuteDimentions[0] * secondDotWidthScale,
            height / 2 - minuteDimentions[1] / dotHeightScale,
            width / 90,
            width / 90
        );

        // Draw the current day.
        var currentDay = getDayOfWeek(dateInfo.day_of_week as Number);
        if (!debugDayValue.equals("")) {
            currentDay = debugDayValue;
        }

        var tinyDimensions = dc.getTextDimensions("0", mediumFont);

        dc.setColor(mAccentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2 + tinyDimensions[1] / dayHeightScale,
            tinyFont,
            currentDay,
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
                height / 2 + tinyDimensions[1] / batteryHeightScale,
                tinyFont,
                batteryText,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // Current steps
        if (mBottomInfo == 1 || !debugBottomInfoValue.equals("")) {
            var text = Lang.format("#$1$", [activityInfo.steps]);
            if (!debugBottomInfoValue.equals("")) {
                text = debugBottomInfoValue;
            }

            dc.setColor(mAccentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                accentColorStart - tinyDimensions[1] / bottomInfoHeightScale,
                tinyFont,
                text,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // Draw the current date.
        if (!debugDateValue.equals("")) {
            currentDateString = debugDateValue;
        }

        var dateDimensions = dc.getTextDimensions("0", smallFont);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            midOfAccentColor - dateDimensions[1] / dateHeightScale,
            smallFont,
            currentDateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Debug center cross.
        if (showDebugLines) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_GREEN);
            dc.drawLine(width / 2, 0, width / 2, height);

            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLUE);
            dc.drawLine(0, height / 2, width, height / 2);
        }

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
                return "M  O  N  D  A  Y";
            case Time.Gregorian.DAY_TUESDAY:
                return "T  U E  S  D  A  Y";
            case Time.Gregorian.DAY_WEDNESDAY:
                return "W  E  D  N  E  S  D  A  Y";
            case Time.Gregorian.DAY_THURSDAY:
                return "T  H  U  R  S  D  A  Y";
            case Time.Gregorian.DAY_FRIDAY:
                return "F  R  I  D  A  Y";
            case Time.Gregorian.DAY_SATURDAY:
                return "S  A  T  U  R  D A  Y";
            case Time.Gregorian.DAY_SUNDAY:
                return "S  U  N  D  A  Y";
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
