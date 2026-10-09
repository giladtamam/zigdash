// The form's State is extended across part files, like .fields.dart.
// ignore_for_file: invalid_use_of_protected_member

part of 'panel_form_screen.dart';

/// The command topic that goes with a state topic, Zigbee2MQTT style:
/// `<state>/set`, or `set` on its own when the prefix is the device topic.
String commandFor(String state) {
  final s = state.trim();
  return s.isEmpty ? 'set' : '$s/set';
}

/// The Topic block and Advanced (devices-tablet-1.13.md §5): topics first,
/// with the prefix shown as a lead-in, "Pick a device", and the rarely used
/// options folded away.
extension _PanelFormTopics on _State {
  String get _effectivePrefix {
    final override = _topicPrefixOverride.text.trim();
    return override.isNotEmpty ? override : (_topicPrefixHint ?? '').trim();
  }

  List<Widget> _topicBlock() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final prefix = _effectivePrefix;
    final lead = prefix.isEmpty ? null : '$prefix/';
    final base = ref.watch(homeBaseTopicProvider(widget.connectionId)) ??
        'zigbee2mqtt';
    final devices = ref
            .watch(bridgeDevicesStreamProvider(
                (connectionId: widget.connectionId, base: base)))
            .valueOrNull ??
        const <Z2mDevice>[];
    final linked =
        devices.where((d) => d.ieeeAddress == _deviceIeee).firstOrNull;

