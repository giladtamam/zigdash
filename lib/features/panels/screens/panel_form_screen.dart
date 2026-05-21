import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';

enum SliderPreset { brightness, position }

/// Editable row backing one entry of a Multi-State / Combo / Radio panel.
class _OptionRow {
  _OptionRow({String label = '', String payload = '', String match = ''})
      : label = TextEditingController(text: label),
        payload = TextEditingController(text: payload),
        match = TextEditingController(text: match);

  final TextEditingController label;
  final TextEditingController payload;
  final TextEditingController match;

  void dispose() {
    label.dispose();
    payload.dispose();
    match.dispose();
  }
}

class PanelFormScreen extends ConsumerStatefulWidget {
  const PanelFormScreen({
    super.key,
    required this.connectionId,
    required this.dashboardId,
    this.panelId,
    this.initialType,
    this.initialSliderPreset,
  });

  final String connectionId;
  final String dashboardId;
  final String? panelId;
  final PanelType? initialType;
  final SliderPreset? initialSliderPreset;

  @override
  ConsumerState<PanelFormScreen> createState() => _State();
}

class _State extends ConsumerState<PanelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _topic = TextEditingController();
  final _subscribeTopic = TextEditingController();

  // Toggle fields
  final _onPayload = TextEditingController(text: '{"state":"ON"}');
  final _offPayload = TextEditingController(text: '{"state":"OFF"}');
  final _onMatch = TextEditingController(text: 'ON');
  final _toggleJsonPath = TextEditingController(text: 'state');

  // Slider fields
  final _sliderMin = TextEditingController(text: '0');
  final _sliderMax = TextEditingController(text: '254');
  final _sliderStep = TextEditingController(text: '1');
  final _sliderTemplate = TextEditingController(text: '{"brightness":{value}}');
  final _sliderJsonPath = TextEditingController(text: 'brightness');

  // Button fields
  final _buttonPayload = TextEditingController(text: 'PRESS');

  // Topic prefix override (optional)
  final _topicPrefixOverride = TextEditingController();

  // LED fields
  final _ledJsonPath = TextEditingController();
  final _ledOnMatch = TextEditingController(text: 'true');
  final _ledOnLabel = TextEditingController();
  final _ledOffLabel = TextEditingController();

  // Node-status fields
  final _nodeOnlinePayload = TextEditingController(text: 'online');
  final _nodeJsonPath = TextEditingController();

  // Progress fields
  final _progressMin = TextEditingController(text: '0');
  final _progressMax = TextEditingController(text: '100');
  final _progressJsonPath = TextEditingController();
  final _progressUnit = TextEditingController(text: '%');

  // Multi-State / Combo / Radio fields
  final _optionsJsonPath = TextEditingController(text: 'state');
  final List<_OptionRow> _optionRows = [];

  // Text Input fields
  final _textInputHint = TextEditingController();
  final _textInputTemplate = TextEditingController(text: '{value}');
  bool _textInputClearOnSend = false;

  // Text Log fields
  final _textLogMaxLines = TextEditingController(text: '50');
  final _textLogJsonPath = TextEditingController();

  // Cover fields
  final _coverPresets = TextEditingController(text: '0, 25, 50, 75, 100');
  bool _coverShowSlider = true;

  // Schedule fields
  final _scheduleOpenTime = TextEditingController(text: '07:00');
  final _scheduleCloseTime = TextEditingController(text: '19:00');
  final _scheduleOpenPayload = TextEditingController(text: '{"state":"OPEN"}');
  final _scheduleClosePayload = TextEditingController(text: '{"state":"CLOSE"}');
  bool _scheduleEnabled = true;

  PanelType _type = PanelType.toggle;
  PanelWidth _width = PanelWidth.full;
  bool _retain = false;
  int _qos = 1;
  bool _loaded = false;
  bool _saving = false;
  String? _topicPrefixHint;

  bool get _isEdit => widget.panelId != null;

  bool get _isReadOnly =>
      _type == PanelType.led ||
      _type == PanelType.nodeStatus ||
      _type == PanelType.progress ||
      _type == PanelType.textLog;

  bool get _isWriteOnly =>
      _type == PanelType.button ||
      _type == PanelType.textInput ||
      _type == PanelType.schedule;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? PanelType.toggle;
    _loadDashboardPrefix();
    if (_isEdit) {
      _loadPanel();
    } else {
      _seedDefaultsForType();
      if (_type == PanelType.slider &&
          widget.initialSliderPreset == SliderPreset.position) {
        _sliderMin.text = '0';
        _sliderMax.text = '100';
        _sliderStep.text = '1';
        _sliderTemplate.text = '{"position":{value}}';
        _sliderJsonPath.text = 'position';
      }
      _loaded = true;
    }
  }

  Future<void> _loadDashboardPrefix() async {
    final d = await ref.read(dashboardRepoProvider).getById(widget.dashboardId);
    if (!mounted) return;
    setState(() => _topicPrefixHint = d?.topicPrefix);
  }

  Future<void> _loadPanel() async {
    final p = await ref.read(panelRepoProvider).getById(widget.panelId!);
    if (p == null || !mounted) return;
    _type = p.type;
    _name.text = p.name;
    _topic.text = p.topic;
    _subscribeTopic.text = p.subscribeTopic ?? '';
    _topicPrefixOverride.text = p.topicPrefixOverride ?? '';
    _width = p.width;
    _retain = p.retain;
    _qos = p.qos;
    final cfg = PanelConfig.decode(p.type, p.config);
    if (cfg is ToggleConfig) {
      _onPayload.text = cfg.onPayload;
      _offPayload.text = cfg.offPayload;
      _onMatch.text = cfg.onMatch;
      _toggleJsonPath.text = cfg.jsonPath ?? '';
    } else if (cfg is SliderConfig) {
      _sliderMin.text = cfg.min.toString();
      _sliderMax.text = cfg.max.toString();
      _sliderStep.text = cfg.step.toString();
      _sliderTemplate.text = cfg.valueTemplate;
      _sliderJsonPath.text = cfg.jsonPath ?? '';
    } else if (cfg is ButtonConfig) {
      _buttonPayload.text = cfg.payload;
    } else if (cfg is LedConfig) {
      _ledJsonPath.text = cfg.jsonPath ?? '';
      _ledOnMatch.text = cfg.onMatch;
      _ledOnLabel.text = cfg.onLabel ?? '';
      _ledOffLabel.text = cfg.offLabel ?? '';
    } else if (cfg is NodeStatusConfig) {
      _nodeOnlinePayload.text = cfg.onlinePayload;
      _nodeJsonPath.text = cfg.jsonPath ?? '';
    } else if (cfg is ProgressConfig) {
      _progressMin.text = cfg.min.toString();
      _progressMax.text = cfg.max.toString();
      _progressJsonPath.text = cfg.jsonPath ?? '';
      _progressUnit.text = cfg.unit ?? '';
    } else if (cfg is OptionsConfig) {
      _optionsJsonPath.text = cfg.jsonPath ?? '';
      _optionRows
        ..clear()
        ..addAll(cfg.options.map((o) => _OptionRow(
              label: o.label,
              payload: o.payload,
              match: o.match,
            )));
    } else if (cfg is TextInputConfig) {
      _textInputHint.text = cfg.hint;
      _textInputTemplate.text = cfg.template;
      _textInputClearOnSend = cfg.clearOnSend;
    } else if (cfg is TextLogConfig) {
      _textLogMaxLines.text = cfg.maxLines.toString();
      _textLogJsonPath.text = cfg.jsonPath ?? '';
    } else if (cfg is CoverConfig) {
      _coverPresets.text = cfg.presets.join(', ');
      _coverShowSlider = cfg.showSlider;
    } else if (cfg is ScheduleConfig) {
      _scheduleOpenTime.text = cfg.openTime;
      _scheduleCloseTime.text = cfg.closeTime;
      _scheduleOpenPayload.text = cfg.openPayload;
      _scheduleClosePayload.text = cfg.closePayload;
      _scheduleEnabled = cfg.enabled;
    }
    setState(() => _loaded = true);
  }

  void _seedDefaultsForType() {
    switch (_type) {
      case PanelType.toggle:
        _topic.text = 'set';
        _subscribeTopic.text = '';
        break;
      case PanelType.slider:
        _topic.text = 'set';
        _subscribeTopic.text = '';
        break;
      case PanelType.button:
        _topic.text = 'set';
        break;
      case PanelType.led:
        _topic.text = '';
        _subscribeTopic.text = '';
        break;
      case PanelType.nodeStatus:
        _topic.text = '';
        _subscribeTopic.text = 'availability';
        break;
      case PanelType.progress:
        _topic.text = '';
        _subscribeTopic.text = '';
        break;
      case PanelType.multiState:
      case PanelType.combo:
      case PanelType.radio:
        _topic.text = 'set';
        _subscribeTopic.text = '';
        final def = OptionsConfig.coverDefault();
        _optionsJsonPath.text = def.jsonPath ?? 'state';
        _optionRows
          ..clear()
          ..addAll(def.options.map((o) => _OptionRow(
                label: o.label,
                payload: o.payload,
                match: o.match,
              )));
        break;
      case PanelType.cover:
        _topic.text = 'set';
        _subscribeTopic.text = '';
        break;
      case PanelType.textInput:
        _topic.text = 'set';
        break;
      case PanelType.textLog:
        _topic.text = '';
        _subscribeTopic.text = '';
        break;
      case PanelType.schedule:
        _topic.text = 'set';
        break;
    }
  }

  PanelConfig _buildConfig() {
    String? nullIfBlank(String s) => s.trim().isEmpty ? null : s.trim();
    return switch (_type) {
      PanelType.button => ButtonConfig(payload: _buttonPayload.text),
      PanelType.toggle => ToggleConfig(
          onPayload: _onPayload.text,
          offPayload: _offPayload.text,
          jsonPath: nullIfBlank(_toggleJsonPath.text),
          onMatch: _onMatch.text,
        ),
      PanelType.slider => SliderConfig(
          min: double.tryParse(_sliderMin.text) ?? 0,
          max: double.tryParse(_sliderMax.text) ?? 254,
          step: double.tryParse(_sliderStep.text) ?? 1,
          valueTemplate: _sliderTemplate.text,
          jsonPath: nullIfBlank(_sliderJsonPath.text),
        ),
      PanelType.led => LedConfig(
          jsonPath: nullIfBlank(_ledJsonPath.text),
          onMatch: _ledOnMatch.text,
          onLabel: nullIfBlank(_ledOnLabel.text),
          offLabel: nullIfBlank(_ledOffLabel.text),
        ),
      PanelType.nodeStatus => NodeStatusConfig(
          onlinePayload: _nodeOnlinePayload.text,
          jsonPath: nullIfBlank(_nodeJsonPath.text),
        ),
      PanelType.progress => ProgressConfig(
          min: double.tryParse(_progressMin.text) ?? 0,
          max: double.tryParse(_progressMax.text) ?? 100,
          jsonPath: nullIfBlank(_progressJsonPath.text),
          unit: nullIfBlank(_progressUnit.text),
        ),
      PanelType.multiState ||
      PanelType.combo ||
      PanelType.radio =>
        OptionsConfig(
          jsonPath: nullIfBlank(_optionsJsonPath.text),
          options: [
            for (final r in _optionRows)
              if (r.label.text.trim().isNotEmpty ||
                  r.payload.text.trim().isNotEmpty)
                SelectOption(
                  label: r.label.text.trim(),
                  payload: r.payload.text,
                  match: r.match.text.trim(),
                ),
          ],
        ),
      PanelType.cover => CoverConfig(
          presets: _parsePresets(_coverPresets.text),
          showSlider: _coverShowSlider,
        ),
      PanelType.textInput => TextInputConfig(
          hint: _textInputHint.text,
          template: _textInputTemplate.text.isEmpty
              ? '{value}'
              : _textInputTemplate.text,
          clearOnSend: _textInputClearOnSend,
        ),
      PanelType.textLog => TextLogConfig(
          maxLines: int.tryParse(_textLogMaxLines.text) ?? 50,
          jsonPath: nullIfBlank(_textLogJsonPath.text),
        ),
      PanelType.schedule => ScheduleConfig(
          openTime: _scheduleOpenTime.text.trim(),
          closeTime: _scheduleCloseTime.text.trim(),
          openPayload: _scheduleOpenPayload.text,
          closePayload: _scheduleClosePayload.text,
          enabled: _scheduleEnabled,
        ),
    };
  }

  List<int> _parsePresets(String s) {
    final out = <int>[];
    for (final part in s.split(',')) {
      final n = int.tryParse(part.trim());
      if (n != null) out.add(n.clamp(0, 100));
    }
    return out;
  }

  Future<void> _pickTime(TextEditingController c) async {
    final parts = c.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '7') ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => c.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(panelRepoProvider);
    final subTopic =
        _subscribeTopic.text == _topic.text ? null : _subscribeTopic.text;
    final prefixOverride = _topicPrefixOverride.text.trim().isEmpty
        ? null
        : _topicPrefixOverride.text.trim();
    try {
      if (_isEdit) {
        await repo.update(
          id: widget.panelId!,
          name: _name.text.trim(),
          topic: _topic.text,
          subscribeTopic: subTopic,
          topicPrefixOverride: prefixOverride,
          qos: _qos,
          retain: _retain,
          width: _width,
          config: _buildConfig(),
        );
      } else {
        await repo.create(
          dashboardId: widget.dashboardId,
          name: _name.text.trim(),
          type: _type,
          topic: _topic.text,
          subscribeTopic: subTopic,
          topicPrefixOverride: prefixOverride,
          qos: _qos,
          retain: _retain,
          width: _width,
          config: _buildConfig(),
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name, _topic, _subscribeTopic,
      _onPayload, _offPayload, _onMatch, _toggleJsonPath,
      _sliderMin, _sliderMax, _sliderStep, _sliderTemplate, _sliderJsonPath,
      _buttonPayload,
      _ledJsonPath, _ledOnMatch, _ledOnLabel, _ledOffLabel,
      _nodeOnlinePayload, _nodeJsonPath,
      _progressMin, _progressMax, _progressJsonPath, _progressUnit,
      _topicPrefixOverride,
      _optionsJsonPath,
      _textInputHint, _textInputTemplate,
      _textLogMaxLines, _textLogJsonPath,
      _coverPresets,
      _scheduleOpenTime, _scheduleCloseTime,
      _scheduleOpenPayload, _scheduleClosePayload,
    ]) {
      c.dispose();
    }
    for (final r in _optionRows) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final typeLabel = switch (_type) {
      PanelType.button => 'Button',
      PanelType.toggle => 'Toggle',
      PanelType.slider => 'Slider',
      PanelType.led => 'LED',
      PanelType.nodeStatus => 'Node Status',
      PanelType.progress => 'Progress',
      PanelType.multiState => 'Multi-State',
      PanelType.combo => 'Combo',
      PanelType.radio => 'Radio',
      PanelType.cover => 'Cover',
      PanelType.textInput => 'Text Input',
      PanelType.textLog => 'Text Log',
      PanelType.schedule => 'Schedule',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit $typeLabel' : 'New $typeLabel'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
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
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            if (_topicPrefixHint != null && _topicPrefixHint!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Dashboard prefix: $_topicPrefixHint/ (used unless overridden below)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            TextFormField(
              controller: _topicPrefixOverride,
              decoration: const InputDecoration(
                labelText: 'Topic prefix override (optional)',
                hintText: 'zigbee2mqtt/shutter',
                helperText: 'Use a different device on this dashboard. Blank = use dashboard prefix.',
              ),
            ),
            const SizedBox(height: 12),
            if (!_isReadOnly)
              TextFormField(
                controller: _topic,
                decoration: const InputDecoration(
                  labelText: 'Publish topic (suffix)',
                  hintText: 'set',
                  helperText: 'Appended to the effective prefix. Leave blank to publish at the prefix itself.',
                ),
              ),
            if (!_isWriteOnly) ...[
              if (!_isReadOnly) const SizedBox(height: 12),
              TextFormField(
                controller: _subscribeTopic,
                decoration: InputDecoration(
                  labelText: _isReadOnly
                      ? 'Topic (suffix)'
                      : 'Subscribe topic (suffix, optional)',
                  hintText: '',
                  helperText: _isReadOnly
                      ? 'Appended to the dashboard prefix. Blank = subscribe to the prefix itself (Z2M state).'
                      : 'Blank = subscribe to the prefix itself (Z2M state). Same as Publish topic = use that.',
                ),
              ),
            ],
            const SizedBox(height: 16),
            ..._typeSpecificFields(),
            const SizedBox(height: 16),
            DropdownButtonFormField<PanelWidth>(
              value: _width,
              decoration: const InputDecoration(labelText: 'Width'),
              items: const [
                DropdownMenuItem(value: PanelWidth.full, child: Text('Full')),
                DropdownMenuItem(value: PanelWidth.half, child: Text('Half')),
                DropdownMenuItem(value: PanelWidth.third, child: Text('Third')),
              ],
              onChanged: (v) => v == null ? null : setState(() => _width = v),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Advanced'),
              children: [
                DropdownButtonFormField<int>(
                  value: _qos,
                  decoration: const InputDecoration(labelText: 'QoS'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0 — at most once')),
                    DropdownMenuItem(value: 1, child: Text('1 — at least once')),
                    DropdownMenuItem(value: 2, child: Text('2 — exactly once')),
                  ],
                  onChanged: (v) => v == null ? null : setState(() => _qos = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Retain'),
                  value: _retain,
                  onChanged: (v) => setState(() => _retain = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _typeSpecificFields() {
    switch (_type) {
      case PanelType.toggle:
        return [
          TextFormField(
            controller: _onPayload,
            decoration: const InputDecoration(labelText: 'On payload'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _offPayload,
            decoration: const InputDecoration(labelText: 'Off payload'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _toggleJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              hintText: 'state',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _onMatch,
            decoration: const InputDecoration(
              labelText: 'On match',
              helperText: 'Value at JSON path that means "on" (e.g. "ON")',
            ),
          ),
        ];
      case PanelType.slider:
        return [
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _sliderMin,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sliderMax,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sliderStep,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Step'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sliderTemplate,
            decoration: const InputDecoration(
              labelText: 'Value template',
              helperText: '{value} is replaced with the slider value',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sliderJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              hintText: 'brightness',
            ),
          ),
        ];
      case PanelType.button:
        return [
          TextFormField(
            controller: _buttonPayload,
            decoration: const InputDecoration(labelText: 'Payload'),
          ),
        ];
      case PanelType.led:
        return [
          TextFormField(
            controller: _ledJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              hintText: 'contact',
              helperText: 'e.g. "contact", "occupancy", "water_leak"',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ledOnMatch,
            decoration: const InputDecoration(
              labelText: 'On match',
              helperText: 'Value at JSON path that lights the LED (e.g. "true", "ON")',
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _ledOnLabel,
                decoration: const InputDecoration(
                  labelText: 'On label (optional)',
                  hintText: 'ON',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _ledOffLabel,
                decoration: const InputDecoration(
                  labelText: 'Off label (optional)',
                  hintText: 'OFF',
                ),
              ),
            ),
          ]),
        ];
      case PanelType.nodeStatus:
        return [
          TextFormField(
            controller: _nodeOnlinePayload,
            decoration: const InputDecoration(
              labelText: 'Online payload',
              helperText: 'Value that means "online" (Z2M default: "online")',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nodeJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              helperText: 'Leave blank for Z2M default (raw "online"/"offline" string)',
            ),
          ),
        ];
      case PanelType.progress:
        return [
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _progressMin,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _progressMax,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _progressUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: '%',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _progressJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              hintText: 'battery',
              helperText: 'e.g. "battery", "linkquality"',
            ),
          ),
        ];
      case PanelType.multiState:
      case PanelType.combo:
      case PanelType.radio:
        return _optionsFields();
      case PanelType.cover:
        return [
          Text(
            'OPEN / STOP / CLOSE buttons plus a row of position presets. '
            'Uses the standard Z2M cover payloads ({"state":…} and '
            '{"position":…}).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _coverPresets,
            decoration: const InputDecoration(
              labelText: 'Position presets',
              hintText: '0, 25, 50, 100',
              helperText: 'Comma-separated percentages (0–100). Blank = no preset row.',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show position slider'),
            value: _coverShowSlider,
            onChanged: (v) => setState(() => _coverShowSlider = v),
          ),
        ];
      case PanelType.textInput:
        return [
          TextFormField(
            controller: _textInputHint,
            decoration: const InputDecoration(
              labelText: 'Hint (optional)',
              hintText: 'Type a value…',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _textInputTemplate,
            decoration: const InputDecoration(
              labelText: 'Template',
              helperText: '{value} is replaced with the typed text. Default publishes the raw text.',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Clear after send'),
            value: _textInputClearOnSend,
            onChanged: (v) => setState(() => _textInputClearOnSend = v),
          ),
        ];
      case PanelType.textLog:
        return [
          TextFormField(
            controller: _textLogMaxLines,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max lines',
              helperText: 'How many recent messages to keep',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _textLogJsonPath,
            decoration: const InputDecoration(
              labelText: 'JSON path (optional)',
              helperText: 'Log just this field instead of the whole payload',
            ),
          ),
        ];
      case PanelType.schedule:
        return [
          Text(
            'Runs on the SMHUB via Node-RED — fires even when this phone is '
            'off. The Publish topic above is the shutter command target.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _scheduleOpenTime,
                readOnly: true,
                onTap: () => _pickTime(_scheduleOpenTime),
                decoration: const InputDecoration(
                  labelText: 'Open time',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _scheduleCloseTime,
                readOnly: true,
                onTap: () => _pickTime(_scheduleCloseTime),
                decoration: const InputDecoration(
                  labelText: 'Close time',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleOpenPayload,
            decoration: const InputDecoration(labelText: 'Open payload'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleClosePayload,
            decoration: const InputDecoration(labelText: 'Close payload'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enabled'),
            value: _scheduleEnabled,
            onChanged: (v) => setState(() => _scheduleEnabled = v),
          ),
        ];
    }
  }

  List<Widget> _optionsFields() {
    return [
      TextFormField(
        controller: _optionsJsonPath,
        decoration: const InputDecoration(
          labelText: 'JSON path (optional)',
          hintText: 'state',
          helperText: 'Field in the received payload that holds the current value',
        ),
      ),
      const SizedBox(height: 12),
      Text('Options', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 4),
      for (var i = 0; i < _optionRows.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _optionRows[i].label,
                      decoration: const InputDecoration(
                        labelText: 'Label',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _optionRows[i].payload,
                      decoration: const InputDecoration(
                        labelText: 'Payload',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _optionRows[i].match,
                      decoration: const InputDecoration(
                        labelText: 'Match (current value)',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() {
                  _optionRows.removeAt(i).dispose();
                }),
              ),
            ],
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add option'),
          onPressed: () => setState(() => _optionRows.add(_OptionRow())),
        ),
      ),
    ];
  }
}
