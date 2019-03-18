using Toybox.WatchUi;

class TwelveMinRunDelegate extends WatchUi.BehaviorDelegate {

	var mParentView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        mParentView = view;
    }
    
    function onSelect() {
    	mParentView.startStopTimer();
    	return true;
    }
    
    function onBack() {
    	return mParentView.resetTimer();
    }
}