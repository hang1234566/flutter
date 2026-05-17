import 'package:flutter/material.dart';

import 'bookings_page.dart';
import 'cancel_booking_page.dart';
import 'contact_page.dart';
import 'flights_page.dart';
import 'help_page.dart';
import 'home_page.dart';

class FlightsShell extends StatefulWidget {
  const FlightsShell({super.key});

  @override
  State<FlightsShell> createState() => _FlightsShellState();
}

class _FlightsShellState extends State<FlightsShell> {
  int _index = 0;

  late final List<Widget> _tabs = [
    const FlightsPage(embedded: true),
    const BookingsPage(embedded: true),
    const CancelBookingPage(embedded: true),
    const HomePage(embedded: true),
    const ContactPage(embedded: true),
    const HelpPage(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: const Color(0xFF00A884).withValues(alpha: 0.15),
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm vé'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), label: 'Vé'),
          NavigationDestination(icon: Icon(Icons.cancel_outlined), label: 'Hủy'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'ST23'),
          NavigationDestination(icon: Icon(Icons.headset_mic_outlined), label: 'Liên hệ'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'Trợ giúp'),
        ],
      ),
    );
  }
}
