import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool useSensor = false;
  List<DeviceOrientation> orientations = List();

  toggleOrientation(DeviceOrientation orientation) {
    setState(() {
      if (!orientations.remove(orientation)) {
        orientations.add(orientation);
      }
      SystemChrome.setPreferredOrientations(orientations);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Native Orientation example app'),
            actions: <Widget>[
              SizedBox(width: 220, child: SwitchListTile(
                title: const Text('Use sensors'),
                value: useSensor,
                onChanged: (val) => setState(() => useSensor = val),
                secondary: const Icon(Icons.settings_input_antenna),
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
                useSensor: useSensor,
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
