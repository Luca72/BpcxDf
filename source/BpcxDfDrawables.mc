import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    hidden var _color as ColorValue;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        _color = Graphics.COLOR_WHITE;
    }

    function setColor(color as ColorValue) as Void {
        _color = color;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_TRANSPARENT, _color);
        dc.clear();
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(dc.getWidth()/2, 24, dc.getWidth(), 24);
        dc.drawLine(dc.getWidth()/2, 102, dc.getWidth(), 102);
        dc.drawLine(0, 122, dc.getWidth()/2, 122);
        dc.drawLine(0, 177, dc.getWidth(), 177);
        dc.drawLine(0, 232, dc.getWidth(), 232);
        dc.drawLine(0, 287, dc.getWidth(), 287);
        dc.drawLine(dc.getWidth()/2, 0, dc.getWidth()/2, 287);
    }

}

class DeviceBattery extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _charge as Numeric;

    function initialize(params as Dictionary) {
        params[:identifier] = "DeviceBattery";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _charge = 0;
    }

    function setChargeLevel(charge as Numeric) as Void {
        _charge = charge;
    }

    function draw(dc as Dc) as Void {
        var width = 25;
        var height = 15;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_x, _y, width, height);
        dc.fillRectangle(_x + width - 1, _y + 3, 4, height - 6);
        
        if (_charge < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_x+3 + width / 2, _y + 6, Graphics.FONT_XTINY, format("$1$%", [_charge.format("%d")]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
        if (_charge < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (_charge < 30) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(_x + 1, _y + 1, (width-2) * _charge / 100, height - 2);
    }

}

class GpsSign extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _gpssignal as Numeric;

    function initialize(params as Dictionary) {
        params[:identifier] = "GpsSign";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _gpssignal = 0;
    }

    function setSignalLevel(gpssignal as Numeric) as Void {
        _gpssignal = gpssignal;
    }

    function draw(dc as Dc) as Void {
        if (_gpssignal > 1) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(_x, _y+8, 6, 8);

        if (_gpssignal > 2) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(_x+7, _y+4, 6, 12);

        if (_gpssignal > 3) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }        
        dc.fillRectangle(_x+14, _y, 6, 16);   
    }

}


class BikeBattery extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _charge as Numeric;

    function initialize(params as Dictionary) {
        params[:identifier] = "BikeBattery";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _charge = 0;
    }

    function setChargeLevel(charge as Numeric) as Void {
        _charge = charge;
    }

    function draw(dc as Dc) as Void {
        var ratio = (dc.getWidth()-(_x*2)).toFloat() / 100.0;
        var capX = dc.getWidth()-(_x+10);
        var filledW = (_charge.toFloat()*ratio).toNumber();
        var maxFilledBodyW = (dc.getWidth()-(_x*2))-10;
        var filledBodyW = filledW < maxFilledBodyW ? filledW : maxFilledBodyW;
        var maxFilledCapW = 10;
        var filledCapW = filledW-maxFilledBodyW;

        
        if(_charge > 20) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else if(_charge > 5) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(_x, _y, filledBodyW, 30);
        dc.fillRectangle(capX, _y+5, filledCapW, 20);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_x+filledBodyW, _y, maxFilledBodyW-filledBodyW, 30);
        dc.fillRectangle(capX+filledCapW, _y+5, maxFilledCapW-filledCapW, 20);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var chargeStr = _charge.toString() + "%";
        dc.drawText(dc.getWidth()/2, _y+15, Graphics.FONT_LARGE, chargeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}

class PowerBar extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _motorpower as Numeric;
    hidden var _riderpower as Numeric;
    hidden var _support as Numeric;

    private var _motorPowerColor = 
        [Graphics.COLOR_LT_GRAY, Graphics.COLOR_DK_BLUE, Graphics.COLOR_DK_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_DK_RED, 0, 0, 0, Graphics.COLOR_LT_GRAY];
    private var _riderPowerColor = 
        [Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_RED, 0, 0, 0, Graphics.COLOR_LT_GRAY];    

    function initialize(params as Dictionary) {
        params[:identifier] = "PowerBar";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _motorpower = 0;
        _riderpower = 0;
        _support = 0;
    }

    function setPowerLevel(motorpower as Numeric, riderpower as Numeric, support as Numeric) as Void {
        _motorpower = motorpower;
        _riderpower = riderpower;
        _support = support;
    }

    function draw(dc as Dc) as Void {
        var maxPowerRect = 387.0;           // 1000W max power rider+motor, 613W arc, 387W rect
        var maxGraphicUnitsRect = 70;       // 230arc, 70rect
        var ratioRect = maxGraphicUnitsRect / maxPowerRect;
        var motorPowerRect = _motorpower<maxPowerRect ? _motorpower : maxPowerRect;
        var riderPowerRect = (_motorpower+_riderpower)<maxPowerRect ? _riderpower : (_motorpower<maxPowerRect ? maxPowerRect-_motorpower : 0);
        var motorFillRectW = (motorPowerRect.toFloat()*ratioRect).toNumber();
        var riderFillRectW = (riderPowerRect.toFloat()*ratioRect).toNumber();

        var maxPowerArc = 613.0;            // 1000W max power rider+motor, 613W arc, 387W rect
        var maxGraphicUnitsArc = 230;       // 230arc, 70rect
        var ratioArc = maxGraphicUnitsArc / maxPowerArc;
        var motorPowerArc = _motorpower>maxPowerRect ? ((_motorpower-maxPowerRect)<maxPowerArc ? _motorpower-maxPowerRect : maxPowerArc) : 0;
        var riderPowerArc = (_motorpower+_riderpower)>maxPowerRect ? ((_riderpower+motorPowerArc)<maxPowerArc ? _riderpower-riderPowerRect : maxPowerArc-motorPowerArc) : 0;
        var motorFillArcW = (motorPowerArc.toFloat()*ratioArc).toNumber();
        var riderFillArcW = (riderPowerArc.toFloat()*ratioArc).toNumber();
        

		dc.setPenWidth(10);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_x, _y+36, maxGraphicUnitsRect, 10);
		dc.drawArc(_x, _y, 40, Graphics.ARC_CLOCKWISE, 270, 40);

        dc.setColor(_motorPowerColor[_support], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_x+(maxGraphicUnitsRect-motorFillRectW), _y+36, motorFillRectW, 10);
		if (motorFillArcW>0) { 
            dc.drawArc(_x, _y, 40, Graphics.ARC_CLOCKWISE, 270, 270-motorFillArcW);
        }

        dc.setColor(_riderPowerColor[_support], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_x+(maxGraphicUnitsRect-(motorFillRectW+riderFillRectW)), _y+36, riderFillRectW, 10);
        if (riderFillArcW>0) { 
		    dc.drawArc(_x, _y, 40, Graphics.ARC_CLOCKWISE, 270-motorFillArcW, (270-motorFillArcW)-riderFillArcW);
        }
    }

}

