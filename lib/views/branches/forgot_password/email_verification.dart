import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:m_pro/services/api.dart';
import 'package:m_pro/views/branches/forgot_password/reset_password.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final emailC = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  requestOtp() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthAPI.requestOtp(emailC.text);

      Fluttertoast.showToast(msg: "OTP berhasil dikirim ke email");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPassword(email: emailC.text),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
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

  Padding buildLayer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Masukan email Anda', style: TextStyle(fontSize: 40)),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Email required" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : requestOtp,
                child: Text(isLoading ? "Loading..." : "Kirim OTP"),
              ),
            ],
          ),
        ),
      ),
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
