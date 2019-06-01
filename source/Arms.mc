using Toybox.System;
using Toybox.WatchUi as Ui;

module Arms {
    // Each minute or second adds 360 / 60 (6) degrees angle.
    var degreesPerMinuteOrSecond = 360 / 60;

    // Each hour adds 360 / 12 (30) degrees.
    var degressPerHour = 360 / 12;

    function hour(clockTime) {
        // Calculate base angle of the hour arm.
        var hourDegrees = clockTime.hour * degressPerHour;

        // Calculate how much of an hour the current minute arm is angled at.
        // Ex: nn:15 means 1/4th of an hour (or 0,25).
        var minutePartsOfHour = clockTime.min.toFloat() / 60;

        // Add the extra angle to the hour angle to show a proper hour arm.
        var extraDegrees = minutePartsOfHour * degressPerHour;

        return hourDegrees + extraDegrees;
    }

    function minute(clockTime) {
        return minuteOrSecond(clockTime.min);
    }

    function second(clockTime) {
        return minuteOrSecond(clockTime.sec);
    }

    static function minuteOrSecond(arm) {
        var degrees = arm * degreesPerMinuteOrSecond;

        return degrees;
    }

    class ArmDrawer extends Ui.Drawable {
        function initialize(params) {
            Drawable.initialize(params);
        }

        function draw(dc) {
            System.println("Should draw here");
        }
    }
}