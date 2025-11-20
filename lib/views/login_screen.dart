import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:m_pro/constant/app_color.dart';
import 'package:m_pro/function/button_function.dart';
import 'package:m_pro/function/textform_function.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/services/shared_preferences/preferences_handler.dart';
import 'package:m_pro/views/branches/forgot_password/email_verification.dart';
import 'package:m_pro/views/main_screen.dart';
import 'package:m_pro/views/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool rememberMe = false;

  login() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final user = await AuthAPI.login(
        email: emailC.text,
        password: passwordC.text,
      );
      await PreferencesHandler.saveToken(user.data?.token ?? "");
      await PreferencesHandler.saveRememberMe(rememberMe);
      Fluttertoast.showToast(msg: "Login berhasil");
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll("Exception:", ""));
    }
    setState(() => isLoading = false);
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

  Widget buildLayer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Colors.white,
                ),
              ),
              Divider(color: Colors.white, indent: 20, endIndent: 20),
              Text(
                'Isi biodata Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Times New Roman',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              inputEmail(),
              SizedBox(height: 16),
              inputPassword(),
              Row(children: [buildRemember(), Spacer(), buildForgot()]),
              SizedBox(height: 16),
              ButtonFunction(
                text: isLoading ? "..." : "Masuk",
                height: 40,
                width: double.infinity,
                backgroundColor: AppColor.button,
                color: Colors.white,
                onPressed: isLoading ? null : login,
              ),
              SizedBox(height: 40),
              Divider(color: Colors.white),
              SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Daftar",
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

  TextButton buildForgot() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmailVerification()),
        );
      },
      child: Text("Lupa kata sandi?", style: TextStyle(color: Colors.white)),
    );
  }

  Row buildRemember() {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: (v) {
            setState(() => rememberMe = v!);
          },
        ),
        Text("Remember Me", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  TextformFunction inputPassword() {
    return TextformFunction(
      hint: "Kata Sandi",
      isPassword: true,
      controller: passwordC,
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

  TextformFunction inputEmail() {
    return TextformFunction(
      hint: "Email",
      controller: emailC,
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "Email tidak boleh kosong";
        } else if (!v.contains('@')) {
          return "Email tidak valid";
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
          image: AssetImage('assets/images/background/background_ariq.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
