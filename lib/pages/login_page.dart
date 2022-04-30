import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/google_sign_in_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(100),
              color: Colors.blue.shade900,
            ),
            child: const Icon(
              Icons.bluetooth_connected,
              size: 120,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "BL Project",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 80),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);

                provider.googleLogin();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: const StadiumBorder(),
              ),
              icon: const FaIcon(
                FontAwesomeIcons.google,
                size: 35,
              ),
              label: const Text("Sign in with Google", style: TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}
