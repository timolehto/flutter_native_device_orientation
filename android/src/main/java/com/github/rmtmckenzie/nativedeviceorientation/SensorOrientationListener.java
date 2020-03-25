package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.hardware.SensorManager;
import android.view.OrientationEventListener;

public class SensorOrientationListener implements IOrientationListener {

    private final OrientationReader reader;
    private final Context context;
    private final OrientationCallback callback;
    private final boolean calculateOrientation;
    private OrientationEventListener orientationEventListener;
    private OrientationReader.Orientation lastOrientation = null;

    public SensorOrientationListener(OrientationReader orientationReader, Context context, OrientationCallback callback, boolean calculateOrientation) {
        this.reader = orientationReader;
        this.context = context;
        this.callback = callback;
        this.calculateOrientation = calculateOrientation;
    }

    @Override
    public void startOrientationListener() {
        if (orientationEventListener != null) return;

        orientationEventListener = new OrientationEventListener(context, SensorManager.SENSOR_DELAY_NORMAL) {
            @Override
            public void onOrientationChanged(int angle) {
                OrientationReader.Orientation newOrientation = calculateOrientation ?
                    reader.calculateSensorOrientation(angle) :
                    reader.getOrientation();

                if (!newOrientation.equals(lastOrientation)) {
                    lastOrientation = newOrientation;
                    callback.receive(newOrientation);
                }
            }
        };
        if (orientationEventListener.canDetectOrientation()) {
            orientationEventListener.enable();
        }
    }

    @Override
    public void stopOrientationListener() {
        if (orientationEventListener == null) return;
        orientationEventListener.disable();
        orientationEventListener = null;
    }
}
