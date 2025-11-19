import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final double checkInLat;
  final double checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  const MapView({
    super.key,
    required this.checkInLat,
    required this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng checkInPos = LatLng(widget.checkInLat, widget.checkInLng);
    final LatLng? checkOutPos =
        (widget.checkOutLat != null && widget.checkOutLng != null)
        ? LatLng(widget.checkOutLat!, widget.checkOutLng!)
        : null;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId("check_in"),
        position: checkInPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Check-In"),
      ),
    };

    if (checkOutPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("check_out"),
          position: checkOutPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Check-Out"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Lokasi Absen")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: checkInPos, zoom: 16),
        markers: markers,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
