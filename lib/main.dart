import 'package:flutter/material.dart';
// import 'pages/signin_page.dart'; // SignInPage referenced by onboarding
import 'pages/onboarding_page.dart';
import 'theme.dart';

void main() => runApp(const UdaApp());

class UdaApp extends StatelessWidget {
  const UdaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OnboardingPage(),
    );
  }
}