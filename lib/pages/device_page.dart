import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import 'discovery_page.dart';
import 'select_bonded_device_page.dart';
import 'setting_page.dart';
import '../providers/blu_state_provider.dart';

// import './helpers/LineChart.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<DevicesPage> {
  @override
  bool get wantKeepAlive => true;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  late TabController controller;

  Timer? _discoverableTimeoutTimer;

  @override
  void initState() {
    super.initState();

    controller = TabController(
      length: 2,
      vsync: this,
    );

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      Provider.of<BluStateProvider>(context, listen: false).updateState(_bluetoothState);
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        Provider.of<BluStateProvider>(context, listen: false).updateState(_bluetoothState);
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;

      Provider.of<BluStateProvider>(context, listen: false).updateState(_bluetoothState);
      _discoverableTimeoutTimer = null;
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Bl project'),
          elevation: 0.6,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Paired device'),
              Tab(text: 'Add device'),
            ],
            controller: controller,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: Column(
          children: [
            Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
              if (!bluStateProvider.state!.isEnabled) {
                return SwitchListTile(
                  title: const Text('Enable Bluetooth'),
                  value: bluStateProvider.state!.isEnabled,
                  onChanged: (bool value) async {
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            }),
            Expanded(
              child: TabBarView(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  SelectBondedDevicePage(),
                  DiscoveryPage(),
                ],
              ),
            ),
          ],
        ));
  }
}
