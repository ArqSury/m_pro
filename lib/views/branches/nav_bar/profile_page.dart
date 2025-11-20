import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:m_pro/constant/app_color.dart';

import 'package:m_pro/constant/endpoint.dart';
import 'package:m_pro/function/button_function.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/services/shared_preferences/preferences_handler.dart';
import 'package:m_pro/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = true;
  bool savingPhoto = false;

  UserModel? profile;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final p = await AuthAPI.getProfile();
      if (p.message == "Unauthenticated.") {
        await PreferencesHandler.logout();
        Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
        return;
      }
      profile = p;
      nameController.text = p.data?.name ?? "";
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat profil");
    }
    setState(() => loading = false);
  }

  Future<void> showEditNameDialog() async {
    nameController.text = profile?.data?.name ?? "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Nama baru",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () async {
              Navigator.pop(context);
              await updateName();
            },
          ),
        ],
      ),
    );
  }

  Future<void> updateName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) {
      Fluttertoast.showToast(msg: "Nama tidak boleh kosong");
      return;
    }
    try {
      final token = await PreferencesHandler.getToken();

      final res = await http.put(
        Uri.parse(Endpoint.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": newName}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Nama berhasil diubah");
        await loadProfile();
      } else {
        Fluttertoast.showToast(msg: body["message"] ?? "Gagal update nama");
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Kesalahan jaringan");
    }
  }

  Future<void> showPhotoPicker() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: 180,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Pilih Sumber Foto",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last;
    final base64Image = "data:image/$ext;base64,${base64Encode(bytes)}";
    setState(() => savingPhoto = true);
    try {
      final token = await PreferencesHandler.getToken();
      final res = await http.put(
        Uri.parse("${Endpoint.baseUrl}/profile/photo"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"profile_photo": base64Image}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        Fluttertoast.showToast(msg: "Foto berhasil diperbarui");
        await loadProfile();
      } else {
        Fluttertoast.showToast(msg: body["message"] ?? "Gagal update foto");
      }
    } catch (_) {
      Fluttertoast.showToast(msg: "Kesalahan upload foto");
    }
    setState(() => savingPhoto = false);
  }

  Future<void> fullLogout() async {
    await PreferencesHandler.logout();
    Fluttertoast.showToast(msg: "Berhasil logout");
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  Future<void> exitApp() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keluar Aplikasi"),
        content: const Text(
          "Yakin ingin keluar aplikasi?\nLogin Anda tetap tersimpan.",
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar"),
            onPressed: () {
              Navigator.pop(ctx);
              Fluttertoast.showToast(msg: "Keluar (tetap login)");
              Future.delayed(const Duration(milliseconds: 200), () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = profile!.data!;
    final created = data.createdAt != null
        ? "${data.createdAt!.day}-${data.createdAt!.month}-${data.createdAt!.year}"
        : "-";
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profil Saya"),
          centerTitle: true,
          backgroundColor: AppColor.primary,
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildLayer(data, created)],
        ),
      ),
    );
  }

  Widget buildLayer(Data data, String created) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [buildProfile(data), SizedBox(height: 40), buildSetting()],
      ),
    );
  }

  Container buildSetting() {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonFunction(
            text: 'Log Out',
            color: Colors.orange,
            height: 40,
            width: double.infinity,
            onPressed: fullLogout,
            fontSize: 28,
          ),
          Divider(color: Colors.black),
          ButtonFunction(
            text: 'Keluar Aplikasi',
            color: Colors.red,
            height: 40,
            width: double.infinity,
            onPressed: exitApp,
            fontSize: 28,
          ),
        ],
      ),
    );
  }

  Container buildProfile(Data data) {
    return Container(
      width: double.infinity,
      height: 380,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildProfilePhoto(data),
          SizedBox(height: 10),
          savingPhoto
              ? Text("Mengupload foto...")
              : Text("Tap untuk ganti foto"),
          SizedBox(height: 25),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Nama"),
            subtitle: Text(data.name ?? "-"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: showEditNameDialog,
            ),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email"),
            subtitle: Text(data.email ?? "-"),
          ),
        ],
      ),
    );
  }

  GestureDetector buildProfilePhoto(Data data) {
    return GestureDetector(
      onTap: savingPhoto ? null : showPhotoPicker,
      child: CircleAvatar(
        radius: 65,
        backgroundImage:
            (data.profilePhotoUrl != null && data.profilePhotoUrl!.isNotEmpty)
            ? NetworkImage(data.profilePhotoUrl!)
            : null,
        child: (data.profilePhotoUrl == null || data.profilePhotoUrl!.isEmpty)
            ? Icon(Icons.person, size: 70)
            : null,
      ),
    );
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.button,
            AppColor.primary,
            AppColor.success,
            AppColor.secondary,
          ],
        ),
      ),
    );
  }
}
