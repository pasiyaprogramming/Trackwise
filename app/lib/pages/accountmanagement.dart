import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../controllers/provider.dart';
import '../widgets/changepass.dart';

class Accountmanagement extends StatefulWidget {
  const Accountmanagement({super.key});

  @override
  State<Accountmanagement> createState() => _AccountmanagementState();
}

class _AccountmanagementState extends State<Accountmanagement> {
  String _userId = '';
  String _name = '';
  String _username = '';
  String _email = '';
  final namecontroller = TextEditingController();
  final usernamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  bool _isEditingname = false;
  bool _isEditingemail = false;
  final passwordcontroller = TextEditingController();

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
      _fetchuserDetails(_userId);
    });
  }

  Future<void> _fetchuserDetails(String userid) async {
    final response = await http.get(Uri.parse(
        'https://trackwise.pasiyaprogramming.live/getdetails?userid=$userid'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String name = data['name'] ?? '';
      final String username = data['username'] ?? '';
      final String email = data['email'] ?? '';
      setState(() {
        _name = name;
        _username = username;
        _email = email;
        namecontroller.text = _name;
        usernamecontroller.text = _username;
        emailcontroller.text = _email;
      });
    } else {
      print('Error get data: ${response.statusCode}');
    }
  }

  Future<void> _deleteaccount() async {
    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/deleteaccount?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  void _updateName(String name) async {
    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/changeuserdetails?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      _fetchuserDetails(_userId);
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateEmail(String email) async {
    final response = await http.post(
      Uri.parse(
          'https://trackwise.pasiyaprogramming.live/changeuserdetails?userid=$_userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String message = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      _fetchuserDetails(_userId);
    } else {
      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage = data['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteaccountPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirmation', textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 55,
                color: Colors.orange,
              ),
              SizedBox(
                height: 10,
              ),
              Text('Are you sure to delete your account'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteaccount();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      flex: 0,
                      child: Stack(
                        children: [
                          Image.asset("assets/circle.png", width: 150),
                          Padding(
                            padding: const EdgeInsets.only(top: 66, left: 1),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');
                                  //Navigator.pushReplacementNamed(context, '/information');
                                },
                                iconSize: 35,
                                icon: const Icon(Icons.arrow_back)),
                          )
                        ],
                      )),
                  Expanded(
                      flex: 3,
                      child: Text(
                        'Hello! $_name',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            color: Colors.black),
                      )),
                  Expanded(
                      child: IconButton(
                          onPressed: () {
                            // _logout(context);
                            Provider.of<AuthProvider>(context, listen: false)
                                .logout(context);
                          },
                          iconSize: 30,
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ))),
                ],
              ),
              Column(
                children: [
                  Image.asset(
                    'assets/images/Profile.png',
                    height: 250,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Account Management",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 15),
                child: Column(children: [
                  TextField(
                    controller: usernamecontroller,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 1, 116, 5), width: 3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: namecontroller,
                    readOnly: !_isEditingname,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.black),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingname = !_isEditingname;
                            if (!_isEditingname) {
                              _updateName(namecontroller.text);
                            }
                          });
                        },
                        child: Icon(_isEditingname ? Icons.save : Icons.edit),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 1, 116, 5), width: 3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailcontroller,
                    readOnly: !_isEditingemail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingemail = !_isEditingemail;
                            if (!_isEditingemail) {
                              _updateEmail(emailcontroller.text);
                            }
                          });
                        },
                        child: Icon(_isEditingemail ? Icons.save : Icons.edit),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 1, 116, 5), width: 3),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Account Actions',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                // ignore: prefer_const_constructors
                                return Wrap(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: const changepasswordbt(),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 105, 243, 110),
                          padding: const EdgeInsets.only(right: 21, left: 21),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _deleteaccountPopup();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 0, 0),
                          padding: const EdgeInsets.only(right: 30, left: 30),
                        ),
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
