import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:m_pro/constant/app_color.dart';
import 'package:m_pro/services/api.dart';

class Permission extends StatefulWidget {
  const Permission({super.key});

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final alasanC = TextEditingController();
  DateTime? selectedDate;
  bool loading = false;

  Future<void> submitIzin() async {
    if (selectedDate == null) {
      Fluttertoast.showToast(msg: "Tanggal belum dipilih");
      return;
    }
    if (alasanC.text.isEmpty) {
      Fluttertoast.showToast(msg: "Alasan izin wajib diisi");
      return;
    }

    setState(() => loading = true);

    try {
      await AuthAPI.submitIzin(
        date: DateFormat("yyyy-MM-dd").format(selectedDate!),
        alasan: alasanC.text,
      );
      Fluttertoast.showToast(msg: "Izin berhasil diajukan");
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Form Izin / Sakit")),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildLayer()],
        ),
      ),
    );
  }

  Padding buildLayer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            title: Text(
              selectedDate == null
                  ? "Pilih tanggal"
                  : DateFormat("dd MMM yyyy").format(selectedDate!),
            ),
            trailing: const Icon(Icons.calendar_month),
            onTap: pickDate,
          ),
          TextField(
            controller: alasanC,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Alasan Izin",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: loading ? null : submitIzin,
            child: Text(
              loading ? "Mengirim..." : "Kirim Izin",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 30)),
      initialDate: now,
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background/background3_ariq.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
