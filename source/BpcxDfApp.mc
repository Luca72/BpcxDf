import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.BluetoothLowEnergy;

class BpcxDfApp extends Application.AppBase {

    private var _profileManager as BpcxProfileManager?;
    private var _bleDelegate as BpcxDelegate?;
    private var _deviceManager as BpcxDeviceManager?;  
    private var _dataFactory as BpcxDataModelFactory?;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        _profileManager = new $.BpcxProfileManager();
        _bleDelegate = new $.BpcxDelegate(_profileManager as BpcxProfileManager);
        _dataFactory = new $.BpcxDataModelFactory(_bleDelegate as BpcxDelegate, _profileManager as BpcxProfileManager);
        _deviceManager = new $.BpcxDeviceManager(_bleDelegate as BpcxDelegate, _profileManager as BpcxProfileManager, _dataFactory as BpcxDataModelFactory);

        BluetoothLowEnergy.setDelegate(_bleDelegate as BpcxDelegate);
        (_profileManager as BpcxProfileManager).registerProfiles();
        (_deviceManager as BpcxDeviceManager).start();            
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        _deviceManager = null;
        _bleDelegate = null;
        _profileManager = null;    
    }

    //! Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new BpcxDfView(_deviceManager as BpcxDeviceManager) ] as Array<Views or InputDelegates>;
    }
}

function getApp() as BpcxDfApp {
    return Application.getApp() as BpcxDfApp;
}