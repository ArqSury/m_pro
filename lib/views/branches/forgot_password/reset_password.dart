import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:m_pro/function/textform_function.dart';
import 'package:m_pro/services/api.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.email});
  final String email;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final otpC = TextEditingController();
  final passC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthAPI.resetPassword(
        email: widget.email,
        otp: otpC.text,
        newPassword: passC.text,
      );

      Fluttertoast.showToast(msg: "Kata sandi berhasil diubah");

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Reset Kata Sandi'), centerTitle: true),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [buildBackground(), buildLayer()],
        ),
      ),
    );
  }

  Widget buildLayer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            inputOTP(),
            SizedBox(height: 16),
            inputNewPass(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : resetPassword,
              child: Text(isLoading ? "Loading..." : "Ubah Kata Sandi"),
            ),
          ],
        ),
      ),
    );
  }

  TextformFunction inputNewPass() {
    return TextformFunction(
      controller: passC,
      hint: 'Kata Sandi Baru',
      isPassword: true,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Kata sandi tidak boleh kosong";
        } else if (v.length < 8) {
          return "Kata sandi minimal 8 karakter";
        }
        return null;
      },
    );
  }

  TextformFunction inputOTP() {
    return TextformFunction(
      controller: otpC,
      hint: 'OTP',
      isNumber: true,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "OTP wajib diisi";
        }
        return null;
      },
    );
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
