import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReportMissingToolPage extends StatefulWidget {
  @override
  _ReportMissingToolPageState createState() => _ReportMissingToolPageState();
}

class _ReportMissingToolPageState extends State<ReportMissingToolPage> {
  String _userId = '';
  String? _messageErrorText;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _fetchUserId();
    super.initState();
  }

  Future<void> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _sendReport() async {
    print('Report Sent: ${_controller.text}');

    final String message = _controller.text;

    if (message.isEmpty) {
      setState(() {
        _messageErrorText = message.isEmpty ? 'message is required' : null;
      });
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/reportmissing?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      _snakbaresp(message, Colors.green);
      Navigator.pop(context);
      Future.delayed(const Duration(seconds: 3));
      _controller.clear();
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      _snakbaresp(message, Colors.red);
    }
  }

  void _snakbaresp(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      ),
      duration: const Duration(seconds: 5), // Set duration to a longer period
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset("assets/circle.png", height: 150)),
              ],
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/images/cleanup.png"),
                ]),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: <Widget>[
                  Text(
                    'Your safety is important to us.',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe the missing Items...',
                      errorText: _messageErrorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _sendReport,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                        child: const Text('Send',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
