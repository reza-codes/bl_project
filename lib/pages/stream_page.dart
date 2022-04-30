import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import '../constants/app_constants.dart';
import '../models/fall_detect_model.dart';
import '../providers/blu_state_provider.dart';
import '../repositories/firestore_repository.dart';
import '../widgets/map_widget.dart';

class StreamPage extends StatefulWidget {
  final BluetoothDevice server;

  const StreamPage({required this.server, Key? key}) : super(key: key);

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> with WidgetsBindingObserver {
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  Stream<Uint8List>? get connectionStream => connection?.input;

  StreamController<Uint8List>? controller = StreamController<Uint8List>.broadcast();

  Stream<Uint8List>? stream;

  bool isDisconnecting = false;
  bool allowSendDataOnResume = false;

  String? recivedData;
  int counter = 0;

  DateTime now = DateTime.now();
  late String formattedDate;

  LatLng? _latLng;
  Location location = Location();
  late LocationData _currentPosition;

  // Twilio serivice
  TwilioFlutter? twilioFlutter;

  initStream() async {
    stream = controller?.stream;

    try {
      BluetoothConnection _connection = await BluetoothConnection.toAddress(widget.server.address);
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      controller?.addStream(connectionStream!);
    } catch (e, s) {
      if (kDebugMode) {
        print('Cannot connect, exception occured');
      }
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }
    }
  }

  Future<void> getLoc() async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      location.enableBackgroundMode(enable: true);
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        if (kDebugMode) {
          print("service not enabled!");
        }
        _serviceEnabled = await location.requestService();
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        if (kDebugMode) {
          print("Permission denied!");
        }
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          if (kDebugMode) {
            print("Permission not granted!");
          }
          return;
        }
      }

      _currentPosition = await location.getLocation();
      _latLng = LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    initStream();

    formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);

    twilioFlutter = TwilioFlutter(
      accountSid: AppConstants.accountSid,
      authToken: AppConstants.authToken,
      twilioNumber: AppConstants.twilioNumber,
    );

    stream?.listen((event) {
      recivedData = ascii.decode(event);
      if (recivedData == null) {
        if (kDebugMode) {
          print("No Fall Detected");
        }
      } else {
        if (kDebugMode) {
          print(recivedData);
        }

        if (recivedData?.trim() == 'Fall Detected') {
          sendDataToFirebase();
        }
      }
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    WidgetsBinding.instance?.removeObserver(this);
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.paused == state) {
      stream?.last.then((value) async {
        recivedData = ascii.decode(value);
        if (recivedData == null) {
          if (kDebugMode) {
            print("No Fall Detected");
          }
        } else {
          if (kDebugMode) {
            print(recivedData);
          }
          if (recivedData?.trim() == 'Fall Detected') {
            sendDataToFirebase();
          }
        }
      });
    }

    if (kDebugMode) {
      print(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverName = widget.server.name ?? "Unknown";
    return Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
      if (!bluStateProvider.state!.isEnabled) Navigator.pop(context);
      return Scaffold(
        appBar: AppBar(
            elevation: 0.3,
            title: (isConnecting
                ? Row(
                    children: [
                      Text('Connecting to ' + serverName + ' ...'),
                      const Icon(Icons.bluetooth_searching, color: Colors.orange)
                    ],
                  )
                : isConnected
                    ? Row(
                        children: [
                          Text('Connected to ' + serverName + ' '),
                          const Icon(Icons.bluetooth_connected, color: Colors.greenAccent)
                        ],
                      )
                    : Text('Chat log with ' + serverName))),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              height: 400,
              child: const MapWidget(),
            ),
            const SizedBox(height: 15),
            recivedData == null
                ? const Text(
                    "No Fall Detected",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.green),
                  )
                : Text(
                    "$counter ${recivedData.toString().trim()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.red),
                  ),
            const SizedBox(height: 15),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateBuilder) {
                return StreamBuilder(
                  stream: currnetTime(setStateBuilder),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(snapshot.data);
                    }
                    return Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Stream<DateTime> currnetTime(StateSetter setStateBuilder) async* {
    await Future.delayed(const Duration(seconds: 1));
    now = DateTime.now();
    yield now;
    setStateBuilder(() {});
  }

  Future<void> sendDataToFirebase() async {
    try {
      await getLoc();

      double? lat = _latLng?.latitude;
      double? lon = _latLng?.longitude;

      String url = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";

      bool allowSendSMS = Provider.of<BluStateProvider>(context, listen: false).pushSMS;

      if (allowSendSMS) {
        for (var element in FirestoreRepository.erContactList) {
          if (kDebugMode) {
            print(element.phoneNumber);
          }
          await twilioFlutter?.sendSMS(
            toNumber: '+1${element.phoneNumber}',
            messageBody: '''Fall detected!
Location:
$url
      ''',
          );
        }
      }

      if (kDebugMode) {
        print("Current location: $_latLng");
      }
      if (kDebugMode) {
        print("Currnet Data and Time : $now");
      }

      FallDetectModel fallDetectModel = FallDetectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        longitude: lon!,
        latitude: lat!,
        dataTime: now,
      );

      FirestoreRepository.fallDetectList.add(fallDetectModel);
      FirestoreRepository.addFallDectected();

      setState(() {
        counter++;
      });
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }
    }
  }
}