    return [
      Row(
        children: [
          Expanded(
            child: Text(l10n.panelFormTopic,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.devices_other),
            label: Text(l10n.panelFormPickDevice),
            onPressed: devices.isEmpty ? null : () => _pickDevice(devices, base),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (!_isWriteOnly) ...[
        TextFormField(
          controller: _subscribeTopic,
          // Topics are left-to-right, also in Hebrew.
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.panelFormStateTopic,
            prefixText: lead,
            helperText: l10n.panelFormStateTopicHelper,
          ),
          onChanged: (v) {
            if (_isReadOnly || _commandEdited) return;
            _topic.text = v.trim().isEmpty ? '' : commandFor(v);
          },
        ),
        const SizedBox(height: 12),
      ],
      if (!_isReadOnly) ...[
        TextFormField(
          controller: _topic,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.panelFormCommandTopic,
            prefixText: lead,
            helperText: _commandEdited || _isWriteOnly
                ? l10n.panelFormPublishTopicHelper
                : l10n.panelFormCommandTopicDerived,
          ),
          onChanged: (_) => _commandEdited = true,
        ),
        const SizedBox(height: 12),
      ],
      if (_deviceIeee != null)
        Card.filled(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
            child: Row(
              children: [
                const Icon(Icons.link, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.panelFormLinkedTo(
                      linked?.friendlyName ?? _deviceIeee!)),
                ),
                TextButton(
                  onPressed: () => context.push(
                      Routes.homeDevice(widget.connectionId, _deviceIeee!)),
                  child: Text(l10n.panelFormOpenDevice),
                ),
                TextButton(
                  onPressed: () => setState(() => _deviceIeee = null),
                  child: Text(l10n.panelFormUnlink),
                ),
              ],
            ),
          ),
        ),
      if (linked != null && _valuePath != null) _valueChoices(linked),
    ];
  }

  /// The current type's value-path field, if it has one.
  TextEditingController? get _valuePath => switch (_type) {
        PanelType.toggle => _toggleJsonPath,
        PanelType.slider => _sliderJsonPath,
        PanelType.led => _ledJsonPath,
        PanelType.nodeStatus => _nodeJsonPath,
        PanelType.progress => _progressJsonPath,
        PanelType.multiState ||
        PanelType.combo ||
        PanelType.radio =>
          _optionsJsonPath,
        PanelType.textLog => _textLogJsonPath,
        PanelType.reading => _readingJsonPath,
        _ => null,
      };

  /// The linked device's readable, everyday properties as value-path
  /// choices.
  Widget _valueChoices(Z2mDevice device) {
    final path = _valuePath!;
    final props = <String>{
      for (final f in classifyExposes(device.rawExposes).features)
        // Everyday values only: settings like turbo_mode are not states.
        if (f.readable &&
            f.normal &&
            f.type != 'composite' &&
            f.type != 'list')
          f.property,
    };
    if (props.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.panelFormValueChoices,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in props)
                ChoiceChip(
                  label: Text(p),
                  selected: path.text == p,
                  onSelected: (_) => setState(() => path.text = p),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Fills the topics from a device (relative to the effective prefix),
  /// links the tile to it, and prefills the command topic.
  Future<void> _pickDevice(List<Z2mDevice> devices, String base) async {
    final picked = await showModalBottomSheet<Z2mDevice>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final d in devices)
                ListTile(
                  leading: Icon(deviceClassIcon(
                      classifyExposes(d.rawExposes).deviceClass)),
                  title: Text(d.friendlyName),
                  subtitle: deviceModelLabel(d) == null
                      ? null
                      : Text(deviceModelLabel(d)!),
                  onTap: () => Navigator.pop(ctx, d),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    final topics = deviceTopics(
      deviceTopic: '$base/${picked.friendlyName}',
      prefix: _effectivePrefix,
      base: base,
    );
    setState(() {
      if (topics.prefixOverride != null) {
        _topicPrefixOverride.text = topics.prefixOverride!;
      }
      _subscribeTopic.text = topics.state;
      if (!_isReadOnly) _topic.text = commandFor(topics.state);
      _commandEdited = false;
      _deviceIeee = picked.ieeeAddress;
      if (_name.text.trim().isEmpty) _name.text = picked.friendlyName;
    });
  }

  Widget _advanced() {
    final l10n = context.l10n;
    final inUse = _topicPrefixOverride.text.trim().isNotEmpty ||
        _qos != 1 ||
        _retain;
    return ExpansionTile(
      // Rebuilt once the tile loads, so a tile using these opens expanded.
      key: ValueKey('advanced-$_loaded'),
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: _loaded && inUse,
      title: Text(l10n.panelFormAdvanced,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(l10n.panelFormAdvancedSubtitle),
      children: [
        if (_topicPrefixHint != null && _topicPrefixHint!.isNotEmpty)
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
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.panelFormTopicPrefixOverride,
            hintText: l10n.panelFormTopicPrefixOverrideHint,
            helperText: l10n.panelFormTopicPrefixOverrideHelper,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          key: ValueKey('qos-$_qos'),
          initialValue: _qos,
          decoration: InputDecoration(labelText: l10n.panelFormQos),
          items: [
            DropdownMenuItem(value: 0, child: Text(l10n.panelFormQos0)),
            DropdownMenuItem(value: 1, child: Text(l10n.panelFormQos1)),
            DropdownMenuItem(value: 2, child: Text(l10n.panelFormQos2)),
          ],
          onChanged: (v) => v == null ? null : setState(() => _qos = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.panelFormRetain),
          value: _retain,
          onChanged: (v) => setState(() => _retain = v),
        ),
      ],
    );
  }
}

/// Where a device's topic lands in a tile relative to its effective
/// prefix (devices-tablet-1.13.md §5): the whole topic with no prefix, the
/// remainder when the prefix leads it, nothing when the prefix is the device
/// topic, and otherwise a prefix override of the base topic.
({String state, String? prefixOverride}) deviceTopics({
  required String deviceTopic,
  required String prefix,
  required String base,
}) {
  if (prefix.isEmpty) return (state: deviceTopic, prefixOverride: null);
  if (deviceTopic == prefix) return (state: '', prefixOverride: null);
  if (deviceTopic.startsWith('$prefix/')) {
    return (
      state: deviceTopic.substring(prefix.length + 1),
      prefixOverride: null
    );
  }
  return (state: deviceTopic.substring(base.length + 1), prefixOverride: base);
}
