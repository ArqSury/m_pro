import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/function/map_function.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/models/user_model.dart';
import 'package:m_pro/views/branches/permission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  bool isLoadingData = true;
  bool loadingCheckIn = false;
  bool loadingCheckOut = false;

  Map<String, dynamic>? absenToday;
  Map<String, dynamic>? absenStats;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      UserModel profile = await AuthAPI.getProfile();
      absenToday = await AuthAPI.getAbsenToday();
      absenStats = await AuthAPI.getAbsenStats();

      userName = profile.data?.name ?? "User";
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data");
    }

    if (mounted) setState(() => isLoadingData = false);
  }

  Future<Position> getLocation() async {
    LocationPermission perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak");
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> checkIn() async {
    if (absenToday != null) {
      Fluttertoast.showToast(msg: "Anda sudah absen hari ini");
      return;
    }

    setState(() => loadingCheckIn = true);

    try {
      final pos = await getLocation();
      await AuthAPI.absenCheckIn(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      Fluttertoast.showToast(msg: "Absen Masuk Berhasil");
      loadInitialData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loadingCheckIn = false);
  }

  Future<void> checkOut() async {
    if (absenToday == null) {
      Fluttertoast.showToast(msg: "Anda belum absen masuk");
      return;
    }

    if (absenToday?["check_out_time"] != null) {
      Fluttertoast.showToast(msg: "Anda sudah absen pulang");
      return;
    }

    setState(() => loadingCheckOut = true);

    try {
      final pos = await getLocation();
      await AuthAPI.absenCheckOut(
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      Fluttertoast.showToast(msg: "Absen Pulang Berhasil");
      loadInitialData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loadingCheckOut = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = DateFormat("EEEE, dd MMM yyyy", "id_ID").format(DateTime.now());
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? "Selamat Pagi"
        : hour < 17
        ? "Selamat Siang"
        : "Selamat Malam";

    final status = absenToday?["status"];
    final checkInTime = absenToday?["check_in_time"] ?? "-";
    final checkOutTime = absenToday?["check_out_time"] ?? "-";

    return SafeArea(
      child: Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: loadingCheckIn ? null : checkIn,
              label: Text(loadingCheckIn ? "..." : "Hadir"),
              icon: const Icon(Icons.login),
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.orange,
              label: const Text("Izin"),
              icon: const Icon(Icons.medical_information),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Permission()),
                );
              },
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.red,
              onPressed: loadingCheckOut ? null : checkOut,
              label: Text(loadingCheckOut ? "..." : "Pulang"),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting, $userName!",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(now, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 22),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(status),
                      child: Icon(
                        Icons.circle,
                        color: getStatusColor(status),
                        size: 16,
                      ),
                    ),
                    title: Text(
                      "Status Hari Ini: ${getStatusText(status)}",
                      style: TextStyle(
                        color: getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Masuk: $checkInTime • Pulang: $checkOutTime",
                    ),
                  ),
                ),
                SizedBox(height: 15),
                if (absenStats != null)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text("📊 Statistik Bulan Ini"),
                      subtitle: Text(
                        "Total Absen: ${absenStats!["total_absen"]}\n"
                        "Hadir: ${absenStats!["total_masuk"]} | "
                        "Izin: ${absenStats!["total_izin"]}",
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                if (absenToday?["check_in_lat"] != null)
                  SizedBox(
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            (absenToday?["check_in_lat"] as num).toDouble(),
                            (absenToday?["check_in_lng"] as num).toDouble(),
                          ),
                          zoom: 16,
                        ),
                        markers: {
                          /// Marker CHECK-IN
                          Marker(
                            markerId: const MarkerId("checkin"),
                            position: LatLng(
                              (absenToday?["check_in_lat"] as num).toDouble(),
                              (absenToday?["check_in_lng"] as num).toDouble(),
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow: const InfoWindow(
                              title: "Lokasi Check-In",
                            ),
                          ),

                          /// Marker CHECK-OUT jika ada
                          if (absenToday?["check_out_lat"] != null &&
                              absenToday?["check_out_lng"] != null)
                            Marker(
                              markerId: const MarkerId("checkout"),
                              position: LatLng(
                                (absenToday?["check_out_lat"] as num)
                                    .toDouble(),
                                (absenToday?["check_out_lng"] as num)
                                    .toDouble(),
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed,
                              ),
                              infoWindow: const InfoWindow(
                                title: "Lokasi Check-Out",
                              ),
                            ),
                        },
                        zoomControlsEnabled: false,
                        myLocationEnabled: false,
                        onTap: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapFunction(
                                checkInLat: (absenToday?["check_in_lat"] as num)
                                    .toDouble(),
                                checkInLng: (absenToday?["check_in_lng"] as num)
                                    .toDouble(),
                                checkOutLat:
                                    (absenToday?["check_out_lat"] as num?)
                                        ?.toDouble(),
                                checkOutLng:
                                    (absenToday?["check_out_lng"] as num?)
                                        ?.toDouble(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'masuk':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String getStatusText(String? status) {
    switch (status) {
      case 'masuk':
        return "Hadir";
      case 'izin':
        return "Izin";
      default:
        return "Belum Absen";
    }
  }
}
