import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

enum SensorSetting {
  no_sensor,
  sensor_with_calc,
  sensor_with_ui
}

class _MyAppState extends State<MyApp> {
  SensorSetting sensorSetting = SensorSetting.no_sensor;
  List<DeviceOrientation> orientations = List();

  toggleOrientation(DeviceOrientation orientation) {
    setState(() {
      if (!orientations.remove(orientation)) {
        orientations.add(orientation);
      }
      SystemChrome.setPreferredOrientations(orientations);
    });
  }

  sensorSettingChanged(SensorSetting newSetting) {
    setState(() {
      sensorSetting = newSetting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Native Orientation example app'),
            actions: <Widget>[
                  SizedBox(width: 200, child: ListTile(
                    title: const Text('No sensor'),
                    leading: Radio(
                      value: SensorSetting.no_sensor,
                      groupValue: sensorSetting,
                      onChanged: sensorSettingChanged,
                    ),
                  )),
                  SizedBox(width: 200, child: ListTile(
                    title: const Text('Calcualte with sensor'),
                    leading: Radio(
                      value: SensorSetting.sensor_with_calc,
                      groupValue: sensorSetting,
                      onChanged: sensorSettingChanged,
                    ),
                  )),
                  SizedBox(width: 200, child: ListTile(
                    title: const Text('UI orientation with sensor'),
                    leading: Radio(
                      value: SensorSetting.sensor_with_ui,
                      groupValue: sensorSetting,
                      onChanged: sensorSettingChanged,
                    ),
                  )),
            ],
          ),
          body: Stack(
            children: <Widget>[
              NativeDeviceOrientationReader(
                builder: (context) {
                  NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(context);
                  print("Received new orientation: $orientation");
                  return Center(child: Text('Native Orientation: $orientation\n'));
                },
                useSensor: sensorSetting == SensorSetting.sensor_with_ui || sensorSetting == SensorSetting.sensor_with_calc,
                calculateOrientation: sensorSetting != SensorSetting.sensor_with_ui
              ),
              Container(
                alignment: Alignment.topRight,
                child: Container(
                  width: 220,
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: <Widget>[
                      const Text("Set preferred orientations", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),),
                      SwitchListTile(
                        title: const Text('Landscape left'),
                        value: orientations.contains(DeviceOrientation.landscapeLeft),
                        onChanged: (_) { toggleOrientation(DeviceOrientation.landscapeLeft); },
                      ),
                      SwitchListTile(
                        title: const Text('Landscape right'),
                        value: orientations.contains(DeviceOrientation.landscapeRight),
                        onChanged: (_) { toggleOrientation(DeviceOrientation.landscapeRight); },
                      ),
                      SwitchListTile(
                        title: const Text('Portrait up'),
                        value: orientations.contains(DeviceOrientation.portraitUp),
                        onChanged: (_) { toggleOrientation(DeviceOrientation.portraitUp); },
                      ),
                      SwitchListTile(
                        title: const Text('Portrait down'),
                        value: orientations.contains(DeviceOrientation.portraitDown),
                        onChanged: (_) { toggleOrientation(DeviceOrientation.portraitDown); },
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    child: Text("Sensor"),
                    onPressed: () async {
                      NativeDeviceOrientation orientation =
                      await NativeDeviceOrientationCommunicator().orientation(useSensor: true);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Native Orientation read: $orientation"),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    child: Text("UI"),
                    onPressed: () async {
                      NativeDeviceOrientation orientation =
                          await NativeDeviceOrientationCommunicator().orientation(useSensor: false);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Native Orientation read: $orientation"),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          )),
    );
  }
}
