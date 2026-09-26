import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/tables/panels.dart';
import '../../../mqtt/json_path.dart';
import '../../../data/repositories/dashboard_repo.dart';
import '../../../data/repositories/panel_repo.dart';
import '../../discovery/models/device_panel_suggestion.dart';
import '../models/panel_config.dart';
import '../providers/panel_value_provider.dart';
import '../services/auto_close_config_publisher.dart';
import '../services/automation_config_publisher.dart';

part 'panel_form_screen.fields.dart';

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
    this.suggestion,
  });

  final String connectionId;
  final String dashboardId;
  final String? panelId;
  final PanelType? initialType;
  final SliderPreset? initialSliderPreset;
  final PanelSuggestion? suggestion;

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

  // Scene field — preserved across generic-form edits (no UI field here; scene
  // panels are created/edited from the Scenes screen).
  String _sceneId = '';

  // Schedule fields
  final _scheduleOpenTime = TextEditingController(text: '07:00');
  final _scheduleCloseTime = TextEditingController(text: '19:00');
  final _scheduleOpenPayload = TextEditingController(text: '{"state":"OPEN"}');
  final _scheduleClosePayload = TextEditingController(text: '{"state":"CLOSE"}');
  bool _scheduleEnabled = true;

  // Auto-close fields
  final _autoCloseTriggerPath = TextEditingController(text: 'state');
  final _autoCloseTriggerValue = TextEditingController(text: 'ON');
  final _autoCloseClosePayload =
      TextEditingController(text: '{"state":"OFF"}');
  final _autoCloseDelaySeconds = TextEditingController(text: '60');
  bool _autoCloseEnabled = true;

  PanelType _type = PanelType.toggle;
  PanelWidth _width = PanelWidth.full;
  bool _retain = false;
  int _qos = 1;
  bool _loaded = false;
  bool _saving = false;
  String? _topicPrefixHint;

  bool get _isEdit => widget.panelId != null;

  // Scene panels carry no MQTT topic of their own (they activate a saved
  // scene); marking scene both read- and write-only hides every topic field.
  bool get _isReadOnly =>
      _type == PanelType.led ||
      _type == PanelType.nodeStatus ||
      _type == PanelType.progress ||
      _type == PanelType.textLog ||
      _type == PanelType.scene;

  bool get _isWriteOnly =>
      _type == PanelType.button ||
      _type == PanelType.textInput ||
      _type == PanelType.schedule ||
      _type == PanelType.scene ||
      _type == PanelType.autoClose;

  /// Returns the json-path text for the current panel type, or '' for types
  /// without a json-path field (button, textInput, cover, schedule, autoClose).
  String get _currentJsonPath => switch (_type) {
        PanelType.toggle => _toggleJsonPath.text,
        PanelType.slider => _sliderJsonPath.text,
        PanelType.led => _ledJsonPath.text,
        PanelType.nodeStatus => _nodeJsonPath.text,
        PanelType.progress => _progressJsonPath.text,
        PanelType.multiState ||
        PanelType.combo ||
        PanelType.radio =>
          _optionsJsonPath.text,
        PanelType.textLog => _textLogJsonPath.text,
        _ => '',
      };

  late final VoidCallback _onTopicChanged;

  @override
  void initState() {
    super.initState();
    _onTopicChanged = () => setState(() {});
    _topic.addListener(_onTopicChanged);
    _subscribeTopic.addListener(_onTopicChanged);
    _topicPrefixOverride.addListener(_onTopicChanged);
    _toggleJsonPath.addListener(_onTopicChanged);
    _sliderJsonPath.addListener(_onTopicChanged);
    _ledJsonPath.addListener(_onTopicChanged);
    _nodeJsonPath.addListener(_onTopicChanged);
    _progressJsonPath.addListener(_onTopicChanged);
    _optionsJsonPath.addListener(_onTopicChanged);
    _textLogJsonPath.addListener(_onTopicChanged);
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
      _applySuggestion(widget.suggestion);
      _loaded = true;
    }
  }

  /// Pre-fills controllers from a [PanelSuggestion] when creating a new panel.
  /// No-op when [suggestion] is null or when editing an existing panel.
  void _applySuggestion(PanelSuggestion? suggestion) {
    if (suggestion == null) return;

    _type = suggestion.type;
    _name.text = suggestion.name;
    _topicPrefixOverride.text = suggestion.topicPrefixOverride;
    _topic.text = suggestion.publishTopicSuffix;
    _subscribeTopic.text = suggestion.subscribeTopicSuffix;

    switch (suggestion.type) {
      case PanelType.toggle:
        if (suggestion.jsonPath != null) {
          _toggleJsonPath.text = suggestion.jsonPath!;
        }
        if (suggestion.onMatch != null) {
          _onMatch.text = suggestion.onMatch!;
        }
      case PanelType.slider:
        if (suggestion.jsonPath != null) {
          _sliderJsonPath.text = suggestion.jsonPath!;
        }
        if (suggestion.sliderIsBrightness) {
          _sliderMin.text = '0';
          _sliderMax.text = '254';
          _sliderStep.text = '1';
          _sliderTemplate.text = '{"brightness":{value}}';
        } else {
          _sliderMin.text = '0';
          _sliderMax.text = '100';
          _sliderStep.text = '1';
          _sliderTemplate.text = '{"position":{value}}';
        }
      case PanelType.led:
        if (suggestion.jsonPath != null) {
          _ledJsonPath.text = suggestion.jsonPath!;
        }
        if (suggestion.onMatch != null) {
          _ledOnMatch.text = suggestion.onMatch!;
        }
      case PanelType.progress:
        if (suggestion.jsonPath != null) {
          _progressJsonPath.text = suggestion.jsonPath!;
        }
        if (suggestion.unit != null) {
          _progressUnit.text = suggestion.unit!;
        }
      case PanelType.cover:
        // cover panel has good defaults; topic suffix already set above
        break;
      case PanelType.combo:
        if (suggestion.jsonPath != null) {
          _optionsJsonPath.text = suggestion.jsonPath!;
        }
      case PanelType.textLog:
        if (suggestion.jsonPath != null) {
          _textLogJsonPath.text = suggestion.jsonPath!;
        }
      default:
        break;
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
    } else if (cfg is AutoCloseConfig) {
      _autoCloseTriggerPath.text = cfg.triggerPath;
      _autoCloseTriggerValue.text = cfg.triggerValue;
      _autoCloseClosePayload.text = cfg.closePayload;
      _autoCloseDelaySeconds.text = cfg.delaySeconds.toString();
      _autoCloseEnabled = cfg.enabled;
    } else if (cfg is SceneConfig) {
      _sceneId = cfg.sceneId;
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
      case PanelType.scene:
        _topic.text = '';
        break;
      case PanelType.autoClose:
        _topic.text = '';
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
      PanelType.scene => SceneConfig(sceneId: _sceneId),
      PanelType.autoClose => AutoCloseConfig(
          triggerPath: _autoCloseTriggerPath.text.trim().isEmpty
              ? 'state'
              : _autoCloseTriggerPath.text.trim(),
          triggerValue: _autoCloseTriggerValue.text,
          closePayload: _autoCloseClosePayload.text,
          delaySeconds: int.tryParse(_autoCloseDelaySeconds.text) ?? 60,
          enabled: _autoCloseEnabled,
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
      String panelId;
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
        panelId = widget.panelId!;
      } else {
        panelId = await repo.create(
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
      if (_type == PanelType.schedule) {
        final effectivePrefix = prefixOverride ?? _topicPrefixHint;
        final target = composeTopic(effectivePrefix, _topic.text);
        final ok =
            await ref.read(automationConfigPublisherProvider).publishConfig(
                  connectionId: widget.connectionId,
                  panelId: panelId,
                  name: _name.text.trim(),
                  target: target,
                  config: _buildConfig() as ScheduleConfig,
                );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.panelScheduleSavedOffline),
          ));
        }
      }
      if (_type == PanelType.autoClose) {
        final effectivePrefix = prefixOverride ?? _topicPrefixHint;
        final triggerTopic = composeTopic(effectivePrefix, _topic.text);
        // Default target = triggerTopic + '/set' (Z2M convention). The v1
        // form does not expose a separate target override; the wire contract
        // supports it but the v1 UX assumes the Z2M target convention.
        final target = '$triggerTopic/set';
        final cfg = _buildConfig() as AutoCloseConfig;
        final ok =
            await ref.read(autoCloseConfigPublisherProvider).publishConfig(
                  connectionId: widget.connectionId,
                  panelId: panelId,
                  name: _name.text.trim(),
                  triggerTopic: triggerTopic,
                  target: target,
                  config: cfg,
                );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.panelAutoCloseSavedOffline),
          ));
        }
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
      _autoCloseTriggerPath, _autoCloseTriggerValue,
      _autoCloseClosePayload, _autoCloseDelaySeconds,
    ]) {
      c.dispose();
    }
    for (final r in _optionRows) {
      r.dispose();
    }
    _topic.removeListener(_onTopicChanged);
    _subscribeTopic.removeListener(_onTopicChanged);
    _topicPrefixOverride.removeListener(_onTopicChanged);
    _toggleJsonPath.removeListener(_onTopicChanged);
    _sliderJsonPath.removeListener(_onTopicChanged);
    _ledJsonPath.removeListener(_onTopicChanged);
    _nodeJsonPath.removeListener(_onTopicChanged);
    _progressJsonPath.removeListener(_onTopicChanged);
    _optionsJsonPath.removeListener(_onTopicChanged);
    _textLogJsonPath.removeListener(_onTopicChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = context.l10n;
    final typeLabel = switch (_type) {
      PanelType.button => l10n.panelTypeButton,
      PanelType.toggle => l10n.panelTypeToggle,
      PanelType.slider => l10n.panelTypeSlider,
      PanelType.led => l10n.panelTypeLed,
      PanelType.nodeStatus => l10n.panelTypeNodeStatus,
      PanelType.progress => l10n.panelTypeProgress,
      PanelType.multiState => l10n.panelTypeMultiState,
      PanelType.combo => l10n.panelTypeCombo,
      PanelType.radio => l10n.panelTypeRadio,
      PanelType.cover => l10n.panelTypeCover,
      PanelType.textInput => l10n.panelTypeTextInput,
      PanelType.textLog => l10n.panelTypeTextLog,
      PanelType.schedule => l10n.panelTypeSchedule,
      PanelType.scene => l10n.panelTypeScene,
      PanelType.autoClose => l10n.panelTypeAutoClose,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit
            ? l10n.panelFormEdit(typeLabel)
            : l10n.panelFormNew(typeLabel)),
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
              decoration: InputDecoration(labelText: l10n.panelFormName),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            if (_type != PanelType.scene)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: _isEdit,
                title: Text('MQTT Settings', style: Theme.of(context).textTheme.titleSmall),
                children: [
                  if (_topicPrefixHint != null &&
                      _topicPrefixHint!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l10n.panelFormDashboardPrefix(_topicPrefixHint!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),
                  TextFormField(
                    controller: _topicPrefixOverride,
                    decoration: InputDecoration(
                      labelText: l10n.panelFormTopicPrefixOverride,
                      hintText: l10n.panelFormTopicPrefixOverrideHint,
                      helperText: l10n.panelFormTopicPrefixOverrideHelper,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isReadOnly)
                    TextFormField(
                      controller: _topic,
                      decoration: InputDecoration(
                        labelText: l10n.panelFormPublishTopic,
                        hintText: l10n.panelFormPublishTopicHint,
                        helperText: l10n.panelFormPublishTopicHelper,
                      ),
                    ),
                  if (!_isWriteOnly) ...[
                    if (!_isReadOnly) const SizedBox(height: 12),
                    TextFormField(
                      controller: _subscribeTopic,
                      decoration: InputDecoration(
                        labelText: _isReadOnly
                            ? l10n.panelFormTopicSuffix
                            : l10n.panelFormSubscribeTopic,
                        hintText: '',
                        helperText: _isReadOnly
                            ? l10n.panelFormSubscribeTopicHelperReadOnly
                            : l10n.panelFormSubscribeTopicHelper,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey('qos-$_qos'),
                    initialValue: _qos,
                    decoration: InputDecoration(labelText: l10n.panelFormQos),
                    items: [
                      DropdownMenuItem(
                          value: 0, child: Text(l10n.panelFormQos0)),
                      DropdownMenuItem(
                          value: 1, child: Text(l10n.panelFormQos1)),
                      DropdownMenuItem(
                          value: 2, child: Text(l10n.panelFormQos2)),
                    ],
                    onChanged: (v) =>
                        v == null ? null : setState(() => _qos = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.panelFormRetain),
                    value: _retain,
                    onChanged: (v) => setState(() => _retain = v),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (_loaded) _buildLivePreview(),
            ..._typeSpecificFields(),
            const SizedBox(height: 16),
            DropdownButtonFormField<PanelWidth>(
              key: ValueKey(_width),
              initialValue: _width,
              decoration: InputDecoration(labelText: l10n.tileSize),
              items: [
                DropdownMenuItem(
                    value: PanelWidth.small,
                    child: Text(l10n.tileSizeSmall)),
                DropdownMenuItem(
                    value: PanelWidth.wide,
                    child: Text(l10n.tileSizeWide)),
                DropdownMenuItem(
                    value: PanelWidth.full,
                    child: Text(l10n.tileSizeFull)),
              ],
              onChanged: (v) => v == null ? null : setState(() => _width = v),
            ),
          ],
        ),
      ),
    );
  }

}
