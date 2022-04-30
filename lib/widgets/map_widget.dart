import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  final LatLng? latLng;
  const MapWidget({this.latLng, Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Marker? marker;

  LatLng? _latLng;
  double _zoom = 15.0;
  Location location = Location();
  late LocationData _currentPosition;

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    // location.enableBackgroundMode(enable: false);
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: location.getLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _currentPosition = snapshot.data as LocationData;
            // setState(() {
            // });
            if (widget.latLng == null) {
              _latLng = LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
            } else {
              _latLng = widget.latLng;
            }

            return GoogleMap(
              // mapType: MapType.hybrid,
              myLocationButtonEnabled: true,
              myLocationEnabled: widget.latLng == null ? true : false,
              initialCameraPosition: CameraPosition(
                target: _latLng!,
                zoom: _zoom,
              ),
              compassEnabled: true,
              rotateGesturesEnabled: false,
              trafficEnabled: false,
              mapToolbarEnabled: false,
              scrollGesturesEnabled: false,
              indoorViewEnabled: true,
              mapType: MapType.normal,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
              markers: markers.values.toSet(),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  if (widget.latLng == null) {
                    _latLng = LatLng(_currentPosition.latitude!, _currentPosition.longitude!);
                  } else {
                    _latLng = widget.latLng;
                    marker = Marker(
                      markerId: const MarkerId('Fall_location'),
                      position: _latLng!,
                    );
                    _zoom = _zoom;
                    markers[const MarkerId('Fall_location')] = marker!;
                  }
                });
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _latLng!,
                      zoom: _zoom,
                    ),
                  ),
                );

                _controller.complete(controller);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        });
  }
}
