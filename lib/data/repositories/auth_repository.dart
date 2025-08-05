import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:logistics/core/services/firebase_authentication.dart';
import 'dart:developer';

class AuthRepository extends GetxController {
  final FirebaseAuthenticationService _authService = FirebaseAuthenticationService();

  void login(String email, String password) {
    _authService
        .signInWithEmail(email, password)
        .then((user) {
          if (user != null) {
            // Handle successful login
            log("Login successful: ${user.email}");
          } else {
            // Handle login failure
            log("Login failed: Invalid email or password");
          }
        })
        .catchError((error) {
          // Handle error
          log("Error during login: $error");
        });
  }
}
