using Toybox.Math;
using Toybox.System;
using Toybox.WatchUi as Ui;

module Arms {
    // Each minute or second adds 360 / 60 (6) degrees angle.
    var degreesPerMinuteOrSecond = 360 / 60;

    // Each hour adds 360 / 12 (30) degrees.
    var degressPerHour = 360 / 12;

    // Return the angle of the hour arm based on the current time.
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

    // Return the angle of the minute arm based on the current time.
    function minute(clockTime) {
        return minuteOrSecond(clockTime.min);
    }

    // Return the angle of the second arm based on the current time.
    function second(clockTime) {
        return minuteOrSecond(clockTime.sec);
    }

    function minuteOrSecond(arm) {
        var degrees = arm * degreesPerMinuteOrSecond;

        return degrees;
    }

    // Return the X and Y coordinates for the outer circle minus the passed
    // offset. This can be used if you want to make an indicator of where the
    // second arm would end based on the current time.
    // Example when the clock is 14:10:15, this function will return
    // [width,height/2] if the angle of the second (Arms.second) is passed.
    function circleOuterEdge(angle, width, height, offset) {
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
        var yAngle = angle;

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

        return [x, y];
    }
}