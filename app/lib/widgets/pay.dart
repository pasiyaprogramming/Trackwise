import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaypalCheckout extends StatefulWidget {
  final String price;

  PaypalCheckout({super.key, required this.price});

  @override
  State<PaypalCheckout> createState() => _PaypalCheckoutState();
}

class _PaypalCheckoutState extends State<PaypalCheckout> {
  String _userId = '';
  late String amount;
  InAppWebViewController? _webViewController;
  String returnURL = "https://trackwise.pasiyaprogramming.live/success";
  String cancelURL = "https://trackwise.pasiyaprogramming.live/cancel";
  double progress = 0;
  late SharedPreferences _prefs;
  String selectedClass = '';
  String selectedRows = '';
  String selectedSeat = '';
  String selectedPickupLocation = '';
  String selectedDestination = '';
  String _price = '';

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    amount = widget.price;
  }

  Future<void> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    setState(() {
      _userId = userId;
      _initializeSharedPreferences();
    });
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getDetails();
  }

  Future<void> _getDetails() async {
    final String userId = _prefs.getString('userId') ?? '';
    final String sclass = _prefs.getString('selectedClass') ?? '';
    final String srow = _prefs.getString('selectedRow') ?? '';
    final String sseat = _prefs.getString('selectedSeat') ?? '';
    final String spklocation = _prefs.getString('selectedPickup') ?? '';
    final String sdlocation = _prefs.getString('selectedDestination') ?? '';
    final String price = _prefs.getString('price') ?? '';
    setState(() {
      _userId = userId;
      selectedClass = sclass;
      selectedRows = srow;
      selectedSeat = sseat;
      selectedPickupLocation = spklocation;
      selectedDestination = sdlocation;
      _price = price;
    });
  }

  Future<void> _deleteSave() async {
    await _prefs.remove('selectedClass');
    await _prefs.remove('selectedRow');
    await _prefs.remove('selectedSeat');
    await _prefs.remove('selectedPickup');
    await _prefs.remove('price');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _sendDB() async {
    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/confirmseat?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'classes': selectedClass,
        'seatrow': selectedRows,
        'seatnumber': selectedSeat,
        'pickup': selectedPickupLocation,
        'destination': selectedDestination,
        'price': _price,
      }),
    );

    if (response.statusCode == 200) {
      print("Save to db success");
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }

  Future<void> sendPayment() async {
    print(_userId);
    print(amount);
    final response = await http.post(
      Uri.parse('https://trackwise.pasiyaprogramming.live/pay?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'total': amount,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String approvalUrl = data['link'];

      _webViewController?.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(approvalUrl)));
    } else {
      print("Failed to load paypal");
    }
  }

  void _showPaymentSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 4), () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/location');
        });
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text(
            'Payment',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/success.json',
                height: 80,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text('Payment Success.'),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDeniedPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/error.json',
                height: 80,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(message),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Try again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Payment",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(textZoom: 120),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
              sendPayment();
            },
            onLoadStart: (
              InAppWebViewController? controller,
              Uri? url,
            ) {
              //print("page start loading: $url");
              if (url!.path == '/success') {
                final uri = url;
                final payerID = uri.queryParameters['PayerID'];
                if (payerID != null) {
                  Navigator.of(context).pop();
                  _sendDB();
                  _showPaymentSuccessPopup();
                  _deleteSave();
                  _prefs.setBool('trip', true);
                } else {
                  Navigator.of(context).pop();
                  _showPaymentDeniedPopup("Payment Failed");
                  _prefs.setBool('trip', false);
                }
              }
              if (url.path == '/cancel') {
                //print("Cancel URL");
                Navigator.of(context).pop();
                _showPaymentDeniedPopup("Payment Cancel");
              }
            },
            onLoadStop: (controller, url) {
              print("page finished loading: $url");
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          progress < 1
              ? SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
