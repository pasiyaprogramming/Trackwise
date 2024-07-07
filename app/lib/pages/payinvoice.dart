import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:track_wise/widgets/pay.dart';

class payinvoice extends StatefulWidget {
  const payinvoice({super.key});

  @override
  State<payinvoice> createState() => _payinvoiceState();
}

class _payinvoiceState extends State<payinvoice> {
  String selectedClass = '';
  String selectedRows = '';
  String selectedSeat = '';
  String selectedPickupLocation = '';
  String selectedDestination = '';
  String _userId = '';
  String _price = '';
  late SharedPreferences _prefs;
  List<String> price = ['5.00', '10.00', '15.00', '20.00', '25.00', '30.00'];

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
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
    Random random = Random();
    int randomIndex = random.nextInt(price.length);
    String pricerandom = price[randomIndex];
    _prefs.setString('price', pricerandom);
    setState(() {
      _userId = userId;
      selectedClass = sclass;
      selectedRows = srow;
      selectedSeat = sseat;
      selectedPickupLocation = spklocation;
      selectedDestination = sdlocation;
      _price = pricerandom;
    });
  }

  Future<void> _deleteSave() async {
    await _prefs.remove('selectedClass');
    await _prefs.remove('selectedRow');
    await _prefs.remove('selectedSeat');
    await _prefs.remove('selectedPickup');
    await _prefs.remove('price');
    await Future.delayed(const Duration(milliseconds: 100));
    Navigator.pushReplacementNamed(context, '/ticketbook');
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
                  'assets/images/Receipt.png',
                  height: 250,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Confirm your booking",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    width: 280,
                    child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: <Widget>[
                          const TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Selected Class",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              selectedClass,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ]),
                        TableRow(children: <Widget>[
                          const TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Selected Seat Row",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              selectedRows,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ]),
                        TableRow(
                          children: <Widget>[
                            const TableCell(
                                child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Selected Seat Number",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )),
                            TableCell(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                selectedSeat,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            )),
                          ],
                        ),
                        TableRow(children: <Widget>[
                          const TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "From",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              selectedPickupLocation,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ]),
                        TableRow(children: <Widget>[
                          const TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "To",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              selectedDestination,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ]),
                        TableRow(children: <Widget>[
                          const TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Price",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _price,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _deleteSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 253, 37, 37),
                      padding: const EdgeInsets.only(right: 45, left: 45),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    )),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PaypalCheckout(price: _price)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 79, 235, 84),
                      padding: const EdgeInsets.only(right: 55, left: 55),
                    ),
                    child: const Text(
                      "Pay",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
