import 'package:drift/drift.dart';

import 'connections.dart';

/// What a shortcut controls (CONTEXT.md: Shortcut).
enum ShortcutKind { device, scene, group }

/// Where a shortcut lives. Device Controls need no row: Android asks the app
/// for every device and the user picks in Android's own screen.
enum ShortcutSurface { widget, tile }

/// One home-screen widget or Quick Settings tile slot, tied to one Home
/// (docs/design/roadmap-post-2.0.md, 2.1 §2–5). [targets] is a JSON array:
/// one IEEE address for a device, a scene id for a scene, or up to five IEEE
/// addresses for a group (kept here, so editing a dashboard can't break it).
class Shortcuts extends Table {
  TextColumn get id => text()();
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ShortcutKind>()();
  TextColumn get surface => textEnum<ShortcutSurface>()();
  TextColumn get targets => text()();

  /// A group's name, shown as the widget's title.
  TextColumn get title => text().nullable()();

  /// The launcher's id for a widget; null for a tile.
  IntColumn get appWidgetId => integer().nullable().unique()();

  /// Which of ZigDash's fixed tile slots; null for a widget.
  IntColumn get tileSlot => integer().nullable().unique()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
