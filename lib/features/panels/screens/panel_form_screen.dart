import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/tables/panels.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../models/panel_config.dart';

class PanelFormScreen extends ConsumerStatefulWidget {
  const PanelFormScreen({
    super.key,
    required this.connectionId,
    required this.dashboardId,
    this.panelId,
    this.initialType,
  });

  final String connectionId;
  final String dashboardId;
  final String? panelId;
  final PanelType? initialType;

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

  PanelType _type = PanelType.toggle;
  PanelWidth _width = PanelWidth.full;
  bool _retain = false;
  int _qos = 1;
  bool _loaded = false;
  bool _saving = false;
  String? _topicPrefixHint;

  bool get _isEdit => widget.panelId != null;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? PanelType.toggle;
    _loadDashboardPrefix();
    if (_isEdit) {
      _loadPanel();
    } else {
      _seedDefaultsForType();
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
    }
  }

  PanelConfig _buildConfig() {
    return switch (_type) {
      PanelType.button => ButtonConfig(payload: _buttonPayload.text),
      PanelType.toggle => ToggleConfig(
          onPayload: _onPayload.text,
          offPayload: _offPayload.text,
          jsonPath: _toggleJsonPath.text.trim().isEmpty ? null : _toggleJsonPath.text.trim(),
          onMatch: _onMatch.text,
        ),
      PanelType.slider => SliderConfig(
          min: double.tryParse(_sliderMin.text) ?? 0,
          max: double.tryParse(_sliderMax.text) ?? 254,
          step: double.tryParse(_sliderStep.text) ?? 1,
          valueTemplate: _sliderTemplate.text,
          jsonPath: _sliderJsonPath.text.trim().isEmpty ? null : _sliderJsonPath.text.trim(),
        ),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(panelRepoProvider);
    final subTopic =
        _subscribeTopic.text == _topic.text ? null : _subscribeTopic.text;
    try {
      if (_isEdit) {
        await repo.update(
          id: widget.panelId!,
          name: _name.text.trim(),
          topic: _topic.text,
          subscribeTopic: subTopic,
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
    ]) {
      c.dispose();
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
                  'Topic prefix from dashboard: $_topicPrefixHint/',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            TextFormField(
              controller: _topic,
              decoration: const InputDecoration(
                labelText: 'Publish topic (suffix)',
                hintText: 'set',
                helperText: 'Leave blank to publish at the prefix itself. Prefix `/` for absolute.',
              ),
            ),
            if (_type != PanelType.button) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _subscribeTopic,
                decoration: const InputDecoration(
                  labelText: 'Subscribe topic (suffix, optional)',
                  hintText: '',
                  helperText: 'Blank = subscribe to the prefix itself (Z2M state). Same as Publish topic = use that.',
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
    }
  }
}
