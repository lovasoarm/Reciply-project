import 'package:flutter/material.dart';
import '../../../core/services/firebase/services.dart';
import '../../../data/models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  final Services _authService = Services();

  bool isLoading = false;
  String? errorMessage;

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = UserModel(username: username, email: email, password: password);
      await _authService.register(user);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
