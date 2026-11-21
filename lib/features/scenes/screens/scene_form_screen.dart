import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/material_icon.dart';
import '../../devices/devices_providers.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../../panels/models/panel_config.dart';
import '../../panels/providers/panel_value_provider.dart';
import '../all_shutters.dart' show shutterListTimeout;
import '../models/scene.dart';
import '../scene_capture.dart';
import '../scenes_providers.dart';

const _swatches = <Color>[
  Color(0xFF3B82F6),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF10B981),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
];

const _icons = <IconData>[
  Icons.auto_awesome,
  Icons.movie,
  Icons.nightlight_round,
  Icons.wb_sunny,
  Icons.weekend,
  Icons.power_settings_new,
  Icons.celebration,
  Icons.local_cafe,
];

class SceneFormScreen extends ConsumerStatefulWidget {
  const SceneFormScreen({
    super.key,
    required this.connectionId,
    this.sceneId,
    this.onDone,
  });

  final String connectionId;
  final String? sceneId;

  /// Called after saving or closing instead of popping the route, when the
  /// form is the detail pane of list-detail.
  final VoidCallback? onDone;

  @override
  ConsumerState<SceneFormScreen> createState() => _State();
}

/// Where a stored or new action sits in the scene (3.8.7): a device row, an
/// own tile, kept as it was, or waiting for the device list.
enum _SlotKind { device, tile, kept, pending }

/// One place in the scene's action order. [key] is the device's friendly
/// name or the tile's panel id; [action] the stored action for kept and
/// pending places.
class _Slot {
  _Slot(this.kind, {this.key, this.action});

  _SlotKind kind;
  String? key;
  final SceneAction? action;
}

