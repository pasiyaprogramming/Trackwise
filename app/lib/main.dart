import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_wise/pages/location.dart';
import 'package:track_wise/pages/accountmanagement.dart';
import 'package:track_wise/pages/dashboard.dart';
import 'package:track_wise/pages/login.dart';
import 'package:track_wise/pages/payinvoice.dart';
import 'package:track_wise/pages/register.dart';
import 'package:track_wise/pages/splashscreen.dart';
import 'package:track_wise/pages/transactions.dart';

import 'controllers/provider.dart';
import 'pages/about_us.dart';
import 'pages/report_missing_tool_page.dart';
import 'pages/ticket_book.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AuthProvider(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Internetcheck(),
      routes: {
        '/ticketbook': (context) => const Ticketbook(),
        '/aboutus': (context) => const AboutUsPage(),
        '/transactions': (context) => const Transactions(),
        '/dashboard': (context) => const Dashboard(),
        '/location': (context) => const map(),
        '/reportmissing': (context) => ReportMissingToolPage(),
        '/invoice': (context) => const payinvoice(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/manageacc': (context) => const Accountmanagement(),
      },
    );
  }
}
