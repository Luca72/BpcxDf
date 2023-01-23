import Toybox.BluetoothLowEnergy;
import Toybox.System;

class BpcxProfileManager {
    
    public const BPCX_SERVICE                   = BluetoothLowEnergy.longToUuid(0xD6970001904511EDL, 0xA1EB0242AC120002L);
    public const BPCX_RIDER_CHARACTERISTICS     = BluetoothLowEnergy.longToUuid(0xD6970010904511EDL, 0xA1EB0242AC120002L);
    public const BPCX_BATTERY_CHARACTERISTICS   = BluetoothLowEnergy.longToUuid(0xD6970011904511EDL, 0xA1EB0242AC120002L);
    public const BPCX_MOTOR_CHARACTERISTICS     = BluetoothLowEnergy.longToUuid(0xD6970012904511EDL, 0xA1EB0242AC120002L);
    public const BPCX_DISTANCE_CHARACTERISTICS  = BluetoothLowEnergy.longToUuid(0xD6970013904511EDL, 0xA1EB0242AC120002L);
    public const BPCX_SENSOR_LOCATION           = BluetoothLowEnergy.longToUuid(0xD6970002904511EDL, 0xA1EB0242AC120002L);

    private const _bpcxProfileDef = {
        :uuid => BPCX_SERVICE,
        :characteristics => [{
            :uuid => BPCX_RIDER_CHARACTERISTICS,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, {
            :uuid => BPCX_BATTERY_CHARACTERISTICS,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, {
            :uuid => BPCX_MOTOR_CHARACTERISTICS,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, {
            :uuid => BPCX_DISTANCE_CHARACTERISTICS,
            :descriptors => [BluetoothLowEnergy.cccdUuid()]
        }, {
            :uuid => BPCX_SENSOR_LOCATION
        }]
    };

    //! Register the bluetooth profile
    public function registerProfiles() as Void {
		try {      
        	BluetoothLowEnergy.registerProfile(_bpcxProfileDef);
		} catch(exception) {
			System.println("exception="+exception.getErrorMessage());
		}
    }    
}
