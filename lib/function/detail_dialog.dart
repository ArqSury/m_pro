import 'package:flutter/material.dart';
import 'package:m_pro/views/branches/map_view.dart';

class DetailDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final checkInLat = data["check_in_lat"]?.toDouble();
    final checkInLng = data["check_in_lng"]?.toDouble();
    final checkOutLat = data["check_out_lat"]?.toDouble();
    final checkOutLng = data["check_out_lng"]?.toDouble();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Detail Absensi",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Tanggal", data["attendance_date"]),
            _info("Status", data["status"]),
            _info("Check-In", data["check_in_time"] ?? "-"),
            _info("Check-Out", data["check_out_time"] ?? "-"),
            _info("Alasan Izin", data["alasan_izin"] ?? "-"),

            const SizedBox(height: 20),

            if (checkInLat != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("Lihat Lokasi"),
                onPressed: () {
                  Navigator.pop(context); // close dialog dulu
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapView(
                        checkInLat: checkInLat,
                        checkInLng: checkInLng,
                        checkOutLat: checkOutLat,
                        checkOutLng: checkOutLng,
                      ),
                    ),
                  );
                },
              )
            else
              const Text(
                "Tidak ada data lokasi",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Tutup"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$title:")),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
