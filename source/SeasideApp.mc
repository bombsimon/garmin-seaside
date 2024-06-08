import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:properties_and_storaged)
function getPropertyValue(key as PropertyKeyType) as PropertyValueType {
    return Properties.getValue(key);
}

(:object_store)
function getPropertyValue(key as PropertyKeyType) as PropertyValueType {
    return Application.getApp().getProperty(key);
}

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
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [mView];
    }
}
