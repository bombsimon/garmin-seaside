import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.Weather;
import Toybox.WatchUi;

import Arms;

class SeasideView extends WatchUi.WatchFace {
    // Watchface fonts
    private var _useLargeFont as Boolean =
        getPropertyValue("UseLargeFont") as Boolean;
    private var _largeFont as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.large) as WatchUi.FontResource;
    private var _mediumFont as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.medium) as WatchUi.FontResource;
    private var _smallFont as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.small) as WatchUi.FontResource;
    private var _tinyFont as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.tiny) as WatchUi.FontResource;
    private var _weatherFontTiny as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.weatherTiny) as WatchUi.FontResource;
    private var _weatherFontSmall as WatchUi.FontResource =
        WatchUi.loadResource(Rez.Fonts.weatherSmall) as WatchUi.FontResource;

    // Watchface customization settings
    private var _bottomInfo as Number =
        getPropertyValue("BottomInfo") as Number;
    private var _accentColor as Number =
        getPropertyValue("AccentColor") as Number;
    private var _showBatteryThreshold as Number =
        getPropertyValue("ShowBatteryThreshold") as Number;
    private var _weatherUnit as Number =
        getPropertyValue("WeatherUnit") as Number;

    // Scaling settings. These are static and the same for all devices but setup
    // as properties to make debugging easier when trying out new fonts. Might
    // come in handy if font customization becomes a thing. (Hello from
    // pre-mature optimization land).
    private var _hourWidthScale as Float =
        getPropertyValue("HourWidthScale") as Float;
    private var _hourHeightScale as Float =
        getPropertyValue("HourHeightScale") as Float;
    private var _minuteWidthScale as Float =
        getPropertyValue("MinuteWidthScale") as Float;
    private var _minuteHeightScale as Float =
        getPropertyValue("MinuteHeightScale") as Float;
    private var _dotSizeScale as Float =
        getPropertyValue("DotSizeScale") as Float;
    private var _dotHeightScale as Float =
        getPropertyValue("DotHeightScale") as Float;
    private var _firstDotWidthScale as Float =
        getPropertyValue("FirstDotWidthScale") as Float;
    private var _secondDotWidthScale as Float =
        getPropertyValue("SecondDotWidthScale") as Float;
    private var _dayHeightScale as Float =
        getPropertyValue("DayHeightScale") as Float;
    private var _dayHeightScaleLargeFont as Float =
        getPropertyValue("DayHeightScaleLargeFont") as Float;
    private var _batteryHeightScale as Float =
        getPropertyValue("BatteryHeightScale") as Float;
    private var _bottomInfoHeightScale as Float =
        getPropertyValue("BottomInfoHeightScale") as Float;
    private var _bottomInfoHeightScaleLargeFont as Float =
        getPropertyValue("BottomInfoHeightScaleLargeFont") as Float;
    private var _dateHeightScale as Float =
        getPropertyValue("DateHeightScale") as Float;
    private var _weatherIconScale as Float =
        getPropertyValue("WeatherIconScale") as Float;

    // Font dimensions are stored as memeber varaibles to only have to load them
    // once. When loaded the first time, `_dimensionsInitialized` will be set to
    // true.
    private var _dimensionsInitialized as Boolean = false;
    private var _hourDimensions as Array<Number> = [0, 0];
    private var _minuteDimensions as Array<Number> = [0, 0];
    private var _tinyDimensions as Array<Number> = [0, 0];
    private var _dateDimensions as Array<Number> = [0, 0];

    // Debug settings used to show guide lines and customize any value.
    // Enable debug settings and will load debug properties when settings
    // change.
    private var _debugMode as Boolean = false;
    private var _showDebugLines as Boolean = false;
    private var _debugHourValue as String = "";
    private var _debugMinuteValue as String = "";
    private var _debugDayValue as String = "";
    private var _debugDateValue as String = "";
    private var _debugBottomInfoValue as String = "";

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onSettingsChanged() as Void {
        _bottomInfo = getPropertyValue("BottomInfo") as Number;
        _showBatteryThreshold =
            getPropertyValue("ShowBatteryThreshold") as Number;
        _weatherUnit = getPropertyValue("WeatherUnit") as Number;
        _accentColor = getPropertyValue("AccentColor") as Number;
        _useLargeFont = getPropertyValue("UseLargeFont") as Boolean;

        onDebugSettingsChanged();

        WatchUi.requestUpdate();
    }

    function onDebugSettingsChanged() as Void {
        if (!_debugMode) {
            return;
        }

        var accentColorHex = getPropertyValue("AccentColorHex") as String;
        if (!accentColorHex.equals("")) {
            var maybeAccentColor =
                accentColorHex.toNumberWithBase(0x10) as Number?;
            if (maybeAccentColor != null) {
                _accentColor = maybeAccentColor;
            }
        }

        _hourWidthScale = getPropertyValue("HourWidthScale") as Float;
        _hourHeightScale = getPropertyValue("HourHeightScale") as Float;
        _minuteWidthScale = getPropertyValue("MinuteWidthScale") as Float;
        _minuteHeightScale = getPropertyValue("MinuteHeightScale") as Float;
        _dotHeightScale = getPropertyValue("DotHeightScale") as Float;
        _firstDotWidthScale = getPropertyValue("FirstDotWidthScale") as Float;
        _secondDotWidthScale = getPropertyValue("SecondDotWidthScale") as Float;
        _dayHeightScale = getPropertyValue("DayHeightScale") as Float;
        _dayHeightScaleLargeFont =
            getPropertyValue("DayHeightScaleLargeFont") as Float;
        _batteryHeightScale = getPropertyValue("BatteryHeightScale") as Float;
        _bottomInfoHeightScale =
            getPropertyValue("BottomInfoHeightScale") as Float;
        _bottomInfoHeightScaleLargeFont =
            getPropertyValue("BottomInfoHeightScaleLargeFont") as Float;
        _dateHeightScale = getPropertyValue("DateHeightScale") as Float;
        _weatherIconScale = getPropertyValue("WeatherIconScale") as Float;

        _showDebugLines = getPropertyValue("ShowDebugLines") as Boolean;
        _debugHourValue = getPropertyValue("DebugHourValue") as String;
        _debugMinuteValue = getPropertyValue("DebugMinuteValue") as String;
        _debugDayValue = getPropertyValue("DebugDayValue") as String;
        _debugDateValue = getPropertyValue("DebugDateValue") as String;
        _debugBottomInfoValue =
            getPropertyValue("DebugBottomInfoValue") as String;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {}

    // Update the view
    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        var middleX = width / 2;

        // On tiny devices with a resolution < 240 there's not enought room to
        // use halft the screen (height / 2) so we scale by starting everything
        // a bit higher up.
        // If the user uses large font it also looks a bit cramped so push
        // everything up a bit for those users.
        var middleY = 0.0;
        if (height < 240 || _useLargeFont) {
            middleY = height / 2.5;
        } else {
            middleY = height / 2;
        }

        var clockTime = System.getClockTime();
        var currentHour = clockTime.hour.format("%02d");
        var currentMinute = clockTime.min.format("%02d");
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var currentDay = getDayOfWeek(dateInfo.day_of_week as Number);
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

        var tinyOrSmallFont = _useLargeFont ? _smallFont : _tinyFont;
        var dayHeightScale = _useLargeFont
            ? _dayHeightScaleLargeFont
            : _dayHeightScale;

        if (!_dimensionsInitialized) {
            _hourDimensions = dc.getTextDimensions("0", _largeFont);
            _minuteDimensions = dc.getTextDimensions("0", _mediumFont);
            _tinyDimensions = dc.getTextDimensions("0", _mediumFont);
            _dateDimensions = dc.getTextDimensions("0", _smallFont);
            _dimensionsInitialized = true;
        }

        if (_debugMode) {
            if (!_debugHourValue.equals("")) {
                currentHour = _debugHourValue;
            }

            if (!_debugMinuteValue.equals("")) {
                currentMinute = _debugMinuteValue;
            }

            if (!_debugDateValue.equals("")) {
                currentDateString = _debugDateValue;
            }

            if (!_debugDayValue.equals("")) {
                currentDay = _debugDayValue;
            }
        }

        // Draw the entire background in the accent color.
        dc.setColor(_accentColor, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the background black for 5/6 of the screen.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height - height / 6);

        // Draw the hour digits.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            middleX + _hourDimensions[0] / _hourWidthScale,
            middleY - _hourDimensions[1] / _hourHeightScale,
            _largeFont,
            currentHour,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        // Draw the minute digits.
        dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            middleX + _minuteDimensions[0] * _minuteWidthScale,
            middleY - _minuteDimensions[1] / _minuteHeightScale,
            _mediumFont,
            currentMinute,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        // Draw the two dots above the minute digits.
        dc.setColor(_accentColor, _accentColor);
        dc.fillRectangle(
            middleX + _minuteDimensions[0] * _firstDotWidthScale,
            middleY - _minuteDimensions[1] / _dotHeightScale,
            width / _dotSizeScale,
            width / _dotSizeScale
        );

        dc.fillRectangle(
            middleX + _minuteDimensions[0] * _secondDotWidthScale,
            middleY - _minuteDimensions[1] / _dotHeightScale,
            width / _dotSizeScale,
            width / _dotSizeScale
        );

        // Draw the current day.
        dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            middleX,
            middleY + _tinyDimensions[1] / dayHeightScale,
            tinyOrSmallFont,
            currentDay,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (batteryInfo <= _showBatteryThreshold) {
            var batteryText = Lang.format("$1$%", [batteryInfo.format("%2d")]);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                middleX,
                middleY + _tinyDimensions[1] / _batteryHeightScale,
                tinyOrSmallFont,
                batteryText,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        drawBottomInfo(
            dc,
            width,
            height,
            middleX,
            middleY,
            accentColorStart,
            tinyOrSmallFont
        );

        // Draw the current date.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            middleX,
            midOfAccentColor - _dateDimensions[1] / _dateHeightScale,
            _smallFont,
            currentDateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Debug center cross.
        if (_debugMode && _showDebugLines) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_GREEN);
            dc.drawLine(width / 2, 0, width / 2, height);

            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLUE);
            dc.drawLine(0, height / 2, width, height / 2);
        }

        drawSecondsIndicator(dc, width, height, clockTime);
    }

    function drawBottomInfo(
        dc as Graphics.Dc,
        width as Number,
        height as Number,
        middleX as Number,
        middleY as Number or Float,
        accentColorStart as Number,
        tinyOrSmallFont as WatchUi.FontResource
    ) as Void {
        var bottomInfoHeightScale = _useLargeFont
            ? _bottomInfoHeightScaleLargeFont
            : _bottomInfoHeightScale;

        // Botton information (e.g. current steps)
        switch (_bottomInfo) {
            case 1:
                var activityInfo = ActivityMonitor.getInfo();
                var text = Lang.format("#$1$", [activityInfo.steps]);

                if (_debugMode && !_debugBottomInfoValue.equals("")) {
                    text = _debugBottomInfoValue;
                }

                dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    middleX,
                    accentColorStart -
                        _tinyDimensions[1] / bottomInfoHeightScale,
                    tinyOrSmallFont,
                    text,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                break;
            case 2:
                if (Weather has :getCurrentConditions) {
                    var weather = Weather.getCurrentConditions();
                    var weatherFont = _useLargeFont
                        ? _weatherFontSmall
                        : _weatherFontTiny;

                    if (weather != null) {
                        var icon = getWeatherIcon(weather.condition as Number);
                        var iconWidth = dc.getTextDimensions(
                            icon,
                            weatherFont
                        )[0];

                        var temperature = "" as String;
                        switch (_weatherUnit) {
                            case 0:
                                temperature = Lang.format("$1$°C", [
                                    (weather.temperature as Number).format(
                                        "%d"
                                    ),
                                ]);
                                break;
                            case 1:
                                temperature = Lang.format("$1$°F", [
                                    (
                                        (9.0 / 5.0) *
                                            (weather.temperature as Float) +
                                        32.0
                                    ).format("%d"),
                                ]);
                                break;
                        }

                        dc.setColor(_accentColor, Graphics.COLOR_TRANSPARENT);

                        dc.drawText(
                            middleX - iconWidth * _weatherIconScale,
                            accentColorStart -
                                _tinyDimensions[1] /
                                    (bottomInfoHeightScale * 1.1),
                            weatherFont,
                            icon,
                            Graphics.TEXT_JUSTIFY_CENTER
                        );

                        dc.drawText(
                            middleX,
                            accentColorStart -
                                _tinyDimensions[1] / bottomInfoHeightScale,
                            tinyOrSmallFont,
                            temperature,
                            Graphics.TEXT_JUSTIFY_LEFT
                        );
                    }
                } else {
                    dc.drawText(
                        middleX,
                        accentColorStart -
                            _tinyDimensions[1] / bottomInfoHeightScale,
                        tinyOrSmallFont,
                        "NOT SUPPORTED",
                        Graphics.TEXT_JUSTIFY_CENTER
                    );
                }

            default:
                break;
        }
    }

    function drawSecondsIndicator(
        dc as Graphics.Dc,
        width as Number,
        height as Number,
        clockTime as System.ClockTime
    ) as Void {
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
        dc.setColor(_accentColor, Graphics.COLOR_WHITE);
        dc.fillCircle(x, y, 3);
    }

    // Convert the weather condition to one of the available icons. This list is
    // a best effort to resemble the one Garmin uses for their activities:
    // https://support.garmin.com/en-MY/?faq=1N9a2SxuV90lkQ1s7g3yK8
    function getWeatherIcon(condition as Number) as String {
        switch (condition) {
            case Weather.CONDITION_CLEAR:
            case Weather.CONDITION_MOSTLY_CLEAR:
            case Weather.CONDITION_PARTLY_CLEAR:
            case Weather.CONDITION_FAIR:
                return "a";
            case Weather.CONDITION_CLOUDY:
            case Weather.CONDITION_PARTLY_CLOUDY:
            case Weather.CONDITION_MOSTLY_CLOUDY:
            case Weather.CONDITION_THIN_CLOUDS:
                return "d";
            case Weather.CONDITION_FOG:
            case Weather.CONDITION_MIST:
            case Weather.CONDITION_SMOKE:
            case Weather.CONDITION_HAZY:
            case Weather.CONDITION_HAZE:
            case Weather.CONDITION_DUST:
            case Weather.CONDITION_SAND:
            case Weather.CONDITION_VOLCANIC_ASH:
                return "c";
            case Weather.CONDITION_LIGHT_RAIN:
            case Weather.CONDITION_DRIZZLE:
            case Weather.CONDITION_SHOWERS:
            case Weather.CONDITION_LIGHT_SHOWERS:
            case Weather.CONDITION_CHANCE_OF_SHOWERS:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN:
            case Weather.CONDITION_SCATTERED_SHOWERS:
                return "f";
            case Weather.CONDITION_RAIN:
            case Weather.CONDITION_HEAVY_RAIN:
            case Weather.CONDITION_HEAVY_SHOWERS:
                return "g";
            case Weather.CONDITION_SNOW:
            case Weather.CONDITION_LIGHT_SNOW:
            case Weather.CONDITION_HEAVY_SNOW:
            case Weather.CONDITION_HAIL:
            case Weather.CONDITION_CHANCE_OF_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW:
            case Weather.CONDITION_FLURRIES:
                return "i";
            case Weather.CONDITION_RAIN_SNOW:
            case Weather.CONDITION_LIGHT_RAIN_SNOW:
            case Weather.CONDITION_HEAVY_RAIN_SNOW:
            case Weather.CONDITION_FREEZING_RAIN:
            case Weather.CONDITION_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW:
            case Weather.CONDITION_SLEET:
                return "f";
            case Weather.CONDITION_WINDY:
            case Weather.CONDITION_TORNADO:
            case Weather.CONDITION_HURRICANE:
            case Weather.CONDITION_TROPICAL_STORM:
            case Weather.CONDITION_SANDSTORM:
            case Weather.CONDITION_SQUALL:
                return "b";
            case Weather.CONDITION_THUNDERSTORMS:
            case Weather.CONDITION_CHANCE_OF_THUNDERSTORMS:
            case Weather.CONDITION_SCATTERED_THUNDERSTORMS:
                return "k";
            case Weather.CONDITION_WINTRY_MIX:
            case Weather.CONDITION_ICE:
            case Weather.CONDITION_ICE_SNOW:
                return "j";
            case Weather.CONDITION_UNKNOWN:
            default:
                return "l";
        }
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
