import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;


class BpcxFitContributor {
	
	// Field ids
    private const BPCX_BATTERY = 0;
    private const BPCX_CADENCE = 1;
    private const BPCX_SPEED = 2;
    private const BPCX_ASSISTANCE_LEVEL = 3;

    private var _timerRunning = false;

    // FIT Contributions variables
    private var _batteryField;
    private var _cadenceField;
    private var _speedField;
    private var _assistanceLevelField;

	//! Constructor
    //! @param dataField Data field to use to create fields
    public function initialize(bpcxField as BpcxDfView) {
    	System.println("Initialize Fit Contributor");

    	// Create the custom FIT data field we want to record
        _batteryField = bpcxField.createField(
            WatchUi.loadResource(Rez.Strings.BatteryField),
            BPCX_BATTERY,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>WatchUi.loadResource(Rez.Strings.BatteryUnitField)}
        );

        _cadenceField = bpcxField.createField(
            WatchUi.loadResource(Rez.Strings.CadenceField),
            BPCX_CADENCE,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>WatchUi.loadResource(Rez.Strings.CadenceUnitField)}
        );

        _speedField = bpcxField.createField(
            WatchUi.loadResource(Rez.Strings.SpeedField),
            BPCX_SPEED,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>WatchUi.loadResource(Rez.Strings.SpeedUnitField)}
        );        

        _assistanceLevelField = bpcxField.createField(
            WatchUi.loadResource(Rez.Strings.AssistanceLevelField),
            BPCX_ASSISTANCE_LEVEL,
            FitContributor.DATA_TYPE_UINT8,
            {:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>WatchUi.loadResource(Rez.Strings.AssistanceLevelUnitField)}
        );

        _batteryField.setData(0);
        _cadenceField.setData(0);
        _speedField.setData(0);
        _assistanceLevelField.setData(0);
    }

    //! Update data and fields
    //! @param battery level, cadence, speed and assistance value
    public function update(battery, cadence, speed, assistance) as Void {
    	//System.println("Updating fit...");

        if (_timerRunning) {
        	// Update fields
        	_batteryField.setData(battery);
        	_cadenceField.setData(cadence);
            _speedField.setData(speed);
        	_assistanceLevelField.setData(assistance);
        }
    }

    //! Set whether the timer is running
    //! @param state Whether the timer is running
    public function setTimerRunning(state) as Void {
        _timerRunning = state;
    }
}