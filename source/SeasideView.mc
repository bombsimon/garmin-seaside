import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Application.Properties;

import Arms;

class BottomArea extends WatchUi.Drawable {
    var mTop as Number = 0;
    var mAccentColor as Number = 0xfe2546;

    typedef AreaParams as {
        :top as Number,
    };

    function initialize(params as AreaParams) {
        Drawable.initialize(params);

        var top = params[:top];
        if (top != null) {
            mTop = top;
        }
    }

    function draw(dc) {
        dc.setColor(mAccentColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, mTop, 500, 500);
    }

    function setColor(color as Number) as Void {
        mAccentColor = color;
    }
}

class SeasideView extends WatchUi.WatchFace {
    var stepsIcon as Graphics.BitmapReference;

    var mBottomArea as BottomArea?;
    var mBottomInfo as Number = 1;
    var mAccentColor as Number = Graphics.COLOR_YELLOW;
    var mAlwaysShowBattery as Boolean = false;
    var mIsRound as Boolean = false;

    function initialize() {
        stepsIcon =
            WatchUi.loadResource(Rez.Drawables.StepsIconYellow) as
            Graphics.BitmapReference;

        var deviceSettings = System.getDeviceSettings();
        mIsRound = deviceSettings.screenShape == System.SCREEN_SHAPE_ROUND;

        onSettingsChanged();

        WatchFace.initialize();
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

        if (mBottomArea != null) {
            mBottomArea.setColor(mAccentColor);
        }

        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {}

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));

        mBottomArea = View.findDrawableById("BottomArea") as BottomArea?;
        if (mBottomArea != null) {
            mBottomArea.setColor(mAccentColor);
        }
    }

    function onUpdate(dc) {
        var clockTime = System.getClockTime();

        var currentHour = clockTime.hour.format("%02d");
        var currentMinute = clockTime.min.format("%02d");
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var currentDay = getFullDayName(dateInfo.day_of_week as String);
        var currentDateString = Lang.format("$1$ $2$ $3$", [
            dateInfo.day,
            (dateInfo.month as String).toUpper(),
            dateInfo.year,
        ]);

        var hour = View.findDrawableById("HourLabel") as WatchUi.Text;
        hour.setText(currentHour);

        var minute = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        minute.setColor(mAccentColor);
        minute.setText(currentMinute);

        var weekday = View.findDrawableById("WeekdayLabel") as WatchUi.Text;
        weekday.setColor(mAccentColor);
        weekday.setText(currentDay);

        var date = View.findDrawableById("DateLabel") as WatchUi.Text;
        date.setText(currentDateString);

        var batteryInfo = System.getSystemStats().battery;
        var battery = View.findDrawableById("BatteryLabel") as WatchUi.Text;
        var showBattery = mAlwaysShowBattery || batteryInfo <= 20;

        battery.setVisible(showBattery);

        if (showBattery) {
            var batteryTextColor = Graphics.COLOR_WHITE;
            if (batteryInfo <= 20) {
                batteryTextColor = Graphics.COLOR_ORANGE;
            }

            var batteryText = Lang.format("$1$%", [batteryInfo.format("%2d")]);
            battery.setColor(batteryTextColor);
            battery.setText(batteryText);
        }

        var bottomInfoLabel =
            View.findDrawableById("BottomInfoLabel") as WatchUi.Text;
        var bottomInfo = View.findDrawableById("BottomInfo") as WatchUi.Bitmap;

        bottomInfo.setVisible(mBottomInfo != 0);
        bottomInfoLabel.setVisible(mBottomInfo != 0);

        if (mBottomInfo == 1) {
            var info = ActivityMonitor.getInfo();
            var steps = info.steps;

            bottomInfoLabel.setColor(mAccentColor);
            bottomInfoLabel.setText(Lang.format("$1$", [steps]));

            bottomInfo.setBitmap(stepsIcon);
        }

        View.onUpdate(dc);

        drawSecondCircle(dc);
    }

    function drawSecondCircle(dc as Graphics.Dc) as Void {
        if (!mIsRound) {
            return;
        }

        var width = dc.getWidth();
        var height = dc.getHeight();
        var clockTime = System.getClockTime();

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

    function getFullDayName(short as String) as String {
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
    function onHide() {}

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {}

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {}
}
