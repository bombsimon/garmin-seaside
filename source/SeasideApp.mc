import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SeasideApp extends Application.AppBase {
    var mView as SeasideView;

    function initialize() {
        mView = new SeasideView();

        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) as Void {}

    // onStop() is called when your application is exiting
    function onStop(state) as Void {}

    // Called on settings change.
    function onSettingsChanged() {
        mView.onSettingsChanged();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [mView] as Array<WatchUi.InputDelegate or WatchUi.View>;
    }
}
