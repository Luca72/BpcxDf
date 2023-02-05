import Toybox.Application;
import Toybox.Graphics;
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
    }

}

class DeviceBattery extends WatchUi.Drawable {

    hidden var _backgroundColor as ColorValue;

    function initialize() {
        var dictionary = {
            :identifier => "DeviceBattery"
        };

        Drawable.initialize(dictionary);

        _backgroundColor = Graphics.COLOR_WHITE;
    }

    function setColor(color as ColorValue) as Void {
        _backgroundColor = color;
    }

    function draw(dc as Dc) as Void {
        /*
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
        */
    }

}



