import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isObserve = true;
  String? _usernameErrorText;
  String? _passwordErrorText;
  String? _cpasswordErrorText;
  String? _emailErrorText;
  String? _nameErrorText;

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String name = _nameController.text;
    final String cpassword = _cpasswordController.text;
    if (username.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        name.isEmpty ||
        cpassword.isEmpty) {
      setState(() {
        _usernameErrorText = username.isEmpty ? 'Username is required' : null;
        _passwordErrorText = password.isEmpty ? 'Password is required' : null;
        _emailErrorText = email.isEmpty ? 'Email is required' : null;
        _nameErrorText = name.isEmpty ? 'Name is required' : null;
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
      _usernameErrorText = null;
      _passwordErrorText = null;
      _cpasswordErrorText = null;
      _emailErrorText = null;
      _nameErrorText = null;
    });

    final response = await http.post(
      Uri.parse('https://trackwise.pasiyaprogramming.live/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'email': email,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500)),
      );
      await Future.delayed(const Duration(milliseconds: 1000), () {});
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
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
            Column(children: [
              Image.asset(
                'assets/images/Add_user.png',
                height: 250,
              ),
            ]),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'Register',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.abc),
                        labelText: 'Name',
                        errorText: _nameErrorText,
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
                                width: 3))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.people_alt_outlined),
                        labelText: 'Username',
                        errorText: _usernameErrorText,
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
                                width: 3))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: 'Email',
                        errorText: _emailErrorText,
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
                                width: 3))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObserve,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      labelText: 'Password',
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
                              color: Color.fromARGB(255, 1, 116, 5), width: 3)),
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
                              color: Color.fromARGB(255, 1, 116, 5), width: 3)),
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 105, 243, 110),
                padding: const EdgeInsets.only(right: 55, left: 55),
              ),
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
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
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Login Here',
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
          ],
        ),
      ),
    );
  }
}
