import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../discovery/models/z2m_device.dart';
import '../../discovery/providers/discovery_provider.dart';
import '../../devices/devices_providers.dart';
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
  final Set<String> _selected = {};
  int _existingActions = 0;
  bool _loaded = false;
  bool _saving = false;

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
    _icon = IconData(scene.iconCodepoint, fontFamily: 'MaterialIcons');
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
    setState(() => _base = next);
  }

  /// Captures actions for the currently-selected devices.
  List<SceneAction> _captureSelected(
    List<Z2mDevice> devices,
    Map<String, String> states,
  ) {
    final out = <SceneAction>[];
    for (final device in devices) {
      if (!_selected.contains(device.friendlyName)) continue;
      final raw = states[device.friendlyName];
      if (raw == null) continue;
      final action = captureDeviceAction(
        base: _base,
        device: device,
        rawStateJson: raw,
      );
      if (action != null) out.add(action);
    }
    return out;
  }

  Future<void> _save(
    List<Z2mDevice> devices,
    Map<String, String> states,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final captured = _captureSelected(devices, states);

    // New scenes must capture something; edits may keep existing actions.
    if (!_isEdit && _selected.isEmpty) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.sceneFormNoDevicesSelected)));
      return;
    }
    if (_selected.isNotEmpty && captured.isEmpty) {
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

    // Devices that can contribute to a scene: have settable exposes and a
    // current state to capture.
    final capturable = [
      for (final d in devices)
        if (d.exposes.any((e) => e.isSettable) &&
            states.containsKey(d.friendlyName))
          d,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.sceneFormEditTitle : l10n.sceneFormNewTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(devices, states),
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
            if (statesAsync.isLoading && capturable.isEmpty)
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
              Text(l10n.sceneFormSelectedCount(_selected.length),
                  style: Theme.of(context).textTheme.bodySmall),
              ...capturable.map((d) {
                final name = d.friendlyName;
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selected.contains(name),
                  title: Text(name),
                  subtitle: Text(states[name] ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  onChanged: (on) => setState(() {
                    if (on == true) {
                      _selected.add(name);
                    } else {
                      _selected.remove(name);
                    }
                  }),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
