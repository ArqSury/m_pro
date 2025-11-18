import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFunction extends StatefulWidget {
  const MapFunction({
    super.key,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  @override
  State<MapFunction> createState() => _MapFunctionState();
}

class _MapFunctionState extends State<MapFunction> {
  GoogleMapController? mapController;
  Set<Marker> markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  void setMarkers() {
    if (widget.checkInLat != null && widget.checkInLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("checkin"),
          position: LatLng(widget.checkInLat!, widget.checkInLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: "Lokasi Check-In"),
        ),
      );
    }
    if (widget.checkOutLat != null && widget.checkOutLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("checkout"),
          position: LatLng(widget.checkOutLat!, widget.checkOutLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Lokasi Check-Out"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.checkInLat == null || widget.checkInLng == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lokasi Absen")),
        body: const Center(
          child: Text("Belum ada data lokasi absen untuk hari ini"),
        ),
      );
    }

    final center = LatLng(widget.checkInLat!, widget.checkInLng!);

    return Scaffold(
      appBar: AppBar(title: const Text("Lokasi Absen")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: center, zoom: 16),
        markers: markers,
        onMapCreated: (controller) => mapController = controller,
        myLocationEnabled: true,
      ),
    );
  }
}
