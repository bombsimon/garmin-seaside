import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module Arms {
    // Each minute or second adds 360 / 60 (6) degrees angle.
    var degreesPerMinuteOrSecond as Float = (360 / 60) as Float;

    // Each hour adds 360 / 12 (30) degrees.
    var degressPerHour as Float = (360 / 12) as Float;

    function hour(clockTime as ClockTime) as Float {
        // Calculate base angle of the hour arm.
        var hourDegrees = clockTime.hour * degressPerHour;

        // Calculate how much of an hour the current minute arm is angled at.
        // Ex: nn:15 means 1/4th of an hour (or 0,25).
        var minutePartsOfHour = clockTime.min.toFloat() / 60;

        // Add the extra angle to the hour angle to show a proper hour arm.
        var extraDegrees = minutePartsOfHour * degressPerHour;

        return hourDegrees + extraDegrees;
    }

    function minute(clockTime as ClockTime) as Float {
        return minuteOrSecond(clockTime.min);
    }

    function second(clockTime as ClockTime) as Float {
        return minuteOrSecond(clockTime.sec);
    }

    function minuteOrSecond(arm as Number) as Float {
        var degrees = arm * degreesPerMinuteOrSecond;

        return degrees;
    }
}
