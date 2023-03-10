import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.System;
import Toybox.Attention;

class BpcxDeviceManager {
    private var _profileManager as BpcxProfileManager;
    private var _delegate as BpcxDelegate;
    private var _profileModel as BpcxProfileModel?;
    private var _device as Device?;
    
    //! Constructor
    //! @param bleDelegate The BLE delegate
    //! @param profileManager The profile manager
    public function initialize(bleDelegate as BpcxDelegate, profileManager as BpcxProfileManager) {
        _device = null;

        bleDelegate.notifyScanResult(self);
        bleDelegate.notifyConnection(self);

        _profileManager = profileManager;
        _delegate = bleDelegate;
    }

    //! Start BLE scanning
    public function start() as Void {
        BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
    }

    //! Process scan result
    //! @param scanResult The scan result
    public function procScanResult(scanResult as ScanResult) as Void {
        // Pair the first device we see with good RSSI
        if (scanResult.getRssi() > -50) {
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
            BluetoothLowEnergy.pairDevice(scanResult);
            System.println("Paired");
            if (Attention has :playTone) {
                Attention.playTone(Attention.TONE_SUCCESS);
            }
        }
    }

    //! Process a new device connection
    //! @param device The device that was connected
    public function procConnection(device as Device) as Void {
        if (device.isConnected()) {
            _device = device;
            procDeviceConnected();
            WatchUi.requestUpdate();
        } else {
            BluetoothLowEnergy.unpairDevice(_device);
            System.println("Unpaired");
            BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
            _device = null;   
            if (Attention has :playTone) {
                Attention.playTone(Attention.TONE_FAILURE);
            }                     
        }
    }

    //! Update the profile after a is device connected
    private function procDeviceConnected() as Void {
        if (_device != null) {
            if (_profileModel == null) {
                _profileModel = new $.BpcxProfileModel(_delegate, _profileManager, _device);
            } else {
                _profileModel.startNotifications();
            }      
        }
    }

    //! Get the active profile
    //! @return The current profile, or null if no device connected
    public function getActiveProfile() as BpcxProfileModel? {
        if (_device != null) {
            if (!_device.isConnected()) {
                return null;
            }
        }
        return _profileModel;
    }

    //! Get whether a device is connected
    //! @return true if connected, false otherwise
    public function isConnected() as Boolean {
        if (_device != null) {
            return _device.isConnected();
        }
        return false;
    }

}
