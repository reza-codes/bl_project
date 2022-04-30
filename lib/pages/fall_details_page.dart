import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/map_widget.dart';

class FallDetailsPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final DateTime? dataTime;

  const FallDetailsPage({
    required this.latitude,
    required this.longitude,
    required this.dataTime,
    Key? key,
  }) : super(key: key);

  @override
  State<FallDetailsPage> createState() => _FallDetailsPageState();
}

class _FallDetailsPageState extends State<FallDetailsPage> {
  late String formattedDate;

  @override
  void initState() {
    super.initState();

    formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(widget.dataTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fall detials"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
            ),
            height: 400,
            child: MapWidget(
              latLng: LatLng(widget.latitude!, widget.longitude!),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            formattedDate,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
          ),
        ],
      ),
    );
  }
}
