import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../widgets/bluetooth_device_list_entry_widget.dart';
import '../providers/blu_state_provider.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  _DiscoveryPage createState() => _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> with AutomaticKeepAliveClientMixin<DiscoveryPage> {
  @override
  bool get wantKeepAlive => true;

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  bool bonded = false;
  bool? isBlueEnabled;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void _startDiscovery() async {
    isBlueEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    if (isBlueEnabled ?? false) {
      setState(() {
        results.clear();
        isDiscovering = true;
      });
      _streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        setState(() {
          final existingIndex = results.indexWhere((element) => element.device.address == r.device.address);
          if (existingIndex >= 0) {
            results[existingIndex] = r;
          } else {
            results.add(r);
          }
        });
      });

      _streamSubscription!.onDone(() {
        setState(() {
          isDiscovering = false;
        });
      });
    }

    timer = Timer(const Duration(seconds: 60), () async {
      await _streamSubscription?.cancel();
      setState(() {
        isDiscovering = false;
      });
    });
  }

  cancelDiscovering() async {
    await _streamSubscription?.cancel();
    setState(() {
      timer!.cancel();
      isDiscovering = false;
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDiscovering ? const Text('Discovering devices') : const Text('Discovered devices'),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
                  return IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: bluStateProvider.state!.isEnabled ? _startDiscovery : null,
                  );
                }),
          if (isDiscovering)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: cancelDiscovering,
            )
        ],
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, index) {
          BluetoothDiscoveryResult result = results[index];
          final device = result.device;
          final address = device.address;
          return BluetoothDeviceListEntryWidget(
            device: device,
            rssi: result.rssi,
            onTap: () async {
              // Navigator.of(context).pop(result.device);

              if (!device.isBonded) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Device status'),
                      content: FutureBuilder(
                          future: FlutterBluetoothSerial.instance.bondDeviceAtAddress(address),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              bonded = snapshot.data as bool;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.'),
                                  bonded
                                      ? const Icon(Icons.check_circle_outline, color: Colors.green, size: 50)
                                      : const Icon(Icons.close, color: Colors.red, size: 50)
                                ],
                              );
                            }

                            return const Center(
                              heightFactor: 1.0,
                              child: CircularProgressIndicator(),
                            );
                          }),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                if (kDebugMode) {
                  print('Bonding with ${device.address}...');
                }

                setState(() {
                  results[results.indexOf(result)] = BluetoothDiscoveryResult(
                      device: BluetoothDevice(
                        name: device.name ?? '',
                        address: address,
                        type: device.type,
                        bondState: bonded ? BluetoothBondState.bonded : BluetoothBondState.none,
                      ),
                      rssi: result.rssi);
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Device status'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Deivece already bounded'),
                          SizedBox(height: 15),
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            onLongPress: () async {
              try {
                if (device.isBonded) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Device status'),
                        content: FutureBuilder(
                            future: FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(address),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                bonded = snapshot.data as bool;
                                if (bonded) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Unbonding from ${device.address} has succed'),
                                      const Icon(Icons.bluetooth_disabled_rounded,
                                          color: Colors.yellow, size: 50)
                                    ],
                                  );
                                }
                              }

                              return const Center(child: CircularProgressIndicator());
                            }),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (kDebugMode) {
                    print('Unbonding from ${device.address}...');
                  }
                  // await FlutterBluetoothSerial.instance.removeDeviceBondWithAddress(address);
                  if (kDebugMode) {
                    print('Unbonding from ${device.address} has succed');
                  }
                }
                setState(() {
                  results[results.indexOf(result)] = BluetoothDiscoveryResult(
                      device: BluetoothDevice(
                        name: device.name ?? '',
                        address: address,
                        type: device.type,
                        bondState: bonded ? BluetoothBondState.bonded : BluetoothBondState.none,
                      ),
                      rssi: result.rssi);
                });
              } catch (ex) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error occured while bonding'),
                      content: Text(ex.toString()),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
