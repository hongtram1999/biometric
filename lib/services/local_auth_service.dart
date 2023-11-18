import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  static Future<bool> authenticateWithBiometrics() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    bool isAuthenticated = false;

    if (isBiometricSupported && canCheckBiometrics) {
      isAuthenticated = await localAuthentication.authenticate(
        localizedReason: 'Please complete the biometrics to proceed.',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    }

    return isAuthenticated;
  }
}
