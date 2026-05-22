part of 'panel_form_screen.dart';

extension _PanelFormFields on _State {
  Widget _buildLivePreview() {
    final l10n = context.l10n;
    final prefix = _topicPrefixHint ?? '';
    final topic = effectiveSubscribeTopic(
      dashboardPrefix: prefix,
      prefixOverride: _topicPrefixOverride.text,
      subscribeSuffix: _subscribeTopic.text,
    );
    if (topic.isEmpty) return const SizedBox.shrink();

    final rawAsync = ref.watch(panelValueProvider(PanelStreamKey(
      connectionId: widget.connectionId,
      topic: topic,
      jsonPath: null,
    )));

    final jsonPath = _currentJsonPath;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.previewTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 6),
              rawAsync.when(
                data: (raw) {
                  final rawStr = raw?.toString() ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        rawStr,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                        maxLines: 6,
                      ),
                      if (jsonPath.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Builder(builder: (_) {
                          final extracted = rawStr.isNotEmpty
                              ? extractByPath(rawStr, jsonPath)
                              : null;
                          return Text(
                            extracted != null
                                ? l10n.previewExtracted(
                                    jsonPath, extracted.toString())
                                : l10n.previewNoValue,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: extracted != null
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.error,
                                  fontFamily: 'monospace',
                                ),
                          );
                        }),
                      ],
                    ],
                  );
                },
                loading: () => Text(
                  l10n.previewWaiting(topic),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                error: (_, __) => Text(
                  l10n.previewWaiting(topic),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _typeSpecificFields() {
    final l10n = context.l10n;
    switch (_type) {
      case PanelType.toggle:
        return [
          TextFormField(
            controller: _onPayload,
            decoration:
                InputDecoration(labelText: l10n.panelToggleOnPayload),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _offPayload,
            decoration:
                InputDecoration(labelText: l10n.panelToggleOffPayload),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _toggleJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelToggleJsonPath,
              hintText: l10n.panelToggleJsonPathHint,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _onMatch,
            decoration: InputDecoration(
              labelText: l10n.panelToggleOnMatch,
              helperText: l10n.panelToggleOnMatchHelper,
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
                decoration:
                    InputDecoration(labelText: l10n.panelSliderMin),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sliderMax,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.panelSliderMax),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _sliderStep,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.panelSliderStep),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sliderTemplate,
            decoration: InputDecoration(
              labelText: l10n.panelSliderTemplate,
              helperText: l10n.panelSliderTemplateHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _sliderJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelSliderJsonPath,
              hintText: l10n.panelSliderJsonPathHint,
            ),
          ),
        ];
      case PanelType.button:
        return [
          TextFormField(
            controller: _buttonPayload,
            decoration:
                InputDecoration(labelText: l10n.panelButtonPayload),
          ),
        ];
      case PanelType.led:
        return [
          TextFormField(
            controller: _ledJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelLedJsonPath,
              hintText: l10n.panelLedJsonPathHint,
              helperText: l10n.panelLedJsonPathHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ledOnMatch,
            decoration: InputDecoration(
              labelText: l10n.panelLedOnMatch,
              helperText: l10n.panelLedOnMatchHelper,
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _ledOnLabel,
                decoration: InputDecoration(
                  labelText: l10n.panelLedOnLabel,
                  hintText: l10n.panelLedOnLabelHint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _ledOffLabel,
                decoration: InputDecoration(
                  labelText: l10n.panelLedOffLabel,
                  hintText: l10n.panelLedOffLabelHint,
                ),
              ),
            ),
          ]),
        ];
      case PanelType.nodeStatus:
        return [
          TextFormField(
            controller: _nodeOnlinePayload,
            decoration: InputDecoration(
              labelText: l10n.panelNodeOnlinePayload,
              helperText: l10n.panelNodeOnlinePayloadHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nodeJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelNodeJsonPath,
              helperText: l10n.panelNodeJsonPathHelper,
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
                decoration:
                    InputDecoration(labelText: l10n.panelProgressMin),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _progressMax,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.panelProgressMax),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _progressUnit,
                decoration: InputDecoration(
                  labelText: l10n.panelProgressUnit,
                  hintText: l10n.panelProgressUnitHint,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _progressJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelProgressJsonPath,
              hintText: l10n.panelProgressJsonPathHint,
              helperText: l10n.panelProgressJsonPathHelper,
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
            l10n.panelCoverDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _coverPresets,
            decoration: InputDecoration(
              labelText: l10n.panelCoverPresets,
              hintText: l10n.panelCoverPresetsHint,
              helperText: l10n.panelCoverPresetsHelper,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelCoverShowSlider),
            value: _coverShowSlider,
            onChanged: (v) => setState(() => _coverShowSlider = v), // ignore: invalid_use_of_protected_member
          ),
        ];
      case PanelType.textInput:
        return [
          TextFormField(
            controller: _textInputHint,
            decoration: InputDecoration(
              labelText: l10n.panelTextInputHint,
              hintText: l10n.panelTextInputHintHint,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _textInputTemplate,
            decoration: InputDecoration(
              labelText: l10n.panelTextInputTemplate,
              helperText: l10n.panelTextInputTemplateHelper,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelTextInputClearAfterSend),
            value: _textInputClearOnSend,
            onChanged: (v) => setState(() => _textInputClearOnSend = v), // ignore: invalid_use_of_protected_member
          ),
        ];
      case PanelType.textLog:
        return [
          TextFormField(
            controller: _textLogMaxLines,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.panelTextLogMaxLines,
              helperText: l10n.panelTextLogMaxLinesHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _textLogJsonPath,
            decoration: InputDecoration(
              labelText: l10n.panelTextLogJsonPath,
              helperText: l10n.panelTextLogJsonPathHelper,
            ),
          ),
        ];
      case PanelType.schedule:
        return [
          Text(
            l10n.panelScheduleDescription,
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
                decoration: InputDecoration(
                  labelText: l10n.panelScheduleOpenTime,
                  suffixIcon: const Icon(Icons.access_time),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _scheduleCloseTime,
                readOnly: true,
                onTap: () => _pickTime(_scheduleCloseTime),
                decoration: InputDecoration(
                  labelText: l10n.panelScheduleCloseTime,
                  suffixIcon: const Icon(Icons.access_time),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleOpenPayload,
            decoration:
                InputDecoration(labelText: l10n.panelScheduleOpenPayload),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _scheduleClosePayload,
            decoration:
                InputDecoration(labelText: l10n.panelScheduleClosePayload),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelScheduleEnabled),
            value: _scheduleEnabled,
            onChanged: (v) => setState(() => _scheduleEnabled = v), // ignore: invalid_use_of_protected_member
          ),
        ];
    }
  }

  List<Widget> _optionsFields() {
    final l10n = context.l10n;
    return [
      TextFormField(
        controller: _optionsJsonPath,
        decoration: InputDecoration(
          labelText: l10n.panelOptionsJsonPath,
          hintText: l10n.panelOptionsJsonPathHint,
          helperText: l10n.panelOptionsJsonPathHelper,
        ),
      ),
      const SizedBox(height: 12),
      Text(l10n.panelOptionsHeader,
          style: Theme.of(context).textTheme.titleSmall),
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
                      decoration: InputDecoration(
                        labelText: l10n.panelOptionsLabel,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _optionRows[i].payload,
                      decoration: InputDecoration(
                        labelText: l10n.panelOptionsPayload,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _optionRows[i].match,
                      decoration: InputDecoration(
                        labelText: l10n.panelOptionsMatch,
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.a11yDeleteOption,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() { // ignore: invalid_use_of_protected_member
                  _optionRows.removeAt(i).dispose();
                }),
              ),
            ],
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.panelOptionsAdd),
          onPressed: () => setState(() => _optionRows.add(_OptionRow())), // ignore: invalid_use_of_protected_member
        ),
      ),
    ];
  }
}
