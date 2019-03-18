using Toybox.Application;
using Toybox.WatchUi;

(:background)
class TwelveMinRunApp extends Application.AppBase {
	
	var mTimerView;
	var mBackgroundData;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    	if( mTimerView ) {
    		mTimerView.saveProperties();
    		mTimerView.setBackgroundEvent();
    	}
    	Toybox.System.println(mProperties);
    }

    function onBackgroundData(data){
    	if( mTimerView ) {
    		mTimerView.backgroundEvent(data);
    	} else {
    		mBackgroundData = data;
    	}
    }
    
    function getInitialView() {
    	mTimerView = new TwelveMinRunView(mBackgroundData);
    	mTimerView.deleteBackgroundEvent();
        return [mTimerView, new TwelveMinRunDelegate(mTimerView) ];
    }
	
	function getServiceDelegate(){
		return [new BackgroundTimerServiceDelegate()];
	}
	
	function objectStoreGet(key, defaultValue) {
		var value = Application.getApp().getProperty(key);
		if((value == null) && (defaultValue != null)) {
			value = defaultValue;
			Application.getApp().setProperty(key, value);
		}
		return value;
	}
	
	function objectStorePut(key, value) {
		Application.getApp().setProperty(key, value);
	}
}
