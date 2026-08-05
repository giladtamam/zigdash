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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                  Row(
                    children: [
                      Text(
                        l10n.previewTitle,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const Spacer(),
                      rawAsync.when(
                        data: (raw) {
                          final rawStr = raw?.toString() ?? '';
                          return _buildPreviewValue(rawStr, jsonPath);
                        },
                        loading: () => const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
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
                  const SizedBox(height: 8),
                  _buildVisualPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewValue(String rawStr, String jsonPath) {
    if (rawStr.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    if (jsonPath.isNotEmpty) {
      final extracted = extractByPath(rawStr, jsonPath);
      return Text(
        extracted?.toString() ?? '',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontFamily: 'monospace',
        ),
      );
    }
    return Text(
      rawStr,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.outline,
        fontFamily: 'monospace',
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVisualPreview() {
    final name = _name.text.isEmpty ? 'Panel' : _name.text;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget panelContent;
    switch (_type) {
      case PanelType.toggle:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.toggle_off, color: cs.outline, size: 32),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
          ],
        );
      case PanelType.slider:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        );
      case PanelType.cover:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blinds_closed, color: cs.primary, size: 28),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_upward, size: 16),
              label: const Text('OPEN'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        );
      case PanelType.button:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send, color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('SEND'),
            ),
          ],
        );
      case PanelType.led:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: 0.3),
                border: Border.all(color: cs.outline, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
          ],
        );
      case PanelType.nodeStatus:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: cs.outline, size: 24),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text('offline', style: theme.textTheme.bodySmall?.copyWith(color: cs.error)),
          ],
        );
      case PanelType.progress:
        panelContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.6,
                      minHeight: 8,
                      backgroundColor: cs.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('60%', style: theme.textTheme.labelMedium),
              ],
            ),
          ],
        );
      case PanelType.multiState:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_week, color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
            const Spacer(),
            for (final o in _optionRows.take(3))
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ActionChip(
                  label: Text(o.label.text, style: const TextStyle(fontSize: 10)),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
              ),
          ],
        );
      case PanelType.textLog:
        panelContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(name, style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Waiting for messages...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      default:
        panelContent = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_panelTypeIcon(_type), color: cs.primary, size: 24),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.bodyMedium),
          ],
        );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cs.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: panelContent,
        ),
      ),
    );
  }

  IconData _panelTypeIcon(PanelType type) => switch (type) {
        PanelType.toggle => Icons.toggle_on,
        PanelType.slider => Icons.tune,
        PanelType.cover => Icons.blinds_closed,
        PanelType.button => Icons.send,
        PanelType.led => Icons.circle,
        PanelType.nodeStatus => Icons.cloud_done,
        PanelType.progress => Icons.battery_5_bar,
        PanelType.multiState => Icons.view_week,
        PanelType.combo => Icons.arrow_drop_down_circle_outlined,
        PanelType.radio => Icons.radio_button_checked,
        PanelType.textInput => Icons.keyboard,
        PanelType.textLog => Icons.notes,
        PanelType.schedule => Icons.schedule,
        PanelType.scene => Icons.auto_awesome,
        PanelType.autoClose => Icons.timer_outlined,
      };

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
      case PanelType.scene:
        // Scene panels are configured from the Scenes screen ("Add to
        // dashboard"); the generic form only edits name/width here.
        return const [];
      case PanelType.autoClose:
        return [
          Text(
            l10n.panelAutoCloseDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseTriggerPath,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseTriggerPath,
              helperText: l10n.panelAutoCloseTriggerPathHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseTriggerValue,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseTriggerValue,
              helperText: l10n.panelAutoCloseTriggerValueHelper,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseClosePayload,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseClosePayload,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _autoCloseDelaySeconds,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.panelAutoCloseDelaySeconds,
              helperText: l10n.panelAutoCloseDelaySecondsHelper,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.panelAutoCloseEnabled),
            value: _autoCloseEnabled,
            onChanged: (v) => setState(() => _autoCloseEnabled = v), // ignore: invalid_use_of_protected_member
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
