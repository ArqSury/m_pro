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
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final batchC = TextEditingController();
  final trainingC = TextEditingController();

  final formKey = GlobalKey<FormState>();
  String? gender;
  bool isLoading = false;

  File? selectedImage;
  String? base64Photo;

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

    Fluttertoast.showToast(msg: "Foto dipilih");
  }

  register() async {
    if (!formKey.currentState!.validate()) return;

    if (gender == null) {
      Fluttertoast.showToast(msg: "Pilih jenis kelamin");
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthAPI.registerUser(
        RegisterRequest(
          name: nameC.text,
          email: emailC.text,
          password: passwordC.text,
          jenisKelamin: gender!,
          batchId: int.parse(batchC.text),
          trainingId: int.parse(trainingC.text),
          profilePhoto: base64Photo,
        ),
      );
      print("REGISTER START");
      print("REGISTER DONE");

      Fluttertoast.showToast(msg: "Registrasi berhasil");

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll("Exception:", ""));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildLayer()],
        ),
      ),
    );
  }

  Padding buildLayer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const Text(
                  'Daftar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                inputName(),
                const SizedBox(height: 16),
                inputEmail(),
                const SizedBox(height: 16),
                inputPassword(),
                const SizedBox(height: 16),
                inputGender(),
                const SizedBox(height: 16),
                inputBatchID(),
                const SizedBox(height: 16),
                inputTrainingID(),
                const SizedBox(height: 16),
                inputProfilePhoto(),

                const SizedBox(height: 28),

                ButtonFunction(
                  text: isLoading ? "Loading..." : "Daftar",
                  height: 50,
                  width: double.infinity,
                  backgroundColor: AppColor.button,
                  color: Colors.white,
                  onPressed: isLoading ? null : register,
                ),

                const SizedBox(height: 40),
                const Divider(color: Colors.white),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Masuk',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextformFunction inputName() {
    return TextformFunction(
      hint: "Nama",
      controller: nameC,
      validator: (v) {
        if (v == null || v.isEmpty) return "Nama tidak boleh kosong";
        return null;
      },
    );
  }

  TextformFunction inputEmail() {
    return TextformFunction(
      hint: "Email",
      controller: emailC,
      validator: (v) {
        if (v == null || v.isEmpty) return "Email tidak boleh kosong";
        if (!v.contains('@')) return "Email tidak valid";
        return null;
      },
    );
  }

  TextformFunction inputPassword() {
    return TextformFunction(
      hint: "Kata Sandi",
      isPassword: true,
      controller: passwordC,
      validator: (v) {
        if (v == null || v.isEmpty) return "Kata sandi tidak boleh kosong";
        if (v.length < 6) return "Minimal 6 karakter";
        return null;
      },
    );
  }

  DropdownButtonFormField<String> inputGender() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Jenis Kelamin",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      value: gender,
      hint: const Text("Pilih Jenis Kelamin"),
      items: const [
        DropdownMenuItem(value: "L", child: Text("Laki-laki")),
        DropdownMenuItem(value: "P", child: Text("Perempuan")),
      ],
      validator: (v) => v == null ? "Jenis kelamin wajib dipilih" : null,
      onChanged: (v) => setState(() => gender = v),
    );
  }

  TextformFunction inputBatchID() {
    return TextformFunction(
      hint: "Batch ID",
      isNumber: true,
      controller: batchC,
      validator: (v) =>
          v == null || v.isEmpty ? "Batch ID tidak boleh kosong" : null,
    );
  }

  TextformFunction inputTrainingID() {
    return TextformFunction(
      hint: "Training ID",
      isNumber: true,
      controller: trainingC,
      validator: (v) =>
          v == null || v.isEmpty ? "Training ID tidak boleh kosong" : null,
    );
  }

  Container inputProfilePhoto() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: pickImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : null,
              child: selectedImage == null
                  ? const Icon(Icons.camera_alt, size: 40)
                  : null,
            ),
            const SizedBox(height: 10),
            const Text("Pilih Foto Profil"),
          ],
        ),
      ),
    );
  }

  Container buildBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background/background_ariq.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
