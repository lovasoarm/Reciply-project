import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firebase/services.dart';
import '../../../data/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final Services _authService = Services();

  bool isLoading = false;
  String? errorMessage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<String> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = UserModel(email: email, password: password);
      await _authService.signIn(user);
      errorMessage = null;
      return 'success';
    } catch (e) {
      errorMessage = e.toString();
      if (errorMessage!.contains('user not found')) {
        return 'user_not_found';
      } else {
        return 'error';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'unknown_error';
    }
  }
}
