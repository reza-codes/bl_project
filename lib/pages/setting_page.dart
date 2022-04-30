import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../providers/blu_state_provider.dart';
import '../providers/google_sign_in_provider.dart';
import '../repositories/firestore_repository.dart';

class SettingPage extends StatelessWidget {
  final blutooth = FlutterBluetoothSerial.instance;

  SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Setting'),
      ),
      body: ListView(
        children: <Widget>[
          Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Enable Bluetooth'),
                  value: bluStateProvider.state!.isEnabled,
                  onChanged: (bool value) async {
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Push SMS Messages'),
                  value: bluStateProvider.pushSMS,
                  onChanged: (bool value) async {
                    bluStateProvider.enableSMS(value);
                    FirestoreRepository.readErContactsOnce();
                  },
                ),
              ],
            );
          }),
          ListTile(
            title: const Text('Bluetooth status'),
            subtitle: Consumer<BluStateProvider>(builder: (context, bluStateProvider, _) {
              return Text(bluStateProvider.state.toString());
            }),
            trailing: ElevatedButton(
              child: const Text('Settings'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('Local adapter address'),
            subtitle: FutureBuilder(
                future: blutooth.address,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return const Text("");
                }),
          ),
          ListTile(
            title: const Text('Local adapter name'),
            subtitle: FutureBuilder(
                future: blutooth.name,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.toString());
                  }
                  return const Text("");
                }),
            onLongPress: null,
          ),
          const Divider(),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);

                await provider.logOut();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: const StadiumBorder(),
                primary: Colors.red.shade400,
              ),
              icon: const Icon(
                Icons.logout_rounded,
                size: 35,
              ),
              label: const Text("Log Out", style: TextStyle(fontSize: 22)),
            ),
          )
        ],
      ),
    );
  }
}
