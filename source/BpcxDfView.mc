import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.UserProfile;

class BpcxDfView extends WatchUi.DataField {

    private var _deviceManager as BpcxDeviceManager;

    // Bosch CX field values
    private var _batteryChargeField as Numeric?;          // battery data
    private var _batteryCurrentField as Float?; 
    private var _batteryPowerField as Float?;
    private var _batteryVoltageField as Float?;
    private var _riderTorqueField as Float?;            // rider data  
    private var _riderCadenceField as Numeric?;
    private var _motorTorqueField as Float?;            // motor data
    private var _motorPowerElField as Float?;
    private var _motorRpmField as Numeric?;
    private var _motorSupportLevelField as Numeric?;
    private var _remainingDistanceField as Numeric?;      // miscellaneous data
    private var _speedField as Float?;
    private var _odometerField as Numeric?;

    // Calculated fields    
    private var _riderPowerField as Numeric?;
    private var _motorPowerField as Numeric?;
    private var _cassetteActualCogField as Numeric?;

    // Activity fields values
    private var _heartrateField as Numeric?; 
    private var _elapsedTimeField as Numeric?; 
    private var _elapsedDistanceField as Numeric?;   
    private var _altitudeField as Float?;  
    private var _totalAscentField as Numeric?;  
    private var _timeField;

    // Fit Contributor
    private var _fitContributor as BpcxFitContributor?;

    // Device signals
    private var _batteryDevice as Numeric;
    private var _gpsSignal as Numeric;
    private var _bleConnected as Boolean;
    private var _temperatureField as Float?;  


    private var _textColor as Numeric;
    private var _supportText = ["", "ECO" , "TOUR+", "eMTB", "TURBO", "", "", "", "", "OFF"];

    private var _supportColor = 
        [Graphics.COLOR_LT_GRAY, Graphics.COLOR_DK_BLUE, Graphics.COLOR_DK_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_DK_RED, 0, 0, 0, Graphics.COLOR_LT_GRAY];
    private var _motorPowerColor = 
        [Graphics.COLOR_LT_GRAY, Graphics.COLOR_DK_BLUE, Graphics.COLOR_DK_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_DK_RED, 0, 0, 0, Graphics.COLOR_LT_GRAY];
    private var _riderPowerColor = 
        [Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_RED, 0, 0, 0, Graphics.COLOR_LT_GRAY];

