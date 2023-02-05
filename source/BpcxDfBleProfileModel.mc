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

        _batteryCharge = 0;
        _batteryCurrent = 0.0;
        _batteryPower = 0.0;
        _batteryVoltage = 0.0;
        _riderTorque = 0.0;
        _riderCadence = 0;
        _motorTorque = 0.0;
        _motorPower = 0.0;
        _motorRpm = 0;
        _motorSupportLevel = 0;
        _remainingDistance = 0;
        _speed = 0.0;
        _odometer = 0;

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

    //! Get the battery charge
    //! @return The battery charge value
    public function getBatteryCharge() as Numeric? {
        return _batteryCharge;
    }   

    //! Get the battery current
    //! @return The battery current value
    public function getBatteryCurrent() as Numeric? {
        return _batteryCurrent;
    }   

    //! Get the battery power
    //! @return The battery power value
    public function getBatteryPower() as Numeric? {
        return _batteryPower;
    }   

    //! Get the battery voltage
    //! @return The battery voltage value
    public function getBatteryVoltage() as Numeric? {
        return _batteryVoltage;
    }   

    //! Get the rider torque
    //! @return The rider torque value
    public function getRiderTorque() as Numeric? {
        return _riderTorque;
    }   

    //! Get the rider cadence
    //! @return The rider cadence value
    public function getRiderCadence() as Numeric? {
        return _riderCadence;
    }   

    //! Get the motor torque
    //! @return The motor torque value
    public function getMotorTorque() as Numeric? {
        return _motorTorque;
    }   

    //! Get the motor power
    //! @return The motor power value
    public function getMotorPower() as Numeric? {
        return _motorPower;
    }   

    //! Get the motor rpm
    //! @return The motor rpm value
    public function getMotorRpm() as Numeric? {
        return _motorRpm;
    }   

    //! Get the motor support level
    //! @return The motor support level value
    public function getMotorSupportLevel() as Numeric? {
        return _motorSupportLevel;
    }   

    //! Get the remaining distance
    //! @return The remaining distance value
    public function getRemainingDistance() as Numeric? {
        return _remainingDistance;
    }   

    //! Get the speed
    //! @return The speed value
    public function getSpeed() as Numeric? {
        return _speed;
    }   

    //! Get the odometer
    //! @return The odometer value
    public function getOdometer() as Numeric? {
        return _odometer;
    }   

    //! Get the odometer
    //! @return The ble signal intensity
    public function getBleSignal() as Numeric? {
        return _odometer;
    }   


    //! Process and set the rider values
    //! @param value new rider values
    private function processRiderValues(value as ByteArray) as Void {
        _riderTorque = ((value[1] << 8) | value[0]).toFloat()/10.0;         // torque
        _riderCadence = ((value[3] << 8) | value[2]).toNumber();            // cadence
        WatchUi.requestUpdate();
    }

    //! Process and set the battery values
    //! @param value new battery values
    private function processBatteryValues(value as ByteArray) as Void {
        _batteryCharge = ((value[3] << 8) | value[2]).toNumber();           // charge
        _batteryCurrent = ((value[5] << 8) | value[4]).toFloat()/1000.0;    // current
        _batteryPower = ((value[7] << 8) | value[6]).toFloat()/10.0;        // power
        _batteryVoltage = ((value[9] << 8) | value[8]).toFloat()/1000.0;    // voltage  
        WatchUi.requestUpdate();
    }

    //! Process and set the motor values
    //! @param value new motor values
    private function processMotorValues(value as ByteArray) as Void {
        _motorTorque = ((value[1] << 8) | value[0]).toFloat()/10.0;         // torque
        _motorPower = ((value[3] << 8) | value[2]).toFloat()/10.0;          // power
        _motorRpm = ((value[5] << 8) | value[4]).toNumber();                // rpm
        _motorSupportLevel = ((value[7] << 8) | value[6]).toNumber();       // support level
        WatchUi.requestUpdate();
    }

    //! Process and set the distance values
    //! @param value new distance values
    private function processDistanceValues(value as ByteArray) as Void {
        _remainingDistance = ((value[1] << 8) | value[0]).toNumber();       // rpm
        _speed = ((value[3] << 8) | value[2]).toFloat()/10.0;               // speed
        _odometer = ((value[5] << 8) | value[4]).toNumber();                // rpm
        WatchUi.requestUpdate();
    }    

}
