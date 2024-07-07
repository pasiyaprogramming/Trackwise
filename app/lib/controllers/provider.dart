import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isTripNow = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isTripNow => _isTripNow;
  final _tripController = StreamController<bool>.broadcast();
  final _loginController = StreamController<bool>.broadcast();
  Stream<bool> get tripStream => _tripController.stream;
  Stream<bool> get loginStream => _loginController.stream;
  late Timer _fetchDataTimer;
  AuthProvider() {
    _fetchDataTimer = Timer.periodic(const Duration(milliseconds: 4000), (_) {
      if (_isLoggedIn) {
        _fetchDataTimer.cancel();
      }
    });
  }
  Future<void> checkLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    _loginController.sink.add(_isLoggedIn);
  }

  Future<void> checkTripIn() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? trip = prefs.getBool('trip') ?? false;
    if (trip != false) {
      _isTripNow = true;
    } else {
      _isTripNow = false;
    }
  }

  @override
  void dispose() {
    _loginController.close();
    _tripController.close();
    super.dispose();
  }

  void updateLoginState(bool loggedIn) {
    _isLoggedIn = loggedIn;
    if (!_isLoggedIn) {
      // Stop fetching data when logged out
      _fetchDataTimer.cancel();
    }
    notifyListeners();
  }

  void updateTripState(bool trip) {
    _isTripNow = trip;
    if (!_isTripNow) {
      // Stop fetching data when logged out
      _fetchDataTimer.cancel();
    }
    notifyListeners();
  }

  Future<void> endtrip(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('trip');
    updateTripState(false);
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
    updateLoginState(false);
  }
}