    private var _highHeartrate as Numeric;
    private var _maxHeartrate as Numeric;
    private var _heartrateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);

    private const _batteryChargeLinSpline = 
        [[0.0,0.0],[10.0,5.0], [20.0,11.0],[30.0,20.0],[40.0,30.0],[50.0,40.0],[60.0,50.0],[70.0,61.0],[80.0,73.0],[90.0,85.0],[100.0,100.0]];
    private const _batteryChargeLinSplineSize = 10;

    private const _cassetteCogsNumber = 12;
    private const _cassetteCogTeeth =
        [52, 42, 36, 32, 28, 24, 21, 18, 16, 14, 12, 10];
    private const _crownTeeth = 34;
    private const _wheelCircumference = 2.2;    // meters

    function initialize(deviceManager as BpcxDeviceManager) {
        DataField.initialize();

        // Bosch CX fields
        
        _batteryChargeField = 0;
        _batteryCurrentField = 0.0;
        _batteryPowerField = 0.0;
        _batteryVoltageField = 0.0;
        _riderTorqueField = 0.0;
        _riderCadenceField = 0;
        _motorTorqueField = 0.0;
        _motorPowerElField = 0.0;
        _motorRpmField = 0;
        _motorSupportLevelField = 0;
        _remainingDistanceField = 0;
        _speedField = 0.0;
        _odometerField = 0;
        /*
        _batteryChargeField = 57;
        _batteryCurrentField = 8.5;
        _batteryPowerField = 350.0;
        _batteryVoltageField = 38.4;
        _riderTorqueField = 34.0;
        _riderCadenceField = 68;
        _motorTorqueField = 33.7;
        _motorPowerElField = 590.0;
        _motorRpmField = 3500;
        _motorSupportLevelField = 1;
        _remainingDistanceField = 64;
        _speedField = 23.5;
        _odometerField = 237;
        */

        // Calculated fields
        _riderPowerField = 0;
        _motorPowerField = 0;
        _cassetteActualCogField = 0;

        // Activity fields
        _heartrateField = 0; 
        _elapsedTimeField = 0;
        _elapsedDistanceField = 0;  
        _timeField = System.getClockTime();  
        _altitudeField = 0.0;
        _totalAscentField = 0;

        // Device signals
        _batteryDevice = 0;
        _gpsSignal = 0;
        _bleConnected = false;
        _temperatureField = 0.0;

        _textColor = 0;
        _highHeartrate = 0;
        _maxHeartrate = _heartrateZones[5];

        _deviceManager = deviceManager;
        _fitContributor = new $.BpcxFitContributor(self);

    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            
            var value = View.findDrawableById("cadence");
            var label = View.findDrawableById("cadence_label");
            var unit = View.findDrawableById("cadence_unit");
            label.locX = value.locX;
            label.locY = value.locY-20;
            unit.locX = value.locX+32;
            unit.locY = value.locY+15;
            value.locX = value.locX+30;

            value = View.findDrawableById("actualcog");
            label = View.findDrawableById("actualcog_label");
            label.locX = value.locX; 
            label.locY = value.locY-20;            

            value = View.findDrawableById("heartrate");
            label = View.findDrawableById("heartrate_label");
            unit = View.findDrawableById("heartrate_unit");
            label.locX = value.locX;
            label.locY = value.locY-20;
            unit.locX = value.locX+16;
            unit.locY = value.locY+15;
            value.locX = value.locX+15;

            value = View.findDrawableById("elapseddistance");
            label = View.findDrawableById("elapseddistance_label");
            unit = View.findDrawableById("elapseddistance_unit");
            label.locX = value.locX;
            label.locY = value.locY-20;
            unit.locX = value.locX+31;
            unit.locY = value.locY+15;
            value.locX = value.locX+30;

            value = View.findDrawableById("altitude");
            label = View.findDrawableById("altitude_label");
            unit = View.findDrawableById("altitude_unit");
            label.locX = value.locX;
            label.locY = value.locY-20;
            unit.locX = value.locX+31;
            unit.locY = value.locY+15;
            value.locX = value.locX+30;

            value = View.findDrawableById("totalascent");
            label = View.findDrawableById("totalascent_label");
            unit = View.findDrawableById("totalascent_unit");
            label.locX = value.locX;
            label.locY = value.locY-20;
            unit.locX = value.locX+31;
            unit.locY = value.locY+15;
            value.locX = value.locX+30;  

            value = View.findDrawableById("time");
            label = View.findDrawableById("time_label");
            label.locX = value.locX; 
            label.locY = value.locY-20;            

            value = View.findDrawableById("elapsedtime");
            label = View.findDrawableById("elapsedtime_label");
            label.locX = value.locX; 
            label.locY = value.locY-20;                    

        }

        (View.findDrawableById("cadence_label") as Text).setText(Rez.Strings.cadence_label);
        (View.findDrawableById("cadence_unit") as Text).setText(Rez.Strings.cadence_unit);
        (View.findDrawableById("actualcog_label") as Text).setText(Rez.Strings.actualcog_label);
        (View.findDrawableById("heartrate_label") as Text).setText(Rez.Strings.heartrate_label);
        (View.findDrawableById("heartrate_unit") as Text).setText(Rez.Strings.heartrate_unit);
        (View.findDrawableById("elapseddistance_label") as Text).setText(Rez.Strings.elapseddistance_label);
        (View.findDrawableById("elapseddistance_unit") as Text).setText(Rez.Strings.elapseddistance_unit);        
        (View.findDrawableById("altitude_label") as Text).setText(Rez.Strings.altitude_label);
        (View.findDrawableById("altitude_unit") as Text).setText(Rez.Strings.altitude_unit);
        (View.findDrawableById("totalascent_label") as Text).setText(Rez.Strings.totalascent_label);
        (View.findDrawableById("totalascent_unit") as Text).setText(Rez.Strings.totalascent_unit);
        (View.findDrawableById("time_label") as Text).setText(Rez.Strings.time_label);
        (View.findDrawableById("elapsedtime_label") as Text).setText(Rez.Strings.elapsedtime_label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        var profile = _deviceManager.getActiveProfile();
        if (_deviceManager.isConnected() && (profile != null)) {
            _batteryChargeField = profile.getBatteryCharge();
            _batteryCurrentField = profile.getBatteryCurrent();
            _batteryPowerField = profile.getBatteryPower();
            _batteryVoltageField = profile.getBatteryVoltage();
            _riderTorqueField = profile.getRiderTorque();
            _riderCadenceField = profile.getRiderCadence();
            _motorTorqueField = profile.getMotorTorque();
            _motorPowerElField = profile.getMotorPower();
            _motorRpmField = profile.getMotorRpm();
            _motorSupportLevelField = profile.getMotorSupportLevel();
            _remainingDistanceField = profile.getRemainingDistance();
            _speedField = profile.getSpeed();
            _odometerField = profile.getOdometer();

            _bleConnected = true;
        } else {
            _bleConnected = false;
        }

        _heartrateField = info.currentHeartRate != null ? info.currentHeartRate : 0; 
        _elapsedTimeField = info.elapsedTime != null ? info.elapsedTime : 0;   
        _elapsedDistanceField = info.elapsedDistance != null ? (info.elapsedDistance/1000.0) : 0;    
        _altitudeField = info.altitude != null ? info.altitude : 0;    
        _totalAscentField = info.totalAscent != null ? info.totalAscent : 0;    
        _timeField = System.getClockTime();
        _temperatureField = getTemperature();

        _riderPowerField = ((_riderCadenceField*_riderTorqueField)/9.5488).toNumber();
        _motorPowerField = ((_riderCadenceField*_motorTorqueField*2.52)/9.5488).toNumber();

        _highHeartrate = _heartrateField>_highHeartrate ? _heartrateField : _highHeartrate;

        _batteryDevice = System.getSystemStats().battery;
        _gpsSignal = info.currentLocationAccuracy != null ? info.currentLocationAccuracy : 0;

        _cassetteActualCogField = computeCasseteCog();

        // Update the activity data
        _fitContributor.update(
            _batteryChargeField, 
            _riderCadenceField, 
            _speedField, 
            _motorSupportLevelField
        );
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        _textColor = getBackgroundColor() == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK; 

        var cadence = View.findDrawableById("cadence") as Text;
        cadence.setColor(_textColor);
        cadence.setText(_bleConnected==true ? _riderCadenceField.toString() : "__");
        var cadence_unit = View.findDrawableById("cadence_unit") as Text;
        cadence_unit.setColor(_textColor);

        var cog = View.findDrawableById("actualcog") as Text;
        cog.setColor(_textColor);
        cog.setText((_cassetteActualCogField>0 ? _cassetteActualCogField.toString() : "__")/*+"/"+_cassetteCogsNumber.toString()*/);

        var heartrate = View.findDrawableById("heartrate") as Text;
        heartrate.setColor(_textColor);
        heartrate.setText(_heartrateField.toString());
        var heartrate_unit = View.findDrawableById("heartrate_unit") as Text;
        heartrate_unit.setColor(_textColor);        

        var elapseddistance = View.findDrawableById("elapseddistance") as Text;
        elapseddistance.setColor(_textColor);
        elapseddistance.setText(_elapsedDistanceField<10.0 ? _elapsedDistanceField.format("%.2f") : _elapsedDistanceField.format("%.1f"));
        var elapseddistance_unit = View.findDrawableById("elapseddistance_unit") as Text;
        elapseddistance_unit.setColor(_textColor);             

        var altitude = View.findDrawableById("altitude") as Text;
        altitude.setColor(_textColor);
        altitude.setText(_altitudeField.format("%.0f"));
        var altitude_unit = View.findDrawableById("altitude_unit") as Text;
        altitude_unit.setColor(_textColor);         

        var totalascent = View.findDrawableById("totalascent") as Text;
        totalascent.setColor(_textColor);
        totalascent.setText(_totalAscentField<100.0 ? _totalAscentField.format("%.1f") : _totalAscentField.format("%.0f"));
        var totalascent_unit = View.findDrawableById("totalascent_unit") as Text;
        totalascent_unit.setColor(_textColor);         

        var time = View.findDrawableById("time") as Text;
        time.setColor(_textColor);
        time.setText(Lang.format("$1$:$2$", [_timeField.hour.format("%.2d"), _timeField.min.format("%.2d")]));

        var elapsedtime = View.findDrawableById("elapsedtime") as Text;
        elapsedtime.setColor(_textColor);
        elapsedtime.setText(Lang.format("$1$:$2$", [((_elapsedTimeField/1000)/3600).format("%.2d"), ((_elapsedTimeField/1000)/60).format("%.2d")]));
    
        var temperature = View.findDrawableById("temperature") as Text;
        temperature.setColor(_textColor);
        temperature.setText(_temperatureField.format("%.1f")+"°");

        var support = View.findDrawableById("support") as Text;
        support.setColor(_supportColor[_motorSupportLevelField]);
        support.setText(_supportText[_motorSupportLevelField].toString());        


        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        // Draw over layout
        drawBattery(dc, 7, 290, _batteryChargeField);
        drawPowerBar(dc, 50, 70, _motorPowerField, _riderPowerField, _motorSupportLevelField);
        drawHRBar(dc, 185, 185, _heartrateField, _highHeartrate);
        drawDeviceBattery(dc, 160, 5, _batteryDevice);
        drawGpsSign(dc, 200, 0, _gpsSignal);
        drawBleSign(dc, 235, 11, _bleConnected);
    }

    //! @author Luca72
    // function for drawing power meter
	public function drawPowerBar(dc, posX, posY, motorpower, riderpower, support) {
        var maxPowerRect = 387.0;           // 1000W max power rider+motor, 613W arc, 387W rect
        var maxGraphicUnitsRect = 70;       // 230arc, 70rect
        var ratioRect = maxGraphicUnitsRect / maxPowerRect;
        var motorPowerRect = motorpower<maxPowerRect ? motorpower : maxPowerRect;
        var riderPowerRect = (motorpower+riderpower)<maxPowerRect ? riderpower : (motorpower<maxPowerRect ? maxPowerRect-motorpower : 0);
        var motorFillRectW = (motorPowerRect.toFloat()*ratioRect).toNumber();
        var riderFillRectW = (riderPowerRect.toFloat()*ratioRect).toNumber();

        var maxPowerArc = 613.0;            // 1000W max power rider+motor, 613W arc, 387W rect
        var maxGraphicUnitsArc = 230;       // 230arc, 70rect
        var ratioArc = maxGraphicUnitsArc / maxPowerArc;
        var motorPowerArc = motorpower>maxPowerRect ? ((motorpower-maxPowerRect)<maxPowerArc ? motorpower-maxPowerRect : maxPowerArc) : 0;
        var riderPowerArc = (motorpower+riderpower)>maxPowerRect ? ((riderpower+motorPowerArc)<maxPowerArc ? riderpower-riderPowerRect : maxPowerArc-motorPowerArc) : 0;
        var motorFillArcW = (motorPowerArc.toFloat()*ratioArc).toNumber();
        var riderFillArcW = (riderPowerArc.toFloat()*ratioArc).toNumber();
        

		dc.setPenWidth(10);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(posX, posY+36, maxGraphicUnitsRect, 10);
		dc.drawArc(posX, posY, 40, Graphics.ARC_CLOCKWISE, 270, 40);

        dc.setColor(_motorPowerColor[support], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(posX+(maxGraphicUnitsRect-motorFillRectW), posY+36, motorFillRectW, 10);
		if (motorFillArcW>0) { 
            dc.drawArc(posX, posY, 40, Graphics.ARC_CLOCKWISE, 270, 270-motorFillArcW);
        }

        dc.setColor(_riderPowerColor[support], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(posX+(maxGraphicUnitsRect-(motorFillRectW+riderFillRectW)), posY+36, riderFillRectW, 10);
        if (riderFillArcW>0) { 
		    dc.drawArc(posX, posY, 40, Graphics.ARC_CLOCKWISE, 270-motorFillArcW, (270-motorFillArcW)-riderFillArcW);
        }
    }

    //! @author Luca72
    // function for drawing heart rate meter
	public function drawHRBar(dc, posX, posY, heartrate, highheartrate) {  
        var minHrArc = 60;
        var maxHrArc = _maxHeartrate;
        var maxGraphicUnitsArc = 40;
        var ratioArc = maxGraphicUnitsArc.toFloat() / (maxHrArc-minHrArc).toFloat();
        var hrFillArcW = ((heartrate-minHrArc).toFloat()*ratioArc).toNumber();
        var hrHighArcW = ((highheartrate-minHrArc).toFloat()*ratioArc).toNumber();
        
        dc.setPenWidth(10);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(posX, posY, 155, Graphics.ARC_CLOCKWISE, 110, 70);

        if((hrFillArcW>0) and (hrFillArcW<maxGraphicUnitsArc)) {
            if(heartrate<_heartrateZones[0]) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            } else if(heartrate<_heartrateZones[1]) {
                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
            } else if(heartrate<_heartrateZones[2]) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else if(heartrate<_heartrateZones[3]) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            } else if(heartrate<_heartrateZones[4]) {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawArc(posX, posY, 155, Graphics.ARC_CLOCKWISE, 110, 110-hrFillArcW);
        }

        if((hrHighArcW>0) and (hrHighArcW<maxGraphicUnitsArc)) {
            dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(posX, posY, 155, Graphics.ARC_CLOCKWISE, 110-hrHighArcW, 110-hrHighArcW-1);
        }
    }

    //! @author Luca72
    // function for drawing battery shape
	public function drawBattery(dc, posX, posY, charge) {
        var chargeLin = linearizeValue(charge, _batteryChargeLinSpline, _batteryChargeLinSplineSize);
        var ratio = (dc.getWidth()-(posX*2)).toFloat() / 100.0;
        var capX = dc.getWidth()-(posX+10);
        var filledW = (chargeLin.toFloat()*ratio).toNumber();
        var maxFilledBodyW = (dc.getWidth()-(posX*2))-10;
        var filledBodyW = filledW < maxFilledBodyW ? filledW : maxFilledBodyW;
        var maxFilledCapW = 10;
        var filledCapW = filledW-maxFilledBodyW;

        
        if(chargeLin > 20) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else if(chargeLin > 5) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(posX, posY, filledBodyW, 30);
        dc.fillRectangle(capX, posY+5, filledCapW, 20);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(posX+filledBodyW, posY, maxFilledBodyW-filledBodyW, 30);
        dc.fillRectangle(capX+filledCapW, posY+5, maxFilledCapW-filledCapW, 20);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var chargeStr = chargeLin.toString() + "%";
        dc.drawText(dc.getWidth()/2, posY+15, Graphics.FONT_LARGE, chargeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    //! @author Luca72
    // function for drawing Garmin device battery level
    public function drawDeviceBattery(dc, posX, posY, battery) {    
        var width = 25;
        var height = 15;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(posX, posY, width, height);
        dc.fillRectangle(posX + width - 1, posY + 3, 4, height - 6);
        
        if (battery < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(posX+3 + width / 2, posY + 6, Graphics.FONT_XTINY, format("$1$%", [battery.format("%d")]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
        if (battery < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (battery < 30) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(posX + 1, posY + 1, (width-2) * battery / 100, height - 2);
    }
    
    //! @author Luca72
    // function for drawing GPS sign
    function drawGpsSign(dc, posX, posY, gpssignal) {
        if (gpssignal > 1) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(posX, posY + 12, 6, 8);

        if (gpssignal > 2) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(posX + 7, posY + 8, 6, 12);

        if (gpssignal > 3) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }        
        dc.fillRectangle(posX + 14, posY + 4, 6, 16);   
    } 

    //! @author Luca72
    // function for drawing BLE sign
    function drawBleSign(dc, posX, posY, connected) {
        if (connected == true) {
            dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);                
        }
        //dc.fillCircle(posX, posY, 6);

        dc.setPenWidth(2);

        dc.drawLine(posX, posY-7, posX, posY+7);
        dc.drawLine(posX, posY-7, posX+5, posY-4);
        dc.drawLine(posX, posY+7, posX+5, posY+4);
        dc.drawLine(posX+5, posY-4, posX-5, posY+3);
        dc.drawLine(posX+5, posY+4, posX-5, posY-3);
    }

    function getIterator() {
        //! Check device for SensorHistory compatibility
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
            return Toybox.SensorHistory.getTemperatureHistory({});
        }
        return null;
    }

    // function for getting last saved temperature
    public function getTemperature() as Float {
        var sensorIter = getIterator();
        var fieldValue = (sensorIter != null) ? sensorIter.next().data : 0;

        return fieldValue;
    }

    //! @author Luca72
    // function for computing used cassette cog
    public function computeCasseteCog() as Numeric {
        var cog = _cassetteActualCogField;
        if (_riderCadenceField > 50){
            var wheelRPM = ((_speedField*16.67)/_wheelCircumference );
            if (wheelRPM > 0) {
                var calculatedCog = ((_crownTeeth.toFloat()*_riderCadenceField.toFloat())/ wheelRPM);

                var cogcurr = _cassetteCogTeeth[0];
                var cogdiff = (calculatedCog-cogcurr).abs();
                if (cogdiff<(_cassetteCogTeeth[0]*0.1)) {
                    cog = 1;
                }
                for (var i = 0; i < _cassetteCogsNumber; i++) {
                    var newcogdiff = (calculatedCog - _cassetteCogTeeth[i]).abs();
                    if (newcogdiff < cogdiff) {
                        cogdiff = newcogdiff;
                        cogcurr = _cassetteCogTeeth[i];
                        if (cogdiff<(_cassetteCogTeeth[i]*0.1)) {
                            cog = i+1;
                        }
                    }
                }
            }
        }
        return cog;
    }

    //! Linearize battery value
    (:typecheck(false))
    public function linearizeValue(value, spline, size) as Numeric {
        var linValue = 0.0;
        var i;
        for (i = 0; i < size-1; i++) {
            if((spline[i][0] <= value) and (spline[i+1][0] > value)) {
                break;
            }
        }
        linValue = spline[i][1] + ( ((value-spline[i][0])/(spline[i+1][0]-spline[i][0]))*(spline[i+1][1]-spline[i][1]) );
        return linValue.toNumber();
    }


    //! Handle the activity timer starting
    public function onTimerStart() as Void {
        _fitContributor.setTimerRunning(true);
    }

    //! Handle the activity timer stopping
    public function onTimerStop() as Void {
        _fitContributor.setTimerRunning(false);
    }

    //! Handle an activity timer pause
    public function onTimerPause() as Void {
        _fitContributor.setTimerRunning(false);
    }

    //! Handle the activity timer resuming
    public function onTimerResume() as Void {
        _fitContributor.setTimerRunning(true);
    }    
}

