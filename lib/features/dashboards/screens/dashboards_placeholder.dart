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
            'Dashboards arrive in Phase 4.\nFirst add a Connection to a broker.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
