import Toybox.BluetoothLowEnergy;
import Toybox.Lang;

class BpcxDelegate extends BluetoothLowEnergy.BleDelegate {
    private var _profileManager as BpcxProfileManager;

    private var _onScanResult as WeakReference?;
    private var _onConnection as WeakReference?;
    private var _onDescriptorWrite as WeakReference?;
    private var _onCharacteristicChanged as WeakReference?;    

    //! Constructor
    //! @param BpcxProfileManager The profile manager
    public function initialize(profileManager as BpcxProfileManager) {
        BleDelegate.initialize();
        _profileManager = profileManager;
    }

    //! Store a new model to handle descriptor writes
    //! @param model The model for descriptors
    public function notifyDescriptorWrite(model as BpcxProfileModel) as Void {
        _onDescriptorWrite = model.weak();
    }

    //! Store a new model to handle characteristic changes
    //! @param model The model for characteristics
    public function notifyCharacteristicChanged(model as BpcxProfileModel) as Void {
        _onCharacteristicChanged = model.weak();
    }    

    //! Handle new Scan Results being received
    //! @param scanResults An iterator of new scan result objects
    public function onScanResults(scanResults as Iterator) as Void {
        for (var result = scanResults.next(); result != null; result = scanResults.next()) {
            if (result instanceof ScanResult) {
                if (contains(result.getServiceUuids(), _profileManager.BPCX_SERVICE)) {
                    broadcastScanResult(result);
                }
            }
        }
    }

    //! Handle pairing and connecting to a device
    //! @param device The device state that was changed
    //! @param state The state of the connection
    public function onConnectedStateChanged(device as Device, state as ConnectionState) as Void {
        var onConnection = _onConnection;
        if (onConnection != null) {
            if (onConnection.stillAlive()) {
                (onConnection.get() as BpcxDeviceManager).procConnection(device);
            }
        }
    }

    //! Handle the completion of a write operation on a descriptor
    //! @param descriptor The descriptor that was written
    //! @param status The BluetoothLowEnergy status indicating the result of the operation
    public function onDescriptorWrite(descriptor as Descriptor, status as Status) as Void {
        var onDescriptorWrite = _onDescriptorWrite;
        if (null != onDescriptorWrite) {
            if (onDescriptorWrite.stillAlive()) {
                (onDescriptorWrite.get() as BpcxProfileModel).onDescriptorWrite(descriptor, status);
            }
        }
    }

    //! Handle a characteristic being changed
    //! @param char The characteristic that changed
    //! @param value The updated value of the characteristic
    public function onCharacteristicChanged(characteristic, value) {
        var onCharacteristicChanged = _onCharacteristicChanged;
        if (null != onCharacteristicChanged) {
            if (onCharacteristicChanged.stillAlive()) {
                (onCharacteristicChanged.get() as BpcxProfileModel).onCharacteristicChanged(characteristic, value);
            }
        }                               
    } 	  

    //! Store a new manager to manage scan results
    //! @param manager The manager of the scan results
    public function notifyScanResult(manager as BpcxDeviceManager) as Void {
        _onScanResult = manager.weak();
    }

    //! Store a new manager to manage device connections
    //! @param manager The manager for devices
    public function notifyConnection(manager as BpcxDeviceManager) as Void {
        _onConnection = manager.weak();
    }

    //! Broadcast a new scan result
    //! @param scanResult The new scan result
    private function broadcastScanResult(scanResult as ScanResult) as Void {
        var onScanResult = _onScanResult;
        if (onScanResult != null) {
            if (onScanResult.stillAlive()) {
                (onScanResult.get() as BpcxDeviceManager).procScanResult(scanResult);
            }
        }
    }

    //! Get whether the iterator contains a specific uuid
    //! @param iter Iterator of uuid objects
    //! @param obj Uuid to search for
    //! @return true if object found, false otherwise
    private function contains(iter as Iterator, obj as Uuid) as Boolean {
        for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
        	//add next line
        	System.println("found="+uuid.toString());
            if (uuid.equals(obj)) {
                return true;
            }
        }

        return false;
    }

}
