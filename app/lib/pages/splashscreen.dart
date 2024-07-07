import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../controllers/provider.dart';

class Internetcheck extends StatefulWidget {
  const Internetcheck({super.key});

  @override
  State<Internetcheck> createState() => _InternetcheckState();
}

class _InternetcheckState extends State<Internetcheck> {
  late Connectivity _connectivity;
  bool _isDialogShown = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkInitialConnectivity(result);
    });
    _delayedCheckInitialConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _delayedCheckInitialConnectivity() {
    Future.delayed(const Duration(seconds: 2), () {
      _connectivity.checkConnectivity().then((ConnectivityResult result) {
        if (result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile) {
          _hideDialog();
        } else {
          _checkInitialConnectivity(ConnectivityResult.none);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset(
            'assets/trainlogo.png',
            height: 150,
          ),
        ),
      ),
    );
  }

  void _checkInitialConnectivity(ConnectivityResult result) {
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      _checkInternetConnectivity(result);
    } else {
      _showDialog();
    }
  }

  Future<void> _checkInternetConnectivity(ConnectivityResult result) async {
    bool isConnected = false;

    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      try {
        final response = await http.head(
          Uri.parse('https://www.google.com'),
          headers: {"Connection": "close"},
        ).timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          isConnected = true;
        }
      } catch (e) {
        isConnected = false;
      }
    }

    if (!isConnected) {
      setState(() {});
      _showDialog();
    } else {
      setState(() {});
      _hideDialog();
      _navigateToAnother();
    }
  }

  void _showDialog() {
    if (!_isDialogShown) {
      _isDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'No Internet',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 400,
              height: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/nointernet.json', height: 160),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'No internet connection available.',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _hideDialog() {
    if (_isDialogShown) {
      Navigator.of(context).pop();
      _isDialogShown = false;
    }
  }

  void _navigateToAnother() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {});

    await Provider.of<AuthProvider>(context, listen: false).checkLoggedIn();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
