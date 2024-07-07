import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/card_desing.dart';
import '../widgets/image_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _userId = '';
  String _name = '';
  String currentTime = '';
  String greeting = '';
  bool _isTripNow = false;
  @override
  void initState() {
    super.initState();
    _fetchUserId();

    updateTime();
  }

//int userid

  Future<void> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    final bool istrip = prefs.getBool('trip') ?? false;
    setState(() {
      _userId = userId;
      _isTripNow = istrip;
      _fetchuserDetails(_userId);
    });
  }

  Future<void> _fetchuserDetails(String userid) async {
    try {
      final response = await http.get(Uri.parse(
          'https://trackwise.pasiyaprogramming.live/getdetails?userid=$userid'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String name = data['name'] ?? '';
        setState(() {
          _name = name;
          print(_name);
        });
      } else {
        print('Error get data: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch data error: $e');
    }
  }

  void updateTime() {
    setState(() {
      currentTime = _getCurrentTime();
    });
    Future.delayed(const Duration(seconds: 1), updateTime);
  }

  String _getCurrentTime() {
    DateTime now = DateTime.now();
    String period = now.hour < 12 ? 'AM' : 'PM';
    int hour = now.hour > 12 ? now.hour - 12 : now.hour;
    hour = hour == 0 ? 12 : hour;
    String formattedHours = hour.toString().padLeft(2, '0');
    String formattedMinute = now.minute.toString().padLeft(2, '0');
    String formattedSeconds = now.second.toString().padLeft(2, '0');
    if (now.hour >= 6 && now.hour < 12) {
      setState(() {
        greeting = 'Good Morning,';
      });
    } else if (now.hour >= 12 && now.hour < 17) {
      setState(() {
        greeting = 'Good Afternoon,';
      });
    } else if (now.hour >= 17 && now.hour < 20) {
      setState(() {
        greeting = 'Good Evening,';
      });
    } else {
      setState(() {
        greeting = 'Good Night,';
      });
    }

    return "$formattedHours:$formattedMinute:$formattedSeconds $period";
  }

  @override
  Widget build(BuildContext context) {
    String datew = DateFormat("EEEE").format(DateTime.now());
    String cdate = DateFormat("dd/MM/yyyy").format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 0,
                    child: Image.asset("assets/circle.png", height: 150)),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    "Today is $datew\n $cdate \n $currentTime",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ImageCard(
                  imagePath: 'assets/images/train.jpg',
                  text: _name,
                  greeting: greeting,
                  textAlignment: Alignment.topCenter,
                  onTap: () {
                    print('Image tapped!');
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            Visibility(
                visible: _isTripNow,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    width: 300,
                    height: 70,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/location');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.train_sharp,
                                color: Colors.white,
                                size: 38,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "You have a trip ongoing",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                children: [
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: <Widget>[
                      DashboardCard(
                          iconData: Icons.train_outlined,
                          title: 'Book Seat',
                          subtitle: 'Book your seats here',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.pushNamed(context, '/ticketbook');
                          }),
                      DashboardCard(
                          iconData: Icons.money,
                          title: 'Transactions',
                          subtitle: 'Your transactions',
                          color: const Color.fromARGB(255, 68, 219, 73),
                          onTap: () {
                            Navigator.pushNamed(context, '/transactions');
                          }),
                      DashboardCard(
                          iconData: Icons.report,
                          title: 'Misplaced Items',
                          subtitle: 'Report your missing items',
                          color: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, '/reportmissing');
                          }),
                      DashboardCard(
                          iconData: Icons.verified_user,
                          title: 'Account Management',
                          subtitle: 'Manage your account',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, '/manageacc');
                          }),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
