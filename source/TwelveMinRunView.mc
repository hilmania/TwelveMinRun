using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Timer;
using Toybox.Background;
using Toybox.Sensor;
using Toybox.Activity;
using Toybox.ActivityRecording;

const TIMER_DURATION_KEY = 0;
const TIMER_START_TIME_KEY = 1;
const TIMER_PAUSE_TIME_KEY = 2;

const TIMER_DURATION_DEFAULT = (12 * 60);    // 12 minutes

class TwelveMinRunView extends WatchUi.View {

    var mMessage = "Press menu button";
    var string_HR;
    var string_distance;
    var string_timer;
    var activity_info;
    var mTimerDuration;
    var mTimerStartTime;
    var mTimerPauseTime;
    var mUpdateTimer;
    

    function initialize(backgroundRan) {
    	View.initialize();
    	Sensor.setEnabledSensors ( [Sensor.SENSOR_HEARTRATE] );
    	Sensor.enableSensorEvents( method(:onSnsr) );
    	string_HR = "0";
    	
    	if(backgroundRan == null) {
    		mTimerDuration = objectStoreGet(TIMER_DURATION_KEY, TIMER_DURATION_DEFAULT);
    		mTimerStartTime = objectStoreGet(TIMER_START_TIME_KEY, null);
    		mTimerPauseTime = objectStoreGet(TIMER_PAUSE_TIME_KEY, null);
    	} else {
    		mTimerDuration = TIMER_DURATION_DEFAULT;
    		mTimerStartTime = null;
    		mTimerPauseTime = null;
    	}
    	
    	mUpdateTimer = new Timer.Timer();
    	
    	if((mTimerStartTime != null) && (mTimerPauseTime == null)) {
    		mUpdateTimer.start(method(:requestUpdate), 1000, true);
    	}
   
    }
    
    function stopRecording() {
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                WatchUi.requestUpdate();
            }
        }
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mMessage = "Watch ID : " + AppConstants.WATCH_ID + "\nPress menu to start"; 
    }

    function onUpdate(dc) {
//        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
//        dc.clear();
        // Draw selected box
//        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
//        dc.fillRectangle(0, 0 * dc.getHeight() / 3, dc.getWidth(), dc.getHeight() / 3);
//        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
//        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, string_timer, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);                
//        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);        
//    	dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, string_distance, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);        
//    	dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2) + 55, Graphics.FONT_LARGE, string_HR, Graphics.TEXT_JUSTIFY_CENTER);
    	var timerString;
    	var timerValue;
    	var elapsed;
    	var minutes;
    	var seconds;
    	var textColor = Graphics.COLOR_WHITE;
    	var distance;
    	
    	elapsed = 0;
    	if(mTimerStartTime != null) {
    		if(mTimerPauseTime != null) {
    			textColor = Graphics.COLOR_YELLOW;
    			elapsed = mTimerPauseTime - mTimerStartTime;
    		} else {
    			elapsed = Time.now().value() - mTimerStartTime;
    		}
    		
    		if(elapsed >= mTimerDuration ){
    			elapsed = mTimerDuration;
    			textColor = Graphics.COLOR_RED;
    			mTimerPauseTime = Time.now().value();
    			mUpdateTimer.stop();
    		}
    	}
    	
    	timerValue = mTimerDuration - elapsed;

        seconds = timerValue % 60;
        minutes = timerValue / 60;

        timerString = minutes + ":" + seconds.format("%02d");
        
        activity_info = Activity.getActivityInfo();
        string_distance = activity_info.elapsedDistance;
        if (string_distance == null) {
        	string_distance = 0;
        }
		distance = string_distance.format("%d");
		
        dc.setColor(textColor, Graphics.COLOR_BLACK);
        dc.clear();
        
        
        dc.drawText(
            dc.getWidth()/2,
            (dc.getHeight()/2) - 75,
            Graphics.FONT_SYSTEM_NUMBER_HOT,
            timerString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
        	dc.getWidth()/2,
            (dc.getHeight()/2) - 10,
            Graphics.FONT_SYSTEM_NUMBER_HOT,
            distance,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            dc.getWidth()/2 + 80,
            (dc.getHeight()/2) - 10,
            Graphics.FONT_LARGE,
            "m",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
        	dc.getWidth()/2,
            (dc.getHeight()/2) + 50,
            Graphics.FONT_SYSTEM_NUMBER_HOT,
            string_HR,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            dc.getWidth()/2 + 80,
            (dc.getHeight()/2) + 50,
            Graphics.FONT_LARGE,
            "bpm",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
    
    function startStopTimer() {
        var now = Time.now().value();

        if(mTimerStartTime == null) {
            mTimerStartTime = now;
            mUpdateTimer.start(method(:requestUpdate), 1000, true);
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
            
        } else {
            if(mTimerPauseTime == null) {
                mTimerPauseTime = now;
                mUpdateTimer.stop();
                Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
                stopRecording();
                Sensor.unregisterSensorDataListener();               
                WatchUi.requestUpdate();
            } else if( mTimerPauseTime - mTimerStartTime < mTimerDuration ) {
                mTimerStartTime += (now - mTimerPauseTime);
                mTimerPauseTime = null;
                mUpdateTimer.start(method(:requestUpdate), 1000, true);
            } else {
            	resetTimer();
            }
        }
    }
    
    function resetTimer() {
        if(mTimerPauseTime != null) {
            mTimerStartTime = null;
            mTimerPauseTime = null;
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
    
    function saveProperties() {
        objectStorePut(TIMER_DURATION_KEY, mTimerDuration);
        objectStorePut(TIMER_START_TIME_KEY, mTimerStartTime);
        objectStorePut(TIMER_PAUSE_TIME_KEY, mTimerPauseTime);
    }
    
    function setBackgroundEvent() {
        if((mTimerStartTime != null) && (mTimerPauseTime == null)) {
            var time = new Time.Moment(mTimerStartTime);
            time = time.add(new Time.Duration(mTimerDuration));
            try {
                var info = Time.Gregorian.info(time, Time.FORMAT_SHORT);
                Background.registerForTemporalEvent(time);
            } catch (e instanceof Background.InvalidBackgroundTimeException) {
    		
            }
        }
    }
    
    function deleteBackgroundEvent() {
        Background.deleteTemporalEvent();
    }

    function backgroundEvent(data) {
        mTimerDuration = TIMER_DURATION_DEFAULT;
        mTimerStartTime = null;
        mTimerPauseTime = null;
        WatchUi.requestUpdate();
    }

    function requestUpdate() {
        WatchUi.requestUpdate();
    }
    
    function onSnsr(sensor_info)
    {
        var HR = sensor_info.heartRate;
        var bucket;
        if( sensor_info.heartRate != null ) {
            string_HR = HR.toString();
        }
        else {
            string_HR = "000";
        }

        WatchUi.requestUpdate();
    }
    
    function onDistance(info) {
    	var Distance = info;
    	
    	WatchUi.requestUpdate();
    }
    
     function onPosition(info) {
    	var mInitialLocation = info.position.toDegrees();
   		objectStorePut(3, mInitialLocation[0]);
   		objectStorePut(4, mInitialLocation[1]);
    }
    
    function onReceive(args) {
        if (args instanceof Lang.String) {
            mMessage = args;
        }
        else if (args instanceof Dictionary) {
            var keys = args.keys();
            mMessage = "";
            for( var i = 0; i < keys.size(); i++ ) {
                mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            }
        }
        WatchUi.requestUpdate();
    }    

}
