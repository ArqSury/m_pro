import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m_pro/constant/app_color.dart';
import 'package:m_pro/function/button_function.dart';
import 'package:m_pro/function/textform_function.dart';
import 'package:m_pro/models/register_request.dart';
import 'package:m_pro/services/api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  List<Map<String, dynamic>> batchList = [];
  List<Map<String, dynamic>> trainingList = [];
  int? selectedBatchId;
  int? selectedTrainingId;
  bool loadingDropdown = true;
  bool loadingRegister = false;

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? selectedGender;
  File? selectedImage;
  String? base64Photo;

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  Future loadDropdownData() async {
    try {
      batchList = await AuthAPI.getBatchList();
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat batch");
    }

    setState(() => loadingDropdown = false);
  }

  void loadTrainingForBatch(int batchId) {
    final selected = batchList.firstWhere((b) => b["id"] == batchId);
    trainingList = List<Map<String, dynamic>>.from(selected["trainings"]);

    selectedTrainingId = null;
    setState(() {});
  }

  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);

    if (img == null) return;

    final bytes = await img.readAsBytes();
    final base64Str = base64Encode(bytes);

    setState(() {
      selectedImage = File(img.path);
      base64Photo = "data:image/png;base64,$base64Str";
    });
  }

  Future register() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedGender == null) {
      Fluttertoast.showToast(msg: "Pilih jenis kelamin");
      return;
    }
    if (selectedBatchId == null) {
      Fluttertoast.showToast(msg: "Pilih batch");
      return;
    }
    if (selectedTrainingId == null) {
      Fluttertoast.showToast(msg: "Pilih jenis pelatihan");
      return;
    }
    setState(() => loadingRegister = true);
    try {
      await AuthAPI.registerUser(
        RegisterRequest(
          name: nameC.text,
          email: emailC.text,
          password: passwordC.text,
          jenisKelamin: selectedGender!,
          batchId: selectedBatchId!,
          trainingId: selectedTrainingId!,
          profilePhoto: base64Photo,
        ),
      );
      Fluttertoast.showToast(msg: "Registrasi berhasil");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll("Exception:", "").trim(),
      );
    }
    if (mounted) setState(() => loadingRegister = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildFormLayer()],
        ),
      ),
    );
  }

  Padding buildFormLayer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Text(
                "Daftar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              inputName(),
              SizedBox(height: 16),
              inputEmail(),
              SizedBox(height: 16),
              inputPassword(),
              SizedBox(height: 16),
              inputGender(),
              SizedBox(height: 16),
              inputBatchDropdown(),
              SizedBox(height: 16),
              inputTrainingDropdown(),
              SizedBox(height: 16),
              inputProfilePhoto(),
              SizedBox(height: 28),
              ButtonFunction(
                text: loadingRegister ? "Loading..." : "Daftar",
                height: 50,
                width: double.infinity,
                backgroundColor: AppColor.button,
                color: Colors.white,
                onPressed: loadingRegister ? null : register,
              ),
              SizedBox(height: 40),
              Divider(color: Colors.white),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sudah punya akun?",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(color: Colors.lightBlueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextformFunction inputName() {
    return TextformFunction(
      hint: "Nama",
      controller: nameC,
      validator: (v) =>
          v == null || v.isEmpty ? "Nama tidak boleh kosong" : null,
    );
  }

  TextformFunction inputEmail() {
    return TextformFunction(
      hint: "Email",
      controller: emailC,
      validator: (v) {
        if (v == null || v.isEmpty) return "Email tidak boleh kosong";
        if (!v.contains("@")) return "Email tidak valid";
        return null;
      },
    );
  }

  TextformFunction inputPassword() {
    return TextformFunction(
      hint: "Kata Sandi",
      controller: passwordC,
      isPassword: true,
      validator: (v) {
        if (v == null || v.isEmpty) return "Password tidak boleh kosong";
        if (v.length < 6) return "Minimal 6 karakter";
        return null;
      },
    );
  }

  DropdownButtonFormField<String> inputGender() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Jenis Kelamin",
        border: OutlineInputBorder(),
      ),
      value: selectedGender,
      items: [
        DropdownMenuItem(value: "L", child: Text("Laki-laki")),
        DropdownMenuItem(value: "P", child: Text("Perempuan")),
      ],
      onChanged: (v) => setState(() => selectedGender = v),
      validator: (v) => v == null ? "Pilih jenis kelamin" : null,
    );
  }

  Widget inputBatchDropdown() {
    if (loadingDropdown) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Batch Pelatihan",
        border: OutlineInputBorder(),
      ),
      value: selectedBatchId,
      items: batchList.map((b) {
        return DropdownMenuItem<int>(
          value: (b["id"] as num).toInt(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              "Batch ${b["batch_ke"]} (${b["start_date"]} - ${b["end_date"]})",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: (v) {
        setState(() {
          selectedBatchId = v;
          loadTrainingForBatch(v!);
        });
      },
      validator: (v) => v == null ? "Batch wajib dipilih" : null,
    );
  }

  Widget inputTrainingDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Pelatihan",
        border: OutlineInputBorder(),
      ),
      value: selectedTrainingId,
      items: trainingList.isEmpty
          ? []
          : trainingList.map((t) {
              return DropdownMenuItem<int>(
                value: (t["id"] as num).toInt(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(t["title"], overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
      onChanged: trainingList.isEmpty
          ? null
          : (v) => setState(() => selectedTrainingId = v),
      validator: (v) => v == null ? "Pilih pelatihan" : null,
    );
  }

  Widget inputProfilePhoto() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: InkWell(
        onTap: pickImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : null,
              child: selectedImage == null
                  ? Icon(Icons.camera_alt, size: 40)
                  : null,
            ),
            SizedBox(height: 10),
            Text("Pilih Foto Profil"),
          ],
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background/background_ariq.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
