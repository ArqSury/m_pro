import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/constant/app_color.dart';
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

      savedCheckInLat = await PreferencesHandler.getDouble("check_in_lat");
      savedCheckInLng = await PreferencesHandler.getDouble("check_in_lng");
      savedCheckOutLat = await PreferencesHandler.getDouble("check_out_lat");
      savedCheckOutLng = await PreferencesHandler.getDouble("check_out_lng");

      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final serverDate = absenToday?["attendance_date"];

      if (serverDate != today) {
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
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            buildBackground(),
            buildLayer(
              greeting,
              now,
              status,
              checkInTime,
              checkOutTime,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLayer(
    String greeting,
    String now,
    status,
    checkInTime,
    checkOutTime,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildGreeting(greeting, now),
            buildStatus(status, checkInTime, checkOutTime, context),
            SizedBox(height: 20),
            if (absenStats != null) buildStatistic(),
          ],
        ),
      ),
    );
  }

  Card buildStatistic() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Statistik Bulan Ini',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.black),
              Text(
                'Total Absen: ${absenStats!["total_absen"]}',
                style: TextStyle(fontSize: 16, color: AppColor.primary),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    'Hadir\n${absenStats!["total_masuk"]}',
                    style: TextStyle(fontSize: 24, color: Colors.lightGreen),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Izin\n${absenStats!["total_izin"]}',
                    style: TextStyle(fontSize: 24, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: loadingCheckIn ? null : checkIn,
          icon: Icon(Icons.login, color: Colors.white),
          label: Text(
            loadingCheckIn ? "..." : "Hadir",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Permission()),
            );
          },
          icon: Icon(Icons.medical_information, color: Colors.white),
          label: Text("Izin", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: loadingCheckOut ? null : checkOut,
          icon: Icon(Icons.logout, color: Colors.white),
          label: Text(
            loadingCheckOut ? "..." : "Pulang",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Card buildStatus(status, checkInTime, checkOutTime, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(backgroundColor: getStatusColor(status)),
                  SizedBox(width: 20),
                  Text(
                    "Status: ${getStatusText(status)}",
                    style: TextStyle(
                      color: getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text('Masuk: $checkInTime'),
                  Spacer(),
                  Text('Pulang: $checkOutTime'),
                  Spacer(),
                ],
              ),
              SizedBox(height: 20),
              buildButton(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildGreeting(String greeting, String now) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$greeting!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(now, style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
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

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.button, AppColor.secondary],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
    );
  }
}
