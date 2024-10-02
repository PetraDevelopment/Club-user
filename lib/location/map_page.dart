// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class Maps extends StatefulWidget {
//   @override
//   State<Maps> createState() {
//     return MapsState();
//   }
// }
//
// class MapsState extends State<Maps> {
//   late GoogleMapController mapController;
//   final LatLng _center = const LatLng(-23.5557714, -46.6395571);
//
//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   void requestLocationPermission() async {
//     var status = await Permission.location.status;
//     if (status.isDenied) {
//       await Permission.location.request();
//     }
//
//     if (await Permission.location.isPermanentlyDenied) {
//       // The user opted not to allow location permissions permanently, open app settings
//       openAppSettings();
//     }
//
//     if (await Permission.locationAlways.isDenied) {
//       await Permission.locationAlways.request();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Google Map"),
//       ),
//       body: GoogleMap(
//         onMapCreated: onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _center,
//           zoom: 12,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
class Maps extends StatefulWidget {
  @override
  State<Maps> createState() {
    return MapsState();
  }
}
class MapsState extends State<Maps> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(0.0, 0.0);
  bool _isPermissionGranted = false;

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
// Reverse geocode to get the place name from LatLng
  Future<String> _getPlaceName(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      print("locality${place.locality}");
      return "${place.street},${place.locality},${place.country}";
    } catch (e) {
      return "Unknown Location";
    }
  }
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });

    if (mapController != null) {
      // Move the camera to the user's current location
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
    print("Map Created Successfully!"); // Add this to debug map creation
  }

  void _onMapTapped(LatLng tappedPoint) async {
    // Get the place name from the tapped coordinates
    String placeName = await _getPlaceName(tappedPoint);

    // Pass the place name back to the previous screen
    Navigator.pop(context, placeName);
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
        onTap: _onMapTapped, // Detect when user taps a location on the map
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
//
// class MapsState extends State<Maps> {
//   late GoogleMapController mapController;
//   LatLng _initialPosition = LatLng(0.0, 0.0);
//   bool _isPermissionGranted = false;
//   void requestLocationPermission() async {
//     var status = await Permission.location.status;
//     if (status.isGranted) {
//       setState(() {
//         _isPermissionGranted = true;
//       });
//       _getCurrentLocation();
//     } else {
//       var result = await Permission.location.request();
//       if (result.isGranted) {
//         setState(() {
//           _isPermissionGranted = true;
//         });
//         _getCurrentLocation();
//       } else if (result.isPermanentlyDenied) {
//         openAppSettings();
//       }
//     }
//   }
//
//
//   void _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     setState(() {
//       _initialPosition = LatLng(position.latitude, position.longitude);
//     });
//
//     // Move the camera to the user's current location
//     mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: _initialPosition,
//           zoom: 12,
//         ),
//       ),
//     );
//   }
//   @override
//   void initState() {
//     super.initState();
//     requestLocationPermission();
//   }
//
//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     if (_isPermissionGranted) {
//       _getCurrentLocation();
//     }
//   }
//   void _onMapTapped(LatLng tappedPoint) {
//     print('Selected Location: ${tappedPoint.latitude}, ${tappedPoint.longitude}');
//     // You can also store the selected location in a variable if needed
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Google Map"),
//       ),
//       body: _isPermissionGranted
//           ? GoogleMap(
//         onMapCreated: onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 12,
//         ),
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         onTap: _onMapTapped, // Detect when user taps a location on the map
//       )
//           : Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }