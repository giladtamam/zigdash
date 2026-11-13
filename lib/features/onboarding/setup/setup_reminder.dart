import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../alerts/alert_push.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/l10n/l10n_ext.dart';

/// Which reminder (3.4): setup stopped and can be tried again tomorrow
/// (2.9.7), or no hub yet, so a week later, when it may have arrived.
enum ReminderKind { setup, hub }

/// "Remind me tomorrow" where setup stops (2.9.7): one local notification a
/// day later, cancelled once setup finishes. Scheduled on the phone (Android's
/// alarm, or iOS's own notification schedule); nothing leaves it. From 3.4
/// also "Remind me in a week" on the "Nothing yet" screen ([ReminderKind.hub]).
abstract class SetupReminder {
  /// Asks for notification permission if needed, then schedules the
  /// reminder. False when the phone said no.
  Future<bool> schedule(Locale locale, {ReminderKind kind = ReminderKind.setup});

  /// Setup finished: the reminder has nothing left to say.
  Future<void> cancel();

  /// Whether this start of the app came from tapping the reminder.
  Future<bool> openedFromReminder();
}

class LocalSetupReminder implements SetupReminder {
  static const _id = 7001;
  static const _channel = 'reminders';
  static const _payload = 'setup_reminder';
  final _notes = FlutterLocalNotificationsPlugin();

  /// On iOS nothing else sets the plugin up (alerts are Android-only for
  /// now, docs/design/ios.md), and permission is asked at the tap.
  static bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get _available => AlertPush.available || _ios;
  static bool _iosReady = false;

  Future<void> _initIos() async {
    if (!_ios || _iosReady) return;
    _iosReady = true;
    await _notes.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> _askPermission() async {
    if (!_ios) return AlertPush.askPermission();
    await _initIos();
    final ios = _notes.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<bool> schedule(Locale locale, {ReminderKind kind = ReminderKind.setup}) async {
    if (!_available) return false;
    if (!await _askPermission()) return false;
    final l10n = appL10n(locale);
    final android = _notes
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        _channel,
        l10n.reminderChannel,
        importance: Importance.defaultImportance,
      ),
    );
    final hub = kind == ReminderKind.hub;
    await _notes.zonedSchedule(
      id: _id,
      title: hub ? l10n.reminderHubTitle : l10n.reminderTitle,
      body: hub ? l10n.reminderHubBody : l10n.reminderBody,
      // A day from now, or a week for a hub still on its way. UTC needs no
      // time-zone database, and a delay means the same in every zone.
      scheduledDate: tz.TZDateTime.now(
        tz.UTC,
      ).add(Duration(days: hub ? 7 : 1)),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel,
          l10n.reminderChannel,
          icon: 'ic_shortcut_tile',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Inexact: no exact-alarm permission, and a few minutes either way
      // don't matter a day later.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: _payload,
    );
    return true;
  }

  @override
  Future<void> cancel() async {
    if (!_available) return;
    try {
      await _initIos();
      await _notes.cancel(id: _id);
    } catch (_) {}
  }

  @override
  Future<bool> openedFromReminder() async {
    if (!_available) return false;
    try {
      await _initIos();
      final d = await _notes.getNotificationAppLaunchDetails();
      return (d?.didNotificationLaunchApp ?? false) &&
          d?.notificationResponse?.payload == _payload;
    } catch (_) {
      return false;
    }
  }
}

final setupReminderProvider = Provider<SetupReminder>(
  (ref) => LocalSetupReminder(),
);

/// The "Remind me tomorrow" button, and what happened once tapped. With
/// [ReminderKind.hub], "Remind me in a week" (3.4); [onTapped] lets the
/// screen count it its own way instead of as [SetupStepKind.remindLater].
class RemindMeLater extends ConsumerStatefulWidget {
  const RemindMeLater({super.key, this.kind = ReminderKind.setup, this.onTapped});
  final ReminderKind kind;
  final VoidCallback? onTapped;

  @override
  ConsumerState<RemindMeLater> createState() => _RemindMeLaterState();
}

class _RemindMeLaterState extends ConsumerState<RemindMeLater> {
  bool? _set;

  Future<void> _remind() async {
    if (widget.onTapped case final tapped?) {
      tapped();
    } else {
      ref
          .read(analyticsProvider)
          .track(const SetupStep(SetupStepKind.remindLater));
    }
    final ok = await ref
        .read(setupReminderProvider)
        .schedule(Localizations.localeOf(context), kind: widget.kind);
    if (mounted) setState(() => _set = ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hub = widget.kind == ReminderKind.hub;
    final set = _set;
    if (set == null) {
      return TextButton.icon(
        onPressed: _remind,
        icon: const Icon(Icons.notifications_none),
        label: Text(hub ? l10n.noHubRemind : l10n.reminderButton),
      );
    }
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          set
              ? (hub ? l10n.noHubRemindSet : l10n.reminderSet)
              : defaultTargetPlatform == TargetPlatform.iOS
                  ? l10n.reminderNoPermissionIos
                  : l10n.reminderNoPermission,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
