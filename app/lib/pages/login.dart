// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObserve = true;
  String? _usernameErrorText;
  String? _passwordErrorText;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    //final String deviceId = 'YourDeviceId'; // Get the device ID

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _usernameErrorText = username.isEmpty ? 'Username is required' : null;
        _passwordErrorText = password.isEmpty ? 'Password is required' : null;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://trackwise.pasiyaprogramming.live/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String token = data['token'];
      final decodedToken = JwtDecoder.decode(token);
      final String userId = decodedToken['userId'];
      _prefs.setString('userId', userId);
      _prefs.setString('token', token);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      _snakbaresp(message);
    }
  }

  void _snakbaresp(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      ),
      duration: const Duration(seconds: 5), // Set duration to a longer period
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                Image.asset(
                  'assets/images/Mobile_login.png',
                  height: 250,
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 25, fontFamily: 'Poppins'),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, top: 15),
                    child: Column(children: <Widget>[
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.people_alt_outlined),
                            labelText: 'Username or Email',
                            labelStyle: const TextStyle(color: Colors.black),
                            errorText: _usernameErrorText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 5),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 1, 116, 5),
                                    width: 3))),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObserve,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.black),
                          labelText: 'Password',
                          errorText: _passwordErrorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide:
                                const BorderSide(color: Colors.green, width: 5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 1, 116, 5),
                                width: 3),
                          ),
                          prefixIcon: const Icon(Icons.password),
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
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 105, 243, 110),
                          padding: const EdgeInsets.only(right: 55, left: 55),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don`t have an account ',
                            style: TextStyle(fontSize: 15),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/register');
                            },
                            child: const Text(
                              'Register Here',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 76, 0, 255)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
