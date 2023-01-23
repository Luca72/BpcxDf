import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class BpcxDfView extends WatchUi.DataField {

    // Fit Contributor
    private var _fitContributor as BpcxFitContributor?;
    private var _deviceManager as BpcxDeviceManager;

    function initialize(bleDelegate as BpcxDelegate, deviceManager as BpcxDeviceManager) {
        DataField.initialize();
        _deviceManager = deviceManager;
        _fitContributor = new $.BpcxFitContributor(self);
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        var profileModel = _deviceManager.getProfileModel();
        if(profileModel != null) {
            // See Activity.Info in the documentation for available information.
            /*
            if(info has :currentHeartRate){
                if(info.currentHeartRate != null){
                    mValue = info.currentHeartRate as Number;
                } else {
                    mValue = 0.0f;
                }
            }
            */

            // Update the activity data
            
            _fitContributor.update(
                94, 
                profileModel.getCadence(), 
                23.0, 
                2
            );
            
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText("23.0");

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }


    //! Handle the activity timer starting
    public function onTimerStart() as Void {
        _fitContributor.setTimerRunning(true);
    }

    //! Handle the activity timer stopping
    public function onTimerStop() as Void {
        _fitContributor.setTimerRunning(false);
    }

    //! Handle an activity timer pause
    public function onTimerPause() as Void {
        _fitContributor.setTimerRunning(false);
    }

    //! Handle the activity timer resuming
    public function onTimerResume() as Void {
        _fitContributor.setTimerRunning(true);
    }    
}
