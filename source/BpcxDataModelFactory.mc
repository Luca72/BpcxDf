import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.WatchUi;

class BpcxDataModelFactory {
    // Dependencies
    private var _delegate as BpcxDelegate;
    private var _profileManager as BpcxProfileManager;
    private var _device as Device?;    

    // Model Storage
    private var _profileModel as WeakReference?;

    //! Constructor
    //! @param delegate The BLE delegate to use for the models
    //! @param profileManager The profile manager to use for a profile model
    public function initialize(delegate as BpcxDelegate, profileManager as BpcxProfileManager) {
        _device = null;        
        _delegate = delegate;
        _profileManager = profileManager;
    }

    //! Get the profile model instance
    //! @param device The device to use for a new model
    //! @return The current environment profile model or a new one
    public function getProfileModel(device as Device) as BpcxProfileModel {
        var profileModel = _profileModel;
        if (profileModel != null) {
            if (profileModel.stillAlive()) {
                return (profileModel.get() as BpcxProfileModel);
            }
        }

        var dataModel = new $.BpcxProfileModel(_delegate, _profileManager, device);
        _profileModel = dataModel.weak();

        return dataModel;
    }
}
