using Toybox.Background;
using Toybox.System;

(:background)
class BackgroundTimerServiceDelegate extends System.ServiceDelegate {
	
	function initialize() {
		ServiceDelegate.initialize();
	}
	
	function onTemporalEvent() {
		Background.requestApplicationWake("Your timer has expired!");
		Background.exit(true);
	}

}