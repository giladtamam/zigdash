import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_ext.dart';
import '../data/database/database.dart' show Scene;
import '../features/devices/devices_providers.dart' show homeBaseTopicProvider;
import '../features/discovery/models/z2m_device.dart';
import '../features/discovery/providers/discovery_provider.dart';
import '../features/scenes/all_shutters.dart';
import '../features/scenes/models/scene.dart';
import '../features/scenes/scenes_providers.dart';
import '../features/settings/providers/settings_controller.dart' show sharedPreferencesProvider;
import '../l10n/app_localizations.dart';
import '../core/analytics/analytics.dart';
import 'automation.dart';
import 'automation_text.dart';
import 'automations_repo.dart';
import 'engine_providers.dart' show engineKnownInstalled;
import 'engine_setup.dart' show checkEngine;
import 'engine_sheet.dart';
import 'engine_status.dart' show HubEnginePhase;
import 'town_picker.dart';

/// Creates or edits one Automation: When / Only if / Then
/// (prototype accepted 2026-10-22, zigdash-3.0.md §1).
class AutomationEditorScreen extends ConsumerStatefulWidget {
  const AutomationEditorScreen({super.key, required this.connectionId, this.existing});

  final String connectionId;
  final Automation? existing;

  @override
  ConsumerState<AutomationEditorScreen> createState() => _AutomationEditorScreenState();
}

enum _TriggerKind { device, time }

enum _TimeKind { clock, sunrise, sunset }

class _AutomationEditorScreenState extends ConsumerState<AutomationEditorScreen> {
  late final TextEditingController _name;
  late bool _enabled;

  // When
  late _TriggerKind _triggerKind;
  String? _tIeee;
  String? _tProperty;
  Object? _tEquals;
  bool _tAbove = true;
  final _tValue = TextEditingController();
  _TimeKind _timeKind = _TimeKind.clock;
  TimeOfDay _at = const TimeOfDay(hour: 7, minute: 0);
  int _offset = 0;
  Set<int> _days = {1, 2, 3, 4, 5, 6, 7};

  // Only if
  late List<AutomationCondition> _conditions;

  // Then
  late ActionKind _actionKind;
  String? _aIeee;
  String _aState = 'ON';
  String? _sceneId;
  int _offAfter = 0;

  bool _saving = false;
  String? _error;

  /// 3.6.2: the Home's rules stay at hand for the Engine sheet's "waiting
  /// from before" list, whatever screen is under this one.
  late final ProviderSubscription<AsyncValue<List<Automation>>> _rules;

  @override
  void initState() {
    super.initState();
    _rules = ref.listenManual(automationsProvider(widget.connectionId), (_, __) {});
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _enabled = e?.enabled ?? true;
    _conditions = [...?e?.conditions];
    switch (e?.trigger) {
      case DeviceTrigger t:
        _triggerKind = _TriggerKind.device;
        _tIeee = t.ieee;
        _tProperty = t.property;
        _tEquals = t.equals;
        if (t.above != null || t.below != null) {
          _tAbove = t.above != null;
          _tValue.text = '${t.above ?? t.below}';
        }
      case TimeTrigger t:
        _triggerKind = _TriggerKind.time;
        _timeKind = switch (t.sun) { Sun.sunrise => _TimeKind.sunrise, Sun.sunset => _TimeKind.sunset, null => _TimeKind.clock };
        _at = parseHhmm(t.at) ?? _at;
        _offset = t.offset;
        _days = t.days.toSet();
      case null:
        _triggerKind = _TriggerKind.device;
    }
    final a = e?.action;
    _actionKind = a?.kind ?? ActionKind.device;
    _offAfter = a?.offAfter ?? 0;
    _sceneId = a?.sceneId;
    if (a != null && a.kind == ActionKind.device && a.commands.isNotEmpty) {
      _aIeee = a.commands.first.ieee;
      _aState = a.deviceState ?? 'ON';
    }
  }

  @override
  void dispose() {
    _rules.close();
    _name.dispose();
    _tValue.dispose();
    super.dispose();
  }

  String get _base => ref.read(homeBaseTopicProvider(widget.connectionId)) ?? 'zigbee2mqtt';

