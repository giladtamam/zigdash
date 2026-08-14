import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zigdash/features/panels/widgets/panel_reliability_frame.dart';
import 'package:zigdash/l10n/app_localizations.dart';

Widget _wrap({
  required bool stale,
  required bool controlsEnabled,
  String? valueLabel,
  VoidCallback? onLongPress,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: GestureDetector(
          onLongPress: onLongPress,
          child: PanelReliabilityFrame(
            stale: stale,
            controlsEnabled: controlsEnabled,
            valueLabel: valueLabel,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Control'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  Finder inFrame(Type type) => find.descendant(
    of: find.byType(PanelReliabilityFrame),
    matching: find.byType(type),
  );

  testWidgets('stale frame blocks its child but preserves outer long press', (
    tester,
  ) async {
    var longPressed = false;
    await tester.pumpWidget(
      _wrap(
        stale: true,
        controlsEnabled: false,
        onLongPress: () => longPressed = true,
      ),
    );

    expect(find.text('Last known'), findsOneWidget);
    expect(
      tester.widget<AbsorbPointer>(inFrame(AbsorbPointer).first).absorbing,
      isTrue,
    );
    await tester.longPress(find.byType(PanelReliabilityFrame));
    expect(longPressed, isTrue);
  });

  testWidgets(
    'fresh frame leaves controls enabled and has no stale treatment',
    (tester) async {
      await tester.pumpWidget(_wrap(stale: false, controlsEnabled: true));

      expect(find.text('Last known'), findsNothing);
      expect(
        tester.widget<AbsorbPointer>(inFrame(AbsorbPointer).first).absorbing,
        isFalse,
      );
      expect(
        tester.widget<AnimatedOpacity>(inFrame(AnimatedOpacity)).opacity,
        1,
      );
    },
  );

  testWidgets('read-only stale frame stays enabled while showing stale state', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(stale: true, controlsEnabled: true));

    expect(find.text('Last known'), findsOneWidget);
    expect(
      tester.widget<AbsorbPointer>(inFrame(AbsorbPointer).first).absorbing,
      isFalse,
    );
  });

  testWidgets('semantics announce stale value and unavailable controls', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(stale: true, controlsEnabled: false, valueLabel: '72 percent'),
    );

    expect(
      tester.getSemantics(find.byType(PanelReliabilityFrame)).label,
      contains('Last known'),
    );
    expect(
      tester.getSemantics(find.byType(PanelReliabilityFrame)).label,
      contains('72 percent'),
    );
    expect(
      tester.getSemantics(find.byType(PanelReliabilityFrame)).label,
      contains('Controls unavailable'),
    );
    semantics.dispose();
  });

  testWidgets('RTL positions stale chip at the logical trailing edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        stale: true,
        controlsEnabled: true,
        textDirection: TextDirection.rtl,
      ),
    );

    final chipCenter = tester.getCenter(find.text('Last known'));
    final frameCenter = tester.getCenter(find.byType(PanelReliabilityFrame));
    expect(chipCenter.dx, lessThan(frameCenter.dx));
  });
}
