import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class changepasswordbt extends StatefulWidget {
  const changepasswordbt({super.key});

  @override
  State<changepasswordbt> createState() => _changepasswordbtState();
}

class _changepasswordbtState extends State<changepasswordbt> {
  String _userId = '';
  String _token = '';

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  bool _isObserve = true;
  String? _passwordErrorText;
  String? _cpasswordErrorText;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _changepassword() async {
    final String password = _passwordController.text;
    final String cpassword = _cpasswordController.text;

    if (password.isEmpty || cpassword.isEmpty) {
      setState(() {
        _passwordErrorText = password.isEmpty ? 'Password is required' : null;
        _cpasswordErrorText =
            cpassword.isEmpty ? 'Confirm Password is required' : null;
      });
      return;
    }
    if (password != cpassword) {
      setState(() {
        _cpasswordErrorText = 'Passwords do not match';
      });
      return;
    } else {
      setState(() {
        _cpasswordErrorText =
            null; // Clear error message for confirm password field
      });
    }
    setState(() {
      _passwordErrorText = null;
      _cpasswordErrorText = null;
    });

    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/changepassword?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'newpassword': password,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      _showSuccessPopup(message);
      // You can navigate to another screen after successful registration if needed
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      _showPermissionDeniedPopup(errorMessage);
    }
  }

  void _showSuccessPopup(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
          Navigator.pop(context);
        });
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text(
            'Success',
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
              Text(msg),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDeniedPopup(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 4), () {
          Navigator.of(context).pop();
        });
        return AlertDialog(
          title: const Text(
            'Error',
            textAlign: TextAlign.center,
          ),
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
              Text(msg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
              top: -20,
              child: Container(
                width: 60,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
              )),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            //  height: MediaQuery.of(context).size.height * 1 / 2,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Change Password',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 15),
                  child: Column(children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObserve,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        labelText: 'New Password',
                        errorText: _passwordErrorText,
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 5),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 1, 116, 5),
                                width: 3)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObserve
                              ? Icons.visibility
                              : Icons
                                  .visibility_off), // Toggle icon based on _obscureText
                          onPressed: () {
                            setState(() {
                              // Toggle password visibility
                              _isObserve = !_isObserve;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextField(
                      controller: _cpasswordController,
                      obscureText: _isObserve,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        labelText: 'Confirm Password',
                        errorText: _cpasswordErrorText,
                        labelStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 5),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 1, 116, 5),
                                width: 3)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObserve
                              ? Icons.visibility
                              : Icons
                                  .visibility_off), // Toggle icon based on _obscureText
                          onPressed: () {
                            setState(() {
                              // Toggle password visibility
                              _isObserve = !_isObserve;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changepassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 105, 243, 110),
                        padding: const EdgeInsets.only(right: 55, left: 55),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]);
  }
}