  /// Away with the hub silent, but this phone saw the Engine there: the
  /// rule goes up through the relay as before.
  bool get _knownInstalled => engineKnownInstalled(ref.read(sharedPreferencesProvider), widget.connectionId);

  List<Z2mDevice> _devices() => [
        ...?ref
            .watch(bridgeDevicesStreamProvider((connectionId: widget.connectionId, base: _base)))
            .valueOrNull
            ?.where((d) => d.type != 'Coordinator' && d.ieeeAddress != null),
      ]..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

  Z2mDevice? _byIeee(List<Z2mDevice> devices, String? ieee) =>
      devices.where((d) => d.ieeeAddress == ieee).firstOrNull;

  Future<void> _save(List<Z2mDevice> devices, List<Scene> scenes) async {
    final l10n = context.l10n;
    final ml = MaterialLocalizations.of(context);
    final AutomationTrigger trigger;
    if (_triggerKind == _TriggerKind.device) {
      final dev = _byIeee(devices, _tIeee);
      final opt = dev == null ? null : triggerOptionsFor(dev).where((o) => o.property == _tProperty).firstOrNull;
      if (dev == null || opt == null) return setState(() => _error = l10n.autoErrPickTrigger);
      if (opt.numeric) {
        final v = double.tryParse(_tValue.text.replaceAll(',', '.'));
        if (v == null) return setState(() => _error = l10n.autoErrValue);
        trigger = DeviceTrigger(
            ieee: dev.ieeeAddress!, property: opt.property, above: _tAbove ? v : null, below: _tAbove ? null : v,
            label: dev.displayName);
      } else {
        if (_tEquals == null) return setState(() => _error = l10n.autoErrPickTrigger);
        trigger = DeviceTrigger(ieee: dev.ieeeAddress!, property: opt.property, equals: _tEquals, label: dev.displayName);
      }
    } else {
      if (_days.isEmpty) return setState(() => _error = l10n.autoErrDays);
      final sun = switch (_timeKind) { _TimeKind.sunrise => Sun.sunrise, _TimeKind.sunset => Sun.sunset, _ => null };
      if (sun != null && ref.read(automationsRepoProvider).town(widget.connectionId) == null) {
        return setState(() => _error = l10n.autoErrTown);
      }
      trigger = TimeTrigger(
          at: sun == null ? hhmm(_at) : null, sun: sun, offset: sun == null ? 0 : _offset, days: _days.toList()..sort());
    }

    final AutomationAction action;
    if (_actionKind == ActionKind.device) {
      final dev = _byIeee(devices, _aIeee);
      if (dev == null) return setState(() => _error = l10n.autoErrPickAction);
      action = AutomationAction(
        kind: ActionKind.device,
        commands: [EngineCommand(ieee: dev.ieeeAddress!, payload: {'state': _aState})],
        offAfter: _aState == 'ON' ? _offAfter : 0,
        label: dev.displayName,
      );
    } else {
      final scene = scenes.where((s) => s.id == _sceneId).firstOrNull;
      if (scene == null) return setState(() => _error = l10n.autoErrPickAction);
      final shutter = allShuttersCommand(scene.id);
      final List<SceneAction> actions = shutter != null
          ? shutterActions(shutter, _base, devices,
              excludedShutters(ref.read(sharedPreferencesProvider), widget.connectionId))
          : SceneAction.decodeList(scene.actions);
      final commands = sceneCommands(actions, devices, _base);
      if (commands.isEmpty) return setState(() => _error = l10n.autoErrEmptyScene);
      action = AutomationAction(
          kind: ActionKind.scene, commands: commands, offAfter: _offAfter, sceneId: scene.id, label: scene.name);
    }

    var rule = Automation(
      id: widget.existing?.id ?? newAutomationId(),
      name: _name.text.trim(),
      enabled: _enabled,
      trigger: trigger,
      conditions: _conditions,
      action: action,
    );
    if (rule.name.isEmpty) rule = rule.copyWith(name: autoName(l10n, ml, rule));
    setState(() {
      _saving = true;
      _error = null;
    });
    // 3.6.2: on a hub without the Engine, saving is where ZigDash puts it
    // there (or keeps the rule, not running).
    final check = await checkEngine(ref, widget.connectionId);
    if (!mounted) return;
    final view = check.view;
    // Away with no Engine seen here: made at home (the tab says so too).
    if (engineAwayWithoutEngine(view, knownInstalled: _knownInstalled)) {
      return setState(() {
        _saving = false;
        _error = l10n.engineAwayMakeAtHome;
      });
    }
    final bool ok;
    var running = true;
    if (view == null || !view.installed && !(view.phase == HubEnginePhase.unreachable && _knownInstalled)) {
      final result = await showEngineSaveSheet(context, ref, widget.connectionId, rule, check);
      if (!mounted) return;
      if (result == null) return setState(() => _saving = false);
      ok = result.saved;
      running = result.running;
    } else {
      ok = await ref.read(automationsRepoProvider).save(widget.connectionId, rule);
    }
    if (!mounted) return;
    if (ok) {
      // The rule may already be back from the broker (an install takes a
      // while): count it once.
      final count = {
        ...?ref.read(automationsProvider(widget.connectionId)).valueOrNull?.map((r) => r.id),
        rule.id,
      }.length;
      ref.read(analyticsProvider).track(AutomationSaved(
        trigger: switch (rule.trigger) {
          DeviceTrigger t when t.above != null || t.below != null => 'device_reading',
          DeviceTrigger t when t.property == 'action' => 'device_action',
          DeviceTrigger() => 'device_state',
          TimeTrigger t => t.sun == null ? 'clock' : 'sun',
        },
        conditions: rule.conditions.length,
        action: rule.action.kind.name,
        offAfter: rule.action.offAfter > 0,
        isNew: widget.existing == null,
        homeCount: count,
        running: running,
      ));
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = l10n.autoErrNotConnected;
      });
    }
  }

  Future<void> _delete() async {
    final id = widget.existing?.id;
    if (id == null) return;
    final l10n = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.autoDeleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.autoDelete)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final ok = await ref.read(automationsRepoProvider).delete(widget.connectionId, id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = context.l10n.autoErrNotConnected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final devices = _devices();
    final scenes = ref.watch(scenesForConnectionProvider(widget.connectionId)).valueOrNull ?? const <Scene>[];
    final theme = Theme.of(context);
    Widget section(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(text.toUpperCase(), style: theme.textTheme.labelLarge),
        );
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? l10n.autoNewTitle : l10n.autoEditTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          TextField(
            key: const Key('auto-name'),
            controller: _name,
            decoration: InputDecoration(labelText: l10n.autoName, hintText: l10n.autoNameHint),
          ),
          section(l10n.autoWhen),
          ..._triggerFields(l10n, devices),
          section(l10n.autoOnlyIf),
          ..._conditionFields(l10n, devices),
          section(l10n.autoThen),
          ..._actionFields(l10n, devices, scenes),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.autoEnabled),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          if (widget.existing != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: _saving ? null : _delete,
                child: Text(l10n.autoDelete, style: TextStyle(color: theme.colorScheme.error)),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('auto-save'),
            onPressed: _saving ? null : () => _save(devices, scenes),
            child: Text(l10n.autoSave),
          ),
        ),
      ),
    );
  }

  List<Widget> _triggerFields(AppLocalizations l10n, List<Z2mDevice> devices) {
    final ml = MaterialLocalizations.of(context);
    final kind = SegmentedButton<_TriggerKind>(
      segments: [
        ButtonSegment(value: _TriggerKind.device, label: Text(l10n.autoDeviceChanges)),
        ButtonSegment(value: _TriggerKind.time, label: Text(l10n.autoTimeComes)),
      ],
      selected: {_triggerKind},
      onSelectionChanged: (s) => setState(() => _triggerKind = s.first),
    );
    if (_triggerKind == _TriggerKind.device) {
      final withOptions = [for (final d in devices) if (triggerOptionsFor(d).isNotEmpty) d];
      final dev = _byIeee(withOptions, _tIeee);
      final options = dev == null ? const <TriggerOption>[] : triggerOptionsFor(dev);
      final opt = options.where((o) => o.property == _tProperty).firstOrNull;
      return [
        kind,
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('auto-trigger-device'),
          initialValue: dev?.ieeeAddress,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.autoDevice),
          items: [for (final d in withOptions) DropdownMenuItem(value: d.ieeeAddress, child: Text(d.displayName))],
          onChanged: (v) => setState(() {
            _tIeee = v;
            final first = _byIeee(withOptions, v) == null ? null : triggerOptionsFor(_byIeee(withOptions, v)!).firstOrNull;
            _tProperty = first?.property;
            _tEquals = first?.choices.firstOrNull;
          }),
        ),
        if (options.length > 1) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in options)
              ChoiceChip(
                label: Text(o.property.replaceAll('_', ' ')),
                selected: o.property == _tProperty,
                onSelected: (_) => setState(() {
                  _tProperty = o.property;
                  _tEquals = o.choices.firstOrNull;
                }),
              ),
          ]),
        ],
        if (opt != null && !opt.numeric) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in opt.choices)
              ChoiceChip(
                label: Text(valueText(l10n, opt.property, c)),
                selected: _tEquals == c,
                onSelected: (_) => setState(() => _tEquals = c),
              ),
          ]),
        ],
        if (opt != null && opt.numeric) ...[
          const SizedBox(height: 12),
          Row(children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.autoAbove)),
                ButtonSegment(value: false, label: Text(l10n.autoBelow)),
              ],
              selected: {_tAbove},
              onSelectionChanged: (s) => setState(() => _tAbove = s.first),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('auto-trigger-value'),
                controller: _tValue,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(suffixText: opt.unit),
              ),
            ),
          ]),
        ],
      ];
    }
    final town = ref.watch(automationsRepoProvider).town(widget.connectionId);
    return [
      kind,
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final k in _TimeKind.values)
          ChoiceChip(
            label: Text(switch (k) {
              _TimeKind.clock => l10n.autoClockTime,
              _TimeKind.sunrise => _capitalized(l10n.autoSunrise),
              _TimeKind.sunset => _capitalized(l10n.autoSunset),
            }),
            selected: _timeKind == k,
            onSelected: (_) => setState(() => _timeKind = k),
          ),
      ]),
      const SizedBox(height: 12),
      if (_timeKind == _TimeKind.clock)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.autoAt),
          trailing: Text(hhmm(_at), style: Theme.of(context).textTheme.titleLarge),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: _at);
            if (t != null) setState(() => _at = t);
          },
        )
      else ...[
        Row(children: [
          Expanded(child: Text(l10n.autoShift)),
          IconButton(onPressed: () => setState(() => _offset -= 5), icon: const Icon(Icons.remove)),
          Text(_offset == 0 ? '0' : (_offset > 0 ? '+$_offset' : '$_offset')),
          IconButton(onPressed: () => setState(() => _offset += 5), icon: const Icon(Icons.add)),
        ]),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(town == null ? l10n.autoTownNone : l10n.autoTownIs(town.name)),
          trailing: TextButton(
            onPressed: () async {
              final picked = await pickTown(context);
              if (picked != null) {
                await ref.read(automationsRepoProvider).setTown(widget.connectionId, picked);
                setState(() {});
              }
            },
            child: Text(town == null ? l10n.autoTownSet : l10n.autoTownChange),
          ),
        ),
      ],
      const SizedBox(height: 8),
      Text(l10n.autoDays),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: [
        for (var d = 1; d <= 7; d++)
          FilterChip(
            label: Text(dayShort(ml, d)),
            selected: _days.contains(d),
            onSelected: (on) => setState(() => on ? _days.add(d) : _days.remove(d)),
          ),
      ]),
    ];
  }

  List<Widget> _conditionFields(AppLocalizations l10n, List<Z2mDevice> devices) {
    return [
      if (_conditions.isEmpty) Text(l10n.autoNoConditions),
      for (final (i, c) in _conditions.indexed)
        InputChip(
          label: Text(conditionText(l10n, c, deviceName: c is DeviceCondition ? _byIeee(devices, c.ieee)?.displayName : null)),
          onDeleted: () => setState(() => _conditions.removeAt(i)),
        ),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(l10n.autoAddHours),
          onPressed: () async {
            final from = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 18, minute: 0), helpText: l10n.autoFrom);
            if (from == null || !mounted) return;
            final to = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0), helpText: l10n.autoTo);
            if (to == null) return;
            setState(() => _conditions.add(HoursCondition(from: hhmm(from), to: hhmm(to))));
          },
        ),
        ActionChip(
          avatar: const Icon(Icons.add),
          label: Text(l10n.autoAddDeviceCondition),
          onPressed: () async {
            final c = await _pickDeviceCondition(l10n, devices);
            if (c != null) setState(() => _conditions.add(c));
          },
        ),
      ]),
    ];
  }

  Future<DeviceCondition?> _pickDeviceCondition(AppLocalizations l10n, List<Z2mDevice> devices) =>
      showModalBottomSheet<DeviceCondition>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l10n.autoAddDeviceCondition, style: Theme.of(ctx).textTheme.titleMedium),
              ),
              for (final d in devices)
                for (final o in triggerOptionsFor(d).where((o) => !o.numeric && o.property != 'action'))
                  for (final v in o.choices)
                    ListTile(
                      title: Text(d.displayName),
                      subtitle: Text(valueText(l10n, o.property, v)),
                      onTap: () => Navigator.of(ctx).pop(
                          DeviceCondition(ieee: d.ieeeAddress!, property: o.property, equals: v, label: d.displayName)),
                    ),
            ],
          ),
        ),
      );

  List<Widget> _actionFields(AppLocalizations l10n, List<Z2mDevice> devices, List<Scene> scenes) {
    final targets = [for (final d in devices) if (actionStatesFor(d).isNotEmpty) d];
    final target = _byIeee(targets, _aIeee);
    final canTurnOff = _actionKind == ActionKind.scene || _aState == 'ON';
    return [
      SegmentedButton<ActionKind>(
        segments: [
          ButtonSegment(value: ActionKind.scene, label: Text(l10n.autoRunASceneOption)),
          ButtonSegment(value: ActionKind.device, label: Text(l10n.autoSetADevice)),
        ],
        selected: {_actionKind},
        onSelectionChanged: (s) => setState(() => _actionKind = s.first),
      ),
      const SizedBox(height: 12),
      if (_actionKind == ActionKind.scene)
        DropdownButtonFormField<String>(
          key: const Key('auto-action-scene'),
          initialValue: scenes.any((s) => s.id == _sceneId) ? _sceneId : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.autoScene),
          items: [for (final s in scenes) DropdownMenuItem(value: s.id, child: Text(s.name))],
          onChanged: (v) => setState(() => _sceneId = v),
        )
      else ...[
        if (targets.isEmpty)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(l10n.autoNoTargets)),
        DropdownButtonFormField<String>(
          key: const Key('auto-action-device'),
          initialValue: target?.ieeeAddress,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.autoDevice),
          items: [for (final d in targets) DropdownMenuItem(value: d.ieeeAddress, child: Text(d.displayName))],
          onChanged: (v) => setState(() {
            _aIeee = v;
            final states = _byIeee(targets, v) == null ? const <String>[] : actionStatesFor(_byIeee(targets, v)!);
            _aState = states.firstOrNull ?? 'ON';
          }),
        ),
        if (target != null) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final s in actionStatesFor(target))
              ChoiceChip(
                label: Text(_capitalized(valueText(l10n, 'state', s))),
                selected: _aState == s,
                onSelected: (_) => setState(() => _aState = s),
              ),
          ]),
        ],
      ],
      if (canTurnOff) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.autoTurnOffAgain),
              Text(_offAfter == 0 ? l10n.autoStaysAsSet : l10n.autoOffAfterMinutes(_offAfter),
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          IconButton(
              onPressed: _offAfter == 0 ? null : () => setState(() => _offAfter = (_offAfter - 5).clamp(0, 1440)),
              icon: const Icon(Icons.remove)),
          Text('$_offAfter'),
          IconButton(onPressed: () => setState(() => _offAfter = (_offAfter + 5).clamp(0, 1440)), icon: const Icon(Icons.add)),
        ]),
      ],
    ];
  }
}

/// The sentence word ("sunrise") as a chip label ("Sunrise").
String _capitalized(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
