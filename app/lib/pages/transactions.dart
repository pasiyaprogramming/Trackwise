import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  String _userId = '';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    setState(() {
      _userId = userId;
      _paymentDetails();
    });
  }

  //int userid
  Future<List<Map<String, dynamic>>> _paymentDetails() async {
    final response = await http.get(Uri.parse(
        'https://trackwise.pasiyaprogramming.live/getpaymentdetails?userid=$_userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
          data.map((dynamic item) => item as Map<String, dynamic>));
    } else {
      throw Exception('No data found');
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
            Column(
              children: [
                Image.asset(
                  "assets/images/Investing.png",
                  height: 250,
                ),
                const Text(
                  "Your Transactions",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _paymentDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No data available'),
                        );
                      } else {
                        return DataTable(
                          columnSpacing: 18,
                          dividerThickness: 0,
                          showBottomBorder: false,
                          columns: const [
                            DataColumn(label: Text('Transaction ID')),
                            DataColumn(
                                label: Text(
                                  'Date',
                                ),
                                tooltip: "Date"),
                            DataColumn(label: Text('Amount')),
                          ],
                          rows: snapshot.data!
                              .map<DataRow>((Map<String, dynamic> item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['transaction_id'])),
                                DataCell(Text(item['date'])),
                                DataCell(Text(item['amount'])),
                              ],
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
