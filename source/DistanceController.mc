class DistanceController {

	var R = 6371000; // Meters
	var d2r = (Math.PI / 180.0);
	var lap = 0;
	var lapDistance = 400; // default 
	var flag = 0;
	var distanceMeasure = 0; // yang ditampilkan di view
	var distanceReal = 0; // by activity position info
	var excess = 0;
	var initialLocation = null;
	var init2CurrentLoc = null; // Jarak = gunakan fungsi dist untuk menghitung dari initial location terhadap current location
	var thresholdDistanceLong = 75; // jarak minimal untuk suspect adanya lap
	var thresholdDistanceShort = 5; // jarak maximal lap dianggap valid

	function dist(lat1, lon1, lat2, lon2) {
		var x = deg2rad((lon2 - lon1)) * Math.cos(deg2rad( (lat1 + lat2) / 2));
		var y = deg2rad(lat2 - lat1);
		var distance = Math.sqrt(x * x + y * y) * R;
		return distance.format("%d");
    }
    
	function deg2rad(deg) {
	  return deg * d2r;
	}
	
	function countDistanceMeasure() {
		//if flag 0
		distanceMeasure = lap * lapDistance  + distanceReal - (lap*lapDistance) - excess;
		
		//if init2CurrenLoc <= thresholdDistanceShort && flag == 1
		distanceMeasure = lap * lapDistance;
		excess = distanceReal - distanceMeasure;
	}

}