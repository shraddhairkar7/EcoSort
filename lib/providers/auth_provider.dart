import 'package:flutter/foundation.dart';

import 'package:ecosort/models/user.dart';
import 'package:ecosort/services/data_service.dart';

/// Holds the signed-in user. All role shells read [currentUser.role].
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._data);

  final DataService _data;

  AppUser? currentUser;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => currentUser != null;

  Future<bool> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = await _data.login(
        email: email,
        password: password,
        roleOverride: role,
      );
      if (user == null) {
        error = 'Unknown account or wrong password.';
        return false;
      }
      currentUser = user;
      return true;
    } catch (e) {
      error = 'Login failed: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
