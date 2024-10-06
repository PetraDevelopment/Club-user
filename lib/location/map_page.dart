import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Maps extends StatefulWidget {
  final String location;

  Maps({required this.location});

  @override
  State<Maps> createState() {
    return MapsState();
  }
}

class MapsState extends State<Maps> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(0.0, 0.0);
  bool _isPermissionGranted = false;
  Set<Marker> _markers = {};

  void requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      _getCurrentLocation();
    } else {
      var result = await Permission.location.request();
      if (result.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getCurrentLocation();
      } else if (result.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  void _getCurrentLocation() async {
    List<Location> locations = await locationFromAddress(widget.location);
    Location location = locations.first;
    double latitude = location.latitude;
    double longitude = location.longitude;

    setState(() {
      _initialPosition = LatLng(latitude, longitude);
      _markers.add(
        Marker(
          markerId: MarkerId("selected_location"),
          position: _initialPosition,
          infoWindow: InfoWindow(title: "Selected Location"),
        ),
      );
    });

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _initialPosition,
            zoom: 12,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_isPermissionGranted) {
      _getCurrentLocation();
    }
    print("Map Created Successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map"),
      ),
      body: _isPermissionGranted
          ? GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}