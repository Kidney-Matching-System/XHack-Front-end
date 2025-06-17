import 'package:flutter/material.dart';
import 'package:webxhack/screens/AdminScreens/admin_dashboard.dart';
import 'package:webxhack/screens/AuthScreens/otp_screen.dart';
import 'package:webxhack/screens/AuthScreens/reset_password_screen.dart';
import 'package:webxhack/screens/DoctorScreens/council_screen.dart';
import 'package:webxhack/screens/DoctorScreens/matching_system_screen.dart';
import 'package:webxhack/screens/DoctorScreens/oragn-patients-screen.dart';
import 'screens/AuthScreens/login_screen.dart';
import 'screens/AuthScreens/forget_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 🔐 Required for async plugins

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/matching-page',
      routes: {
        '/': (context) => const LoginScreen(),
        '/forgot-password': (context) => ForgetPasswordScreen(),
        '/verify-otp': (context) => const OtpScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/matching-page': (context) => const OrganMatchingPage(),
        '/organs-patients-Page': (context) => const DashboardDoctor(),
        '/med-council': (context) => const MedicalCouncilScreen(doctorId: ''),
        '/admin-dash': (context) => const AdminDashboard(),

      },
    );
  }
}
