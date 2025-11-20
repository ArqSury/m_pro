import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapFunction extends StatefulWidget {
  const MapFunction({
    super.key,
    required this.checkInLat,
    required this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });
  final double checkInLat;
  final double checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  MapFunction.pickLocation({super.key})
    : checkInLat = 0,
      checkInLng = 0,
      checkOutLat = null,
      checkOutLng = null;

  @override
  State<MapFunction> createState() => _MapFunctionState();
}

class _MapFunctionState extends State<MapFunction> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  LatLng defaultLocation = const LatLng(-6.2, 106.816666);
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw Exception("Location service disabled");
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
        if (perm != LocationPermission.always &&
            perm != LocationPermission.whileInUse) {
          throw Exception("Permission denied");
        }
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      setState(() {
        selectedLocation = LatLng(pos.latitude, pos.longitude);
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation!));
    } catch (e) {
      setState(() {
        selectedLocation = defaultLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Pilih Lokasi")),
        body: selectedLocation == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: selectedLocation!,
                      zoom: 16,
                    ),
                    myLocationEnabled: true,
                    onMapCreated: (controller) => mapController = controller,
                    onCameraMove: (pos) {
                      setState(() {
                        selectedLocation = pos.target;
                      });
                    },
                  ),
                  Center(
                    child: Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 40,
                    right: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text("Gunakan Lokasi Ini"),
                      onPressed: () {
                        Navigator.pop(context, selectedLocation);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
