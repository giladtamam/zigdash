import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';

class DashboardsPlaceholder extends StatelessWidget {
  const DashboardsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navDashboards)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.dashPlaceholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
