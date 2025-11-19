import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/function/map_function.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/models/user_model.dart';
import 'package:m_pro/services/shared_preferences/preferences_handler.dart';
import 'package:m_pro/views/branches/map_view.dart';
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

  double? savedCheckInLat;
  double? savedCheckInLng;
  double? savedCheckOutLat;
  double? savedCheckOutLng;

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

      // Load saved GPS (do NOT delete)
      savedCheckInLat = await PreferencesHandler.getDouble("check_in_lat");
      savedCheckInLng = await PreferencesHandler.getDouble("check_in_lng");
      savedCheckOutLat = await PreferencesHandler.getDouble("check_out_lat");
      savedCheckOutLng = await PreferencesHandler.getDouble("check_out_lng");

      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final serverDate = absenToday?["attendance_date"];

      if (serverDate != today) {
        // New day -> clear old map
        await PreferencesHandler.remove("check_in_lat");
        await PreferencesHandler.remove("check_in_lng");
        await PreferencesHandler.remove("check_out_lat");
        await PreferencesHandler.remove("check_out_lng");

        savedCheckInLat = null;
        savedCheckInLng = null;
        savedCheckOutLat = null;
        savedCheckOutLng = null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data");
    }

    if (mounted) setState(() => isLoadingData = false);
  }

  // ---------------------- CHECK IN ----------------------------
  Future<void> checkIn() async {
    if (absenToday != null) {
      Fluttertoast.showToast(msg: "Anda sudah absen hari ini");
      return;
    }

    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapFunction.pickLocation()),
    );

    if (selectedLocation == null) {
      Fluttertoast.showToast(msg: "Lokasi tidak dipilih");
      return;
    }

    setState(() => loadingCheckIn = true);

    try {
      await AuthAPI.absenCheckIn(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      // Save locally
      await PreferencesHandler.saveDouble(
        "check_in_lat",
        selectedLocation.latitude,
      );
      await PreferencesHandler.saveDouble(
        "check_in_lng",
        selectedLocation.longitude,
      );

      Fluttertoast.showToast(msg: "Absen Masuk Berhasil");
      await loadInitialData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loadingCheckIn = false);
  }

  // ---------------------- CHECK OUT ----------------------------
  Future<void> checkOut() async {
    if (absenToday == null) {
      Fluttertoast.showToast(msg: "Anda belum absen masuk");
      return;
    }

    if (absenToday?["check_out_time"] != null) {
      Fluttertoast.showToast(msg: "Anda sudah absen pulang");
      return;
    }

    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapFunction.pickLocation()),
    );

    if (selectedLocation == null) {
      Fluttertoast.showToast(msg: "Lokasi tidak dipilih");
      return;
    }

    setState(() => loadingCheckOut = true);

    try {
      await AuthAPI.absenCheckOut(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      // Save locally
      await PreferencesHandler.saveDouble(
        "check_out_lat",
        selectedLocation.latitude,
      );
      await PreferencesHandler.saveDouble(
        "check_out_lng",
        selectedLocation.longitude,
      );

      Fluttertoast.showToast(msg: "Absen Pulang Berhasil");
      await loadInitialData();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loadingCheckOut = false);
  }

  // ---------------------- UI ----------------------------
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
              heroTag: "checkInBtn",
              backgroundColor: Colors.green,
              onPressed: loadingCheckIn ? null : checkIn,
              label: Text(loadingCheckIn ? "..." : "Hadir"),
              icon: const Icon(Icons.login),
            ),
            FloatingActionButton.extended(
              heroTag: "izinBtn",
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
              heroTag: "checkOutBtn",
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(now, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(status),
                    ),
                    title: Text(
                      "Status Hari Ini:\n${getStatusText(status)}",
                      style: TextStyle(
                        color: getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Masuk: $checkInTime \nPulang: $checkOutTime",
                    ),

                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapView(
                              checkInLat: savedCheckInLat!,
                              checkInLng: savedCheckInLng!,
                              checkOutLat: savedCheckOutLat,
                              checkOutLng: savedCheckOutLng,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.map),
                      label: Text("Lihat\nLokasi"),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (absenStats != null)
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.bar_chart),
                      title: const Text("Statistik Bulan Ini"),
                      subtitle: Text(
                        "Total Absen: ${absenStats!["total_absen"]}\n"
                        "Hadir: ${absenStats!["total_masuk"]} | Izin: ${absenStats!["total_izin"]}",
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