class BleSign extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _connected as Boolean;

    function initialize(params as Dictionary) {
        params[:identifier] = "BleSign";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _connected = false;
    }

    function setConnected(connected as Boolean) as Void {
        _connected = connected;
    }

    function draw(dc as Dc) as Void {
        if (_connected == true) {
            dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);                
        }
        dc.fillEllipse(_x, _y, 6, 8);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        dc.drawLine(_x, _y-6, _x, _y+6);
        dc.drawLine(_x, _y-6, _x+4, _y-3);
        dc.drawLine(_x, _y+6, _x+4, _y+3);
        dc.drawLine(_x+4, _y-3, _x-5, _y+3);
        dc.drawLine(_x+4, _y+3, _x-5, _y-3);
    }

}

class HeartrateBar extends WatchUi.Drawable {

    private var _x, _y;
    private var _heartrate as Numeric;
    private var _highHeartrate as Numeric;
    private var _heartrateZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
    private var _maxHeartrate as Numeric;

    function initialize(params as Dictionary) {
        params[:identifier] = "HeartrateBar";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _heartrate = 0;
        _highHeartrate = 0;
        _maxHeartrate = _heartrateZones[5];;
    }


    function setHeartrate(heartrate as Numeric) as Void {
        _heartrate = heartrate;
        _highHeartrate = _heartrate>_highHeartrate ? _heartrate : _highHeartrate;        
    }    

    function draw(dc as Dc) as Void {
        var minHrArc = 60;
        var maxHrArc = _maxHeartrate;
        var maxGraphicUnitsArc = 40;
        var ratioArc = maxGraphicUnitsArc.toFloat() / (maxHrArc-minHrArc).toFloat();
        var hrFillArcW = ((_heartrate-minHrArc).toFloat()*ratioArc).toNumber();
        var hrHighArcW = ((_highHeartrate-minHrArc).toFloat()*ratioArc).toNumber();
        
        dc.setPenWidth(10);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_x, _y, 155, Graphics.ARC_CLOCKWISE, 110, 70);

        if((hrFillArcW>0) and (hrFillArcW<maxGraphicUnitsArc)) {
            if(_heartrate<_heartrateZones[0]) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            } else if(_heartrate<_heartrateZones[1]) {
                dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
            } else if(_heartrate<_heartrateZones[2]) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else if(_heartrate<_heartrateZones[3]) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            } else if(_heartrate<_heartrateZones[4]) {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawArc(_x, _y, 155, Graphics.ARC_CLOCKWISE, 110, 110-hrFillArcW);
        }

        if((hrHighArcW>0) and (hrHighArcW<maxGraphicUnitsArc)) {
            dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(_x, _y, 155, Graphics.ARC_CLOCKWISE, 110-hrHighArcW, 110-hrHighArcW-1);
        }
    }

}


class CassetteCog extends WatchUi.Drawable {

    private var _x, _y;
    hidden var _cog as Numeric;
    hidden var _cognum as Numeric;


    function initialize(params as Dictionary) {
        params[:identifier] = "CassetteCog";
        Drawable.initialize(params);

        _x = params.get(:x);
        _y = params.get(:y);
        _cog = 0;
        _cognum = 0;
    }

    function setCog(cog as Numeric, cognum as Numeric) as Void {
        _cog = cog;
        _cognum = (cognum>0 ? cognum : 10);
    }

    function draw(dc as Dc) as Void {
        var fieldWidth = 110;
        var cogWidth = 0;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        cogWidth = fieldWidth/_cognum;
        for(var i=0; i<_cognum; i++) {
            dc.drawRectangle(_x+(cogWidth*i), _y, cogWidth-2, 18-i);
            if ((i+1) == _cog){
                dc.fillRectangle(_x+(cogWidth*i), _y, cogWidth-2, 18-i);
            }
        }
    }

}