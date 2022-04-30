import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/bluetooth_device_list_entry_widget.dart';
import 'stream_page.dart';
import '../providers/blu_state_provider.dart';

class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = false, Key? key}) : super(key: key);

  @override
  _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage>
    with AutomaticKeepAliveClientMixin<SelectBondedDevicePage> {
  @override
  bool get wantKeepAlive => true;

  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>.empty(growable: true);

  Timer? timer;

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        for (var device in bondedDevices) {
          if (!AppConstants.addresses.contains(device.address)) continue;

          devices.add(_DeviceWithAvailability(
            device,
            widget.checkAvailability ? _DeviceAvailability.maybe : _DeviceAvailability.yes,
          ));
        }
      });
    });
  }

  void _restartDiscovery() {
    devices.clear();
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (kDebugMode) {
        print(r.device.name);
      }

      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }

        if (AppConstants.addresses.contains(r.device.address)) {
          devices.add(_DeviceWithAvailability(
            r.device,
            widget.checkAvailability ? _DeviceAvailability.maybe : _DeviceAvailability.yes,
          ));
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });

    timer = Timer(const Duration(seconds: 60), () async {
      await _discoveryStreamSubscription?.cancel();
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  cancelDiscovering() async {
    await _discoveryStreamSubscription?.cancel();
    setState(() {
      timer!.cancel();
      _isDiscovering = false;
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntryWidget> list = devices
        .map((_device) => BluetoothDeviceListEntryWidget(
              device: _device.device,
              rssi: _device.rssi,
              enabled: _device.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => StreamPage(server: _device.device)));
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select device'),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
                  return IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: bluStateProvider.state!.isEnabled ? _restartDiscovery : null,
                  );
                }),
          if (_isDiscovering)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: cancelDiscovering,
            )
        ],
      ),
      body: ListView(children: list),
    );
  }
}