class _State extends ConsumerState<SceneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _baseController = TextEditingController(text: 'zigbee2mqtt');
  String _base = 'zigbee2mqtt';

  Color _color = _swatches.first;
  IconData _icon = _icons.first;
  // friendlyName -> the state values this scene will publish for that device.
  final Map<String, Map<String, dynamic>> _edits = {};
  // friendlyName -> the action as saved, until its controls change (3.8.7):
  // an untouched device saves its original payload string.
  final Map<String, SceneAction> _deviceOriginal = {};
  // panel id -> what the ticked own tile sends, and its control's value
  // (bool / number / option index / SceneCoverValue) (3.8.7).
  final Map<String, SceneAction> _tileActions = {};
  final Map<String, Object?> _tileValues = {};
  // The scene's actions in order: survivors where they were, new ones last.
  final List<_Slot> _slots = [];
  // The tiles the saved scene was matched against (edit only).
  SceneTiles? _loadedTiles;
  // The base the saved scene was read under; pending actions are under it.
  String _loadBase = 'zigbee2mqtt';
  // Pending `$base/…/set` actions get one pass, when the device list first
  // arrives (or fails): never again, whatever `_refresh` does.
  bool _pendingSettled = false;
  bool _loaded = false;
  bool _saving = false;
  bool _statesRequested = false;

  bool get _isEdit => widget.sceneId != null;

  @override
  void initState() {
    super.initState();
    _base = ref.read(homeBaseTopicProvider(widget.connectionId)) ?? _base;
    _baseController.text = _base;
    _loadBase = _base;
    if (_isEdit) {
      _load();
    } else {
      _pendingSettled = true;
      _loaded = true;
    }
  }

  /// Opens the scene as it was saved (3.8.7): the tiles are read first
  /// (directly, not through the autoDispose provider nothing watches yet),
  /// then each stored action claims one place. Actions outside the base go
  /// to a tile now; `$base/…/set` ones wait for the device list.
  Future<void> _load() async {
    final repo = ref.read(sceneRepoProvider);
    final readTiles = ref.read(sceneTilesLoaderProvider);
    final scene = await repo.getById(widget.sceneId!);
    SceneTiles tiles;
    try {
      tiles = await readTiles(widget.connectionId).timeout(shutterListTimeout);
    } catch (_) {
      tiles = SceneTiles.empty; // unmatched actions are kept, never lost
    }
    if (scene == null || !mounted) return;
    _name.text = scene.name;
    _color = Color(scene.colorSeed);
    _icon = materialIcon(scene.iconCodepoint);
    _loadedTiles = tiles;
    for (final a in SceneAction.decodeList(scene.actions)) {
      if (_isBaseSet(a.setTopic)) {
        _slots.add(_Slot(_SlotKind.pending, action: a));
      } else if (_claimTile(a, tiles.tiles) case final id?) {
        _slots.add(_Slot(_SlotKind.tile, key: id));
      } else {
        _slots.add(_Slot(_SlotKind.kept, action: a));
      }
    }
    setState(() => _loaded = true);
  }

  bool _isBaseSet(String topic) =>
      topic.startsWith('$_loadBase/') &&
      topic.endsWith('/set') &&
      topic.length > _loadBase.length + 5;

  /// Ticks the first unclaimed tile that publishes [a] exactly (topic and
  /// payload), keeping [a] as stored; its panel id, or null.
  String? _claimTile(SceneAction a, List<SceneTile> tiles) {
    for (final t in tiles) {
      if (t.publishTopic != a.setTopic || _tileActions.containsKey(t.panelId)) {
        continue;
      }
      final value = tileValueOf(t, a.payload);
      if (value == null) continue;
      _tileActions[t.panelId] = a;
      _tileValues[t.panelId] = value;
      return t.panelId;
    }
    return null;
  }

  /// The one pass over pending actions (3.8.7). With the device list: a
  /// device whose row could build the payload, else any tile, else kept.
  /// Without it (discovery failed): tiles only; the rest stay pending and
  /// are saved as they were.
  void _settlePending(List<Z2mDevice>? devices, List<SceneTile> tiles) {
    _pendingSettled = true;
    for (final s in _slots) {
      if (s.kind != _SlotKind.pending) continue;
      final a = s.action!;
      if (devices != null) {
        final name =
            a.setTopic.substring(_loadBase.length + 1, a.setTopic.length - 4);
        final d = devices.where((d) => d.friendlyName == name).firstOrNull;
        if (d != null && !_edits.containsKey(name)) {
          final map = deviceRowPayload(d, a.payload);
          if (map != null) {
            _edits[name] = map;
            _deviceOriginal[name] = a;
            s
              ..kind = _SlotKind.device
              ..key = name;
            continue;
          }
        }
      }
      if (_claimTile(a, tiles) case final id?) {
        s
          ..kind = _SlotKind.tile
          ..key = id;
      } else if (devices != null) {
        s.kind = _SlotKind.kept;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _baseController.dispose();
    super.dispose();
  }

  void _refresh() {
    final next = _baseController.text.trim();
    if (next.isEmpty) return;
    final args = (connectionId: widget.connectionId, base: next);
    ref.invalidate(discoveredDevicesProvider(args));
    ref.invalidate(deviceStatesProvider(args));
    setState(() {
      // Pending actions were stored under the load base: they settle only
      // on its device list (build checks `_base == _loadBase`), once; a
      // retry on the same base still settles them when it arrives (3.8.7).
      _base = next;
      _statesRequested = false; // re-pull state for the new base
    });
  }

  /// Pull current state once the device list is known. Z2M setups often don't
  /// retain state, so we publish a `/get` to each device and let the live
  /// subscription deliver fresh values.
  void _ensureStateRequested(List<Z2mDevice> devices) {
    if (_statesRequested || devices.isEmpty) return;
    _statesRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) requestDeviceStates(ref, widget.connectionId, _base, devices);
    });
  }

  static Map<String, dynamic>? _parseState(String? raw) {
    if (raw == null) return null;
    try {
      final d = jsonDecode(raw);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
    }
  }

  void _addSlot(_SlotKind kind, String key) {
    if (_slots.any((s) => s.kind == kind && s.key == key)) return;
    _slots.add(_Slot(kind, key: key));
  }

  /// Selects/deselects a device. On select, seeds its editable values from the
  /// device's current live state (or sensible defaults); devices with no typed
  /// controls fall back to capturing their settable state as-is.
  void _toggleDevice(Z2mDevice d, bool on, Map<String, String> states) {
    setState(() {
      _deviceOriginal.remove(d.friendlyName);
      if (!on) {
        _edits.remove(d.friendlyName);
        return;
      }
      final live = _parseState(states[d.friendlyName]);
      var seed = initialSceneEdits(d, live);
      if (seed.isEmpty && live != null) seed = captureSettableState(d, live);
      _edits[d.friendlyName] = seed;
      _addSlot(_SlotKind.device, d.friendlyName);
    });
  }

  /// Ticks/unticks an own tile (3.8.7). On tick the control starts from the
  /// tile's [live] value (copied once), else the defaults.
  void _toggleTile(SceneTile t, bool on, Object? live) {
    setState(() {
      if (!on) {
        _tileActions.remove(t.panelId);
        _tileValues.remove(t.panelId);
        return;
      }
      final value = tileSeedValue(t, live);
      final action = buildTileAction(t, value);
      if (action == null) return;
      _tileValues[t.panelId] = value;
      _tileActions[t.panelId] = action;
      _addSlot(_SlotKind.tile, t.panelId);
    });
  }

  void _setTileValue(SceneTile t, Object? value) {
    final action = buildTileAction(t, value);
    if (action == null) return;
    setState(() {
      _tileValues[t.panelId] = value;
      _tileActions[t.panelId] = action;
    });
  }

  SceneAction? _deviceAction(String name) =>
      _deviceOriginal[name] ??
      buildSceneAction(
          base: _base, friendlyName: name, settableState: _edits[name]!);

  /// What Save writes (3.8.7): every place in stored order (an untouched
  /// device or tile keeps its original string; kept and pending actions as
  /// they were), new ones last.
  List<SceneAction> _buildActions() {
    final out = <SceneAction>[];
    final devices = <String>{};
    final tiles = <String>{};
    for (final s in _slots) {
      switch (s.kind) {
        case _SlotKind.device:
          final name = s.key!;
          if (!_edits.containsKey(name) || !devices.add(name)) continue;
          if (_deviceAction(name) case final a?) out.add(a);
        case _SlotKind.tile:
          final id = s.key!;
          final a = _tileActions[id];
          if (a != null && tiles.add(id)) out.add(a);
        case _SlotKind.kept || _SlotKind.pending:
          out.add(s.action!);
      }
    }
    return out;
  }

  int get _keptCount => _slots
      .where((s) => s.kind == _SlotKind.kept || s.kind == _SlotKind.pending)
      .length;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final captured = _buildActions();

    // Something must be in the scene: a ticked device or tile, or an action
    // kept from before (3.8.7: the old "nothing ticked keeps all" is gone).
    if (_edits.isEmpty && _tileActions.isEmpty && _keptCount == 0) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.sceneFormNoDevicesSelected)));
      return;
    }
    if (captured.isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.sceneFormNothingCaptured)));
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(sceneRepoProvider);
    try {
      if (_isEdit) {
        await repo.update(
          id: widget.sceneId!,
          name: _name.text.trim(),
          iconCodepoint: _icon.codePoint,
          colorSeed: _color.toARGB32(),
          actions: captured,
        );
      } else {
        await repo.create(
          connectionId: widget.connectionId,
          name: _name.text.trim(),
          iconCodepoint: _icon.codePoint,
          colorSeed: _color.toARGB32(),
          actions: captured,
        );
        ref.read(analyticsProvider).track(const FeatureUsed(Feature.sceneCreated));
      }
      if (!mounted) return;
      final done = widget.onDone;
      done != null ? done() : context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final args = (connectionId: widget.connectionId, base: _base);
    final devicesAsync = ref.watch(discoveredDevicesProvider(args));
    final statesAsync = ref.watch(deviceStatesProvider(args));
    // valueOrNull: `value` rethrows once discovery gave up (8 s).
    final devices = devicesAsync.valueOrNull ?? const <Z2mDevice>[];
    final states = statesAsync.valueOrNull ?? const <String, String>{};
    // An edit uses the tiles it was opened with; a new scene reads them.
    final sceneTiles = _loadedTiles ??
        ref.watch(sceneTilesProvider(widget.connectionId)).valueOrNull ??
        SceneTiles.empty;
    final tiles = sceneTiles.tiles;

    if (!_pendingSettled && _base == _loadBase) {
      if (devicesAsync.hasError && !devicesAsync.isLoading) {
        _settlePending(null, tiles);
      } else if (devicesAsync.hasValue && !devicesAsync.isLoading) {
        _settlePending(devicesAsync.requireValue, tiles);
      }
    }

    _ensureStateRequested(devices);

    // Devices that can contribute to a scene: anything with settable controls.
    // Their live state may still be arriving (we pull it via `/get`).
    final capturable = [
      for (final d in devices)
        if (d.exposes.any((e) => e.isSettable)) d,
    ];
    final outline = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        );
    final kept = _keptCount;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onDone == null,
        leading: widget.onDone == null
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close),
                onPressed: widget.onDone,
              ),
        title: Text(_isEdit ? l10n.sceneFormEditTitle : l10n.sceneFormNewTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? l10n.saving : l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.sceneFormNameLabel),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            // Color swatches
            Wrap(
              spacing: 12,
              children: _swatches.map((c) {
                final sel = c.toARGB32() == _color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    radius: 18,
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Icon picker
            Wrap(
              spacing: 8,
              children: _icons.map((i) {
                final sel = i.codePoint == _icon.codePoint;
                return IconButton(
                  isSelected: sel,
                  onPressed: () => setState(() => _icon = i),
                  icon: Icon(i),
                  style: sel
                      ? IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer)
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.sceneFormDevicesHeader,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.retry,
                  onPressed: _refresh,
                ),
              ],
            ),
            Text(l10n.sceneFormCaptureHint, style: outline),
            // What the scene holds that no row shows (3.8.7): kept, or
            // waiting for the device list. Remove drops them on Save.
            if (kept > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sceneFormKeptActions(kept),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    TextButton(
                      key: const Key('scene-remove-kept'),
                      onPressed: () => setState(() => _slots.removeWhere((s) =>
                          s.kind == _SlotKind.kept ||
                          s.kind == _SlotKind.pending)),
                      child: Text(l10n.sceneFormRemoveKept),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (devicesAsync.isLoading && capturable.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (capturable.isEmpty && tiles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.sceneFormNoDevices),
              )
            else if (capturable.isNotEmpty) ...[
              Text(l10n.sceneFormSelectedCount(_edits.length),
                  style: Theme.of(context).textTheme.bodySmall),
              ...capturable.map((d) {
                final name = d.friendlyName;
                final selected = _edits.containsKey(name);
                final hasState = states.containsKey(name);
                // The name the user gave the device's tile (3.8.7).
                final tileName = sceneTiles.deviceNames[d.ieeeAddress];
                final title = tileName != null && tileName != name
                    ? tileName
                    : d.displayName;
                final subtitle = [
                  if (title != name) name,
                  if (!hasState && !selected) l10n.sceneFormReadingState,
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected,
                      title: Text(title),
                      subtitle:
                          subtitle.isEmpty ? null : Text(subtitle.join('\n')),
                      onChanged: (on) => _toggleDevice(d, on == true, states),
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 16, bottom: 8),
                        child: _deviceControls(d),
                      ),
                  ],
                );
              }),
            ],
            if (tiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              Text(l10n.sceneFormTilesHeader,
                  style: Theme.of(context).textTheme.titleSmall),
              Text(l10n.sceneFormTilesHint, style: outline),
              const SizedBox(height: 8),
              for (final t in tiles) _tileRow(t, sceneTiles.dashboards > 1),
            ],
          ],
        ),
      ),
    );
  }

  /// One own tile (3.8.7): a checkbox with the tile's name, and when ticked
  /// its control and, for an action the Engine can't send, the home-only
  /// note.
  Widget _tileRow(SceneTile t, bool showDashboard) {
    final l10n = context.l10n;
    // Watched so the tile's value is known on tick (same key as the
    // dashboard's tile, so no extra subscription while it is alive).
    final live = t.subscribes && !t.disabled
        ? ref
            .watch(panelValueSnapshotProvider(PanelStreamKey(
              connectionId: widget.connectionId,
              topic: t.subscribeTopic,
              jsonPath: t.jsonPath,
            )))
            .valueOrNull
            ?.value
        : null;
    final action = _tileActions[t.panelId];
    final selected = action != null;
    final config = t.config;
    final subtitle = [
      if (showDashboard && t.dashboardName != null) t.dashboardName!,
      if (config is ButtonConfig) config.payload,
    ];
    final outline = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        );
    return Column(
      key: ValueKey('scene-tile-${t.panelId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: selected,
          title: Text(t.name),
          subtitle: subtitle.isEmpty ? null : Text(subtitle.join('\n')),
          onChanged:
              t.disabled ? null : (on) => _toggleTile(t, on == true, live),
        ),
        if (selected)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?_tileControl(t),
                if (!engineCanSend(action, _base))
                  Text(l10n.sceneTileHomeOnly, style: outline),
              ],
            ),
          ),
      ],
    );
  }

  /// A ticked tile's control, built from the widgets the device rows use;
  /// null for a button (ticked = pressed).
  Widget? _tileControl(SceneTile t) {
    final l10n = context.l10n;
    final value = _tileValues[t.panelId];
    switch (t.config) {
      case ToggleConfig():
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.sceneCtrlPower),
          value: value != false,
          onChanged: (v) => _setTileValue(t, v),
        );
      case SliderConfig c:
        final v = (value is num ? value.toDouble() : c.min).clamp(c.min, c.max);
        return Row(
          children: [
            Expanded(
              child: Slider(
                min: c.min,
                max: c.max,
                divisions: sliderDivisions(c),
                value: v,
                label: '${v.round()}',
                onChanged: (n) => _setTileValue(t, n),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text('${v.round()}', textAlign: TextAlign.end),
            ),
          ],
        );
      case OptionsConfig c:
        final i = value is int ? value.clamp(0, c.options.length - 1) : 0;
        return DropdownButton<int>(
          value: i,
          isExpanded: true,
          items: [
            for (final (j, o) in c.options.indexed)
              DropdownMenuItem(value: j, child: Text(o.label)),
          ],
          onChanged: (j) => j == null ? null : _setTileValue(t, j),
        );
      case CoverConfig c:
        final cover = value is SceneCoverValue
            ? value
            : const SceneCoverValue(SceneCoverChoice.open);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<SceneCoverChoice>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: SceneCoverChoice.open,
                    label: Text(l10n.panelCoverOpen)),
                ButtonSegment(
                    value: SceneCoverChoice.close,
                    label: Text(l10n.panelCoverClose)),
                ButtonSegment(
                    value: SceneCoverChoice.stop,
                    label: Text(l10n.panelCoverStop)),
                if (c.showSlider)
                  ButtonSegment(
                      value: SceneCoverChoice.position,
                      label: Text(l10n.sceneCtrlPosition)),
              ],
              selected: {cover.choice},
              onSelectionChanged: (s) =>
                  _setTileValue(t, SceneCoverValue(s.first, cover.position)),
            ),
            if (c.showSlider && cover.choice == SceneCoverChoice.position)
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 100,
                      divisions: 100,
                      value: cover.position.clamp(0, 100).toDouble(),
                      label: '${cover.position}%',
                      onChanged: (n) => _setTileValue(t,
                          SceneCoverValue(SceneCoverChoice.position, n.round())),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text('${cover.position}%',
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
          ],
        );
      default:
        return null;
    }
  }

  /// Editable controls (sliders/toggles) for a selected device's scene values.
  /// Devices with no typed controls show the raw captured state instead.
  Widget _deviceControls(Z2mDevice d) {
    final l10n = context.l10n;
    final name = d.friendlyName;
    final edits = _edits[name]!;
    final controls = sceneControlsFor(d);

    if (controls.isEmpty) {
      return Text(
        edits.isEmpty ? l10n.sceneFormReadingState : jsonEncode(edits),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      );
    }

    // A changed control saves the rebuilt payload, not the stored one.
    void set(String property, Object value) => setState(() {
          edits[property] = value;
          _deviceOriginal.remove(name);
        });

    return Column(
      children: controls.map((c) {
        if (c.kind == SceneControlKind.toggle) {
          final on = edits[c.property] == c.onValue;
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_controlLabel(c.property)),
            value: on,
            onChanged: (v) => set(c.property, v ? c.onValue : c.offValue),
          );
        }
        final raw = edits[c.property];
        final value =
            (raw is num ? raw.toDouble() : c.min).clamp(c.min, c.max);
        return Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(_controlLabel(c.property),
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              child: Slider(
                min: c.min,
                max: c.max,
                divisions: (c.max - c.min).round(),
                value: value,
                label: '${value.round()}${c.unit ?? ''}',
                onChanged: (v) => set(c.property, v.round()),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text('${value.round()}${c.unit ?? ''}',
                  textAlign: TextAlign.end),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _controlLabel(String property) {
    final l10n = context.l10n;
    return switch (property) {
      'state' => l10n.sceneCtrlPower,
      'brightness' => l10n.sceneCtrlBrightness,
      'position' => l10n.sceneCtrlPosition,
      _ => property,
    };
  }
}
