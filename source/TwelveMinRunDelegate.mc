using Toybox.WatchUi;

class TwelveMinRunDelegate extends WatchUi.BehaviorDelegate {

	var mParentView;
	var session = null;
	
    function initialize(view) {
        BehaviorDelegate.initialize();
        mParentView = view;
    }
    
    function onSelect() {
    	mParentView.startStopTimer();
    	if( Toybox has :ActivityRecording ) {
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                session = ActivityRecording.createSession({:name=>"Run", :sport=>ActivityRecording.SPORT_RUNNING});
                session.start();
                WatchUi.requestUpdate();
            }
            else if( ( session != null ) && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                WatchUi.requestUpdate();
            }
        }
    	return true;
    }
    
    function onBack() {
    	return mParentView.resetTimer();
    }
}