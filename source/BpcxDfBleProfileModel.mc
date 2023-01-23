import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class BpcxProfileModel {
    private var _service as Service?;
    private var _profileManager as BpcxProfileManager;
    private var _pendingNotifies as Array<Characteristic>;

    // Field values
    private var _batteryCharge as Numeric?;          // battery data
    private var _batteryCurrent as Numeric?; 
    private var _batteryPower as Numeric?;
    private var _batteryVoltage as Numeric?;
    private var _riderTorque as Numeric?;            // rider data  
    private var _riderCadence as Numeric?;
    private var _motorTorque as Numeric?;            // motor data
    private var _motorPower as Numeric?;
    private var _motorRpm as Numeric?;
    private var _motorSupportLevel as Numeric?;
    private var _remainingDistance as Numeric?;      // miscellaneous data
    private var _speed as Numeric?;
    private var _odometer as Numeric?;    


    //! Constructor
    //! @param delegate The BLE delegate for the model
    //! @param profileManager The profile manager for this model
    //! @param device The current device
    public function initialize(delegate as BpcxDelegate, profileManager as BpcxProfileManager, device as Device) {
        delegate.notifyDescriptorWrite(self);
        delegate.notifyCharacteristicChanged(self);

        _profileManager = profileManager;
        _service = device.getService(profileManager.BPCX_SERVICE);

        _pendingNotifies = [] as Array<Characteristic>;

        var service = _service;
        if (service != null) {
            var characteristic = service.getCharacteristic(profileManager.BPCX_RIDER_CHARACTERISTICS);
            if (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }

            characteristic = service.getCharacteristic(profileManager.BPCX_BATTERY_CHARACTERISTICS);
            if (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }

            characteristic = service.getCharacteristic(profileManager.BPCX_MOTOR_CHARACTERISTICS);
            if (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            }
            
            characteristic = service.getCharacteristic(profileManager.BPCX_DISTANCE_CHARACTERISTICS);
            if (null != characteristic) {
                _pendingNotifies = _pendingNotifies.add(characteristic);
            } 
        }

        activateNextNotification();
    }

    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param value The updated value of the characteristic
    public function onCharacteristicChanged(characteristic as Characteristic, value as ByteArray) as Void {
        switch (characteristic.getUuid()) {
            case _profileManager.BPCX_RIDER_CHARACTERISTICS:
                processRiderValues(value);
                break;

            case _profileManager.BPCX_BATTERY_CHARACTERISTICS:
                processBatteryValues(value);
                break;

            case _profileManager.BPCX_MOTOR_CHARACTERISTICS:
                processMotorValues(value);
                break;

            case _profileManager.BPCX_DISTANCE_CHARACTERISTICS:
                processDistanceValues(value);
                break;
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void {
        if (BluetoothLowEnergy.cccdUuid().equals(descriptor.getUuid())) {
            processCccdWrite();
        }
    }

    //! Write the next notification to the descriptor
    private function activateNextNotification() as Void {
        if (_pendingNotifies.size() == 0) {
            return;
        }

        var characteristic = _pendingNotifies[0];
        var cccd = characteristic.getDescriptor(BluetoothLowEnergy.cccdUuid());
        if (cccd != null) {
            System.println("Req.Write="+characteristic.getUuid().toString());
            System.println("Array Size="+_pendingNotifies.size().toString());
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    //! Process a CCCD write operation
    private function processCccdWrite() as Void {
        if (_pendingNotifies.size() > 1) {
            _pendingNotifies = _pendingNotifies.slice(1, _pendingNotifies.size());
            activateNextNotification();
        } else {
            _pendingNotifies = [] as Array<Characteristic>;
        }

    }

    //! Get the cadence
    //! @return The cadence value
    public function getCadence() as Numeric? {
        return _riderCadence;
    }    

    //! Process and set the rider values
    //! @param value new rider values
    private function processRiderValues(value as ByteArray) as Void {
        System.println("Rider");
        _riderTorque = ((value[1] << 8) | value[0]).toFloat()/10.0;         // torque
        _riderCadence = ((value[3] << 8) | value[2]).toNumber();            // cadence
        WatchUi.requestUpdate();
    }

    //! Process and set the battery values
    //! @param value new battery values
    private function processBatteryValues(value as ByteArray) as Void {
        System.println("Battery");
        _batteryCharge = ((value[3] << 8) | value[2]).toNumber();           // charge
        _batteryCurrent = ((value[5] << 8) | value[4]).toFloat()/1000.0;    // current
        _batteryPower = ((value[7] << 8) | value[6]).toFloat()/10.0;        // power
        _batteryVoltage = ((value[9] << 8) | value[8]).toFloat()/1000.0;    // voltage  
        WatchUi.requestUpdate();
    }

    //! Process and set the motor values
    //! @param value new motor values
    private function processMotorValues(value as ByteArray) as Void {
        System.println("Motor");
        _motorTorque = ((value[1] << 8) | value[0]).toFloat()/10.0;         // torque
        _motorPower = ((value[3] << 8) | value[2]).toFloat()/10.0;          // power
        _motorRpm = ((value[5] << 8) | value[4]).toNumber();                // rpm
        _motorSupportLevel = ((value[7] << 8) | value[6]).toNumber();       // support level
        WatchUi.requestUpdate();
    }

    //! Process and set the distance values
    //! @param value new distance values
    private function processDistanceValues(value as ByteArray) as Void {
        System.println("Distance");
        _remainingDistance = ((value[1] << 8) | value[0]).toNumber();       // rpm
        _speed = ((value[3] << 8) | value[2]).toFloat()/10.0;               // speed
        _odometer = ((value[5] << 8) | value[4]).toNumber();                // rpm
        WatchUi.requestUpdate();
    }    

}
