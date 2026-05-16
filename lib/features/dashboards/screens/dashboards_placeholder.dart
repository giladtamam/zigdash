import 'package:flutter/material.dart';

class DashboardsPlaceholder extends StatelessWidget {
  const DashboardsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboards')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Open a broker from the Brokers tab to see and manage its dashboards.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
