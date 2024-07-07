import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ticketbook extends StatefulWidget {
  const Ticketbook({super.key});

  @override
  State<Ticketbook> createState() => _TicketbookState();
}

class _TicketbookState extends State<Ticketbook> {
  List<String> locations = [];
  String? selectedPickupLocation;
  String? selectedDestination;
  String? selectedRows;
  String? selectedSeat;
  String? selectedClass;
  bool selectedClassError = false;
  bool selectedSeatError = false;
  bool selectedRowError = false;
  bool selectedPickupError = false;
  bool selectedDestError = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    fetchLocations();
    _initializeSharedPreferences();
  }

  Future<void> fetchLocations() async {
    final response = await http.get(
        Uri.parse('https://trackwise.pasiyaprogramming.live/getlocations'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        locations = data.map((location) => location.toString()).toList();
      });
    } else {
      throw Exception('Failed to load locations');
    }
  }

  final List<String> seatRows = [
    'R1',
    'R2',
  ];
  final List<String> seatNumbers = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10'
  ];
  final List<String> classes = [
    'First',
    'Second',
    'Third',
  ];

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _sendSeatDB() async {
    if (selectedClass != null &&
        selectedSeat != null &&
        selectedRows != null &&
        selectedPickupLocation != null &&
        selectedDestination != null) {
      _prefs.setString('selectedClass', selectedClass!);
      _prefs.setString('selectedSeat', selectedSeat!);
      _prefs.setString('selectedRow', selectedRows!);
      _prefs.setString('selectedPickup', selectedPickupLocation!);
      _prefs.setString('selectedDestination', selectedDestination!);
      Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacementNamed(context, '/invoice');
    } else {
      setState(() {
        selectedClassError = selectedClass == null;
        selectedSeatError = selectedSeat == null;
        selectedRowError = selectedRows == null;
        selectedPickupError = selectedPickupLocation == null;
        selectedDestError = selectedDestination == null;
      });

      if (selectedClassError &&
          selectedSeatError &&
          selectedRowError &&
          selectedPickupError &&
          selectedDestError) {
        String message = "Please choose your selections to your trip";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      } else if (selectedClassError) {
        String message = "Please choose your Class";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      } else if (selectedSeatError) {
        String message = "Please choose your Seat Number";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      } else if (selectedRowError) {
        String message = "Please choose your Seat Row";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      } else if (selectedPickupError) {
        String message = "Please choose your pickup location";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      } else if (selectedDestError) {
        String message = "Please choose your destination";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
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
                  "assets/images/Booking.png",
                  height: 250,
                ),
                const Text(
                  "Book Seat From Here",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  width: 350,
                  padding: const EdgeInsets.only(top: 15, bottom: 15, left: 25),
                  child: Table(
                    children: [
                      TableRow(
                        children: <Widget>[
                          const Text(
                            "Class",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 30,
                            width: 20,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedClass,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedClass = newValue;
                                          selectedClassError = false;
                                        });
                                      },
                                      items: classes
                                          .map<DropdownMenuItem<String>>(
                                              (String srvalue) {
                                        return DropdownMenuItem<String>(
                                          value: srvalue,
                                          child: Text(
                                            srvalue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      icon: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const TableRow(children: [
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                      TableRow(
                        children: <Widget>[
                          const Text(
                            "Seat Row",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 30,
                            width: 20,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedRows,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedRows = newValue;
                                          selectedRowError = false;
                                        });
                                      },
                                      items: seatRows
                                          .map<DropdownMenuItem<String>>(
                                              (String srvalue) {
                                        return DropdownMenuItem<String>(
                                          value: srvalue,
                                          child: Text(
                                            srvalue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      icon: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const TableRow(children: [
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                      TableRow(
                        children: <Widget>[
                          const Text(
                            "Seat Number",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 30,
                            width: 200,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedSeat,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedSeat = newValue;
                                          selectedSeatError = false;
                                        });
                                      },
                                      items: seatNumbers
                                          .map<DropdownMenuItem<String>>(
                                              (String snvalue) {
                                        return DropdownMenuItem<String>(
                                          value: snvalue,
                                          child: Text(
                                            snvalue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      icon: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const TableRow(children: [
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                      TableRow(
                        children: <Widget>[
                          const Text(
                            "From",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 30,
                            width: 200,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedPickupLocation,
                                      onChanged: (String? pickupValue) {
                                        setState(() {
                                          selectedPickupLocation = pickupValue;
                                          selectedPickupError = false;
                                        });
                                      },
                                      items: locations
                                          .map<DropdownMenuItem<String>>(
                                              (String pkvalue) {
                                        return DropdownMenuItem<String>(
                                          value: pkvalue,
                                          child: Text(
                                            pkvalue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      icon: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const TableRow(children: [
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 15,
                        )
                      ]),
                      TableRow(
                        children: <Widget>[
                          const Text(
                            "To",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 200,
                            height: 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145)),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedDestination,
                                      onChanged: (String? destinationValue) {
                                        setState(() {
                                          selectedDestination =
                                              destinationValue;
                                          selectedDestError = false;
                                        });
                                      },
                                      items: locations
                                          .map<DropdownMenuItem<String>>(
                                              (String devalue) {
                                        return DropdownMenuItem<String>(
                                          value: devalue,
                                          child: Text(
                                            devalue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      icon: null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 37, 37),
                        padding: const EdgeInsets.only(right: 55, left: 55),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: _sendSeatDB,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 79, 235, 84),
                        padding: const EdgeInsets.only(right: 55, left: 55),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
