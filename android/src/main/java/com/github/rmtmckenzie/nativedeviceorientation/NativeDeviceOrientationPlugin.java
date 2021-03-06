package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.util.Log;

import java.util.Map;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NativeDeviceOrientationPlugin
 */
public class NativeDeviceOrientationPlugin implements MethodCallHandler, EventChannel.StreamHandler {

    private static final String METHOD_CHANEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientation";
    private static final String EVENT_CHANNEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), METHOD_CHANEL);
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL);
        final NativeDeviceOrientationPlugin instance = new NativeDeviceOrientationPlugin(registrar.activeContext());

        methodChannel.setMethodCallHandler(instance);
        eventChannel.setStreamHandler(instance);
    }

    private NativeDeviceOrientationPlugin(Context context) {
        this.context = context;
        this.reader = new OrientationReader(context);
    }

    private final Context context;
    private final OrientationReader reader;

    private IOrientationListener listener;

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        switch (call.method) {
            case "getOrientation":
                Boolean useSensor = call.argument("useSensor");

                if(useSensor != null && useSensor){
                    // we can't immediately retrieve a orientation from the sensor. We have to start listening
                    // and return the first orientation retrieved.
                    reader.getSensorOrientation(new IOrientationListener.OrientationCallback(){

                        @Override
                        public void receive(OrientationReader.Orientation orientation) {
                            result.success(orientation.name());
                        }
                    });
                }else{
                    result.success(reader.getOrientation().name());
                }
                break;

            case "pause":
                pause();
                result.success(null);
                break;

            case "resume":
                resume();
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }


    private void pause(){
        // if a listener is currently active, stop listening. The app is going to the background
        if(listener != null){
            listener.stopOrientationListener();
        }
    }

    private void resume(){
        // start listening for orientation changes again. The app is in the foreground.
        if(listener != null){
            listener.startOrientationListener();
        }
    }

    @Override
    public void onListen(Object parameters, final EventChannel.EventSink eventSink) {
        boolean useSensor = false;
        boolean calculateOrientation = true;
        // used hashMap to send parameters to this method. This makes it easier in the future to add new parameters if needed.
        if(parameters instanceof Map){
            Map params = (Map) parameters;

            if(params.containsKey("useSensor")){
                Boolean useSensorNullable = (Boolean) params.get("useSensor");
                useSensor = useSensorNullable != null && useSensorNullable;
            }
            if(params.containsKey("calculateOrientation")) {
                Boolean calculateOrientationNullable = (Boolean) params.get("calculateOrientation");
                if(calculateOrientationNullable != null) {
                    calculateOrientation = calculateOrientationNullable;
                }
            }
        }

        // initialize the callback. It is the same for both listeners.
        IOrientationListener.OrientationCallback callback = new IOrientationListener.OrientationCallback() {
            @Override
            public void receive(OrientationReader.Orientation orientation) {
                eventSink.success(orientation.name());
            }
        };

        if(useSensor){
            Log.i("NDOP", "listening using sensor listener");
            listener = new SensorOrientationListener(reader, context, callback, calculateOrientation);
        }else{
            Log.i("NDOP", "listening using window listener");
            listener = new OrientationListener(reader, context, callback);
        }
        listener.startOrientationListener();
    }

    @Override
    public void onCancel(Object o) {
        listener.stopOrientationListener();
        listener = null;
    }
}
