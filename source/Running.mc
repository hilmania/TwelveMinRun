using Toybox.WatchUi;


class Running extends WatchUi.View {

	function initialize() {
		View.initialize();
	    Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
	    Sensor.enableSensorEvents( method(:onSnsr) );
	     
	    string_HR = "---bpm";
	    string_distance = "--m";
	
	}
	
	function onShow(){
	}
	
	function onHide(){
	}

}