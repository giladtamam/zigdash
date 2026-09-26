import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/material_icon.dart';
import '../../devices/devices_providers.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
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
  });

  final String connectionId;
  final String? sceneId;

  @override
  ConsumerState<SceneFormScreen> createState() => _State();
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
  int _existingActions = 0;
  bool _loaded = false;
  bool _saving = false;
  bool _statesRequested = false;

  bool get _isEdit => widget.sceneId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final scene = await ref.read(sceneRepoProvider).getById(widget.sceneId!);
    if (scene == null || !mounted) return;
    _name.text = scene.name;
    _color = Color(scene.colorSeed);
    _icon = materialIcon(scene.iconCodepoint);
    _existingActions = SceneAction.decodeList(scene.actions).length;
    setState(() => _loaded = true);
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

  /// Selects/deselects a device. On select, seeds its editable values from the
  /// device's current live state (or sensible defaults); devices with no typed
  /// controls fall back to capturing their settable state as-is.
  void _toggleDevice(Z2mDevice d, bool on, Map<String, String> states) {
    setState(() {
      if (!on) {
        _edits.remove(d.friendlyName);
        return;
      }
      final live = _parseState(states[d.friendlyName]);
      var seed = initialSceneEdits(d, live);
      if (seed.isEmpty && live != null) seed = captureSettableState(d, live);
      _edits[d.friendlyName] = seed;
    });
  }

  List<SceneAction> _buildActions() {
    final out = <SceneAction>[];
    for (final entry in _edits.entries) {
      if (entry.value.isEmpty) continue;
      out.add(SceneAction(
        setTopic: '$_base/${entry.key}/set',
        payload: jsonEncode(entry.value),
      ));
    }
    return out;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final captured = _buildActions();

    // New scenes must capture something; edits may keep existing actions.
    if (!_isEdit && _edits.isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.sceneFormNoDevicesSelected)));
      return;
    }
    if (_edits.isNotEmpty && captured.isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.sceneFormNothingCaptured)));
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(sceneRepoProvider);
    try {
      if (_isEdit) {
        final scene = await repo.getById(widget.sceneId!);
        final actions = captured.isNotEmpty
            ? captured
            : SceneAction.decodeList(scene?.actions ?? '[]');
        await repo.update(
          id: widget.sceneId!,
          name: _name.text.trim(),
          iconCodepoint: _icon.codePoint,
          colorSeed: _color.toARGB32(),
          actions: actions,
        );
      } else {
        await repo.create(
          connectionId: widget.connectionId,
          name: _name.text.trim(),
          iconCodepoint: _icon.codePoint,
          colorSeed: _color.toARGB32(),
          actions: captured,
        );
      }
      if (mounted) context.pop();
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
    final devices = devicesAsync.value ?? const <Z2mDevice>[];
    final states = statesAsync.value ?? const <String, String>{};

    _ensureStateRequested(devices);

    // Devices that can contribute to a scene: anything with settable controls.
    // Their live state may still be arriving (we pull it via `/get`).
    final capturable = [
      for (final d in devices)
        if (d.exposes.any((e) => e.isSettable)) d,
    ];

    return Scaffold(
      appBar: AppBar(
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
            Text(
              l10n.sceneFormCaptureHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            if (_isEdit && _existingActions > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.sceneActionsCount(_existingActions),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            if (devicesAsync.isLoading && capturable.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (capturable.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.sceneFormNoDevices),
              )
            else ...[
              Text(l10n.sceneFormSelectedCount(_edits.length),
                  style: Theme.of(context).textTheme.bodySmall),
              ...capturable.map((d) {
                final name = d.friendlyName;
                final selected = _edits.containsKey(name);
                final hasState = states.containsKey(name);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selected,
                      title: Text(name),
                      subtitle: hasState || selected
                          ? null
                          : Text(l10n.sceneFormReadingState),
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
          ],
        ),
      ),
    );
  }

  /// Editable controls (sliders/toggles) for a selected device's scene values.
  /// Devices with no typed controls show the raw captured state instead.
  Widget _deviceControls(Z2mDevice d) {
    final l10n = context.l10n;
    final edits = _edits[d.friendlyName]!;
    final controls = sceneControlsFor(d);

    if (controls.isEmpty) {
      return Text(
        edits.isEmpty ? l10n.sceneFormReadingState : jsonEncode(edits),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      );
    }

    return Column(
      children: controls.map((c) {
        if (c.kind == SceneControlKind.toggle) {
          final on = edits[c.property] == c.onValue;
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(_controlLabel(c.property)),
            value: on,
            onChanged: (v) => setState(
                () => edits[c.property] = v ? c.onValue : c.offValue),
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
                onChanged: (v) =>
                    setState(() => edits[c.property] = v.round()),
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
