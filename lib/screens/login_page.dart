import 'package:biometric/screens/home_page.dart';
import 'package:biometric/services/local_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: MaterialButton(
          color: Colors.blue,
          onPressed: () async {
            bool isAuthenticated =
                await LocalAuthService.authenticateWithBiometrics();
            if (isAuthenticated) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomePage()));
            }
          },
          child: const Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
