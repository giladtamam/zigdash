import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/l10n/l10n_ext.dart';

/// Renders the bundled user guide (docs/USER_GUIDE.md) as scrollable Markdown.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsHelp)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('docs/USER_GUIDE.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(16),
          );
        },
      ),
    );
  }
}
