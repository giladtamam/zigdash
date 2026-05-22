import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/repositories/dashboard_repo.dart';

const _swatches = <Color>[
  Color(0xFF3B82F6), // blue (default)
  Color(0xFFF59E0B), // amber
  Color(0xFFEF4444), // red
  Color(0xFF10B981), // emerald
  Color(0xFF8B5CF6), // purple
  Color(0xFF06B6D4), // cyan
];

const _icons = <IconData>[
  Icons.dashboard,
  Icons.lightbulb,
  Icons.bed,
  Icons.kitchen,
  Icons.tv,
  Icons.window,
  Icons.thermostat,
  Icons.outdoor_grill,
];

class DashboardFormScreen extends ConsumerStatefulWidget {
  const DashboardFormScreen({
    super.key,
    required this.connectionId,
    this.dashboardId,
  });

  final String connectionId;
  final String? dashboardId;

  @override
  ConsumerState<DashboardFormScreen> createState() => _State();
}

class _State extends ConsumerState<DashboardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _topicPrefix = TextEditingController();

  Color _color = _swatches.first;
  IconData _icon = _icons.first;
  bool _locked = false;
  bool _loaded = false;
  bool _saving = false;

  bool get _isEdit => widget.dashboardId != null;

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
    final d = await ref.read(dashboardRepoProvider).getById(widget.dashboardId!);
    if (d == null || !mounted) return;
    setState(() {
      _name.text = d.name;
      _topicPrefix.text = d.topicPrefix ?? '';
      _color = Color(d.colorSeed);
      _icon = IconData(d.iconCodepoint, fontFamily: 'MaterialIcons');
      _locked = d.locked;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(dashboardRepoProvider);
    final prefix = _topicPrefix.text.trim().isEmpty ? null : _topicPrefix.text.trim();
    try {
      if (_isEdit) {
        await repo.update(
          id: widget.dashboardId!,
          name: _name.text.trim(),
          topicPrefix: prefix,
          colorSeed: _color.toARGB32(),
          iconCodepoint: _icon.codePoint,
          locked: _locked,
        );
      } else {
        await repo.create(
          connectionId: widget.connectionId,
          name: _name.text.trim(),
          topicPrefix: prefix,
          colorSeed: _color.toARGB32(),
          iconCodepoint: _icon.codePoint,
          locked: _locked,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _topicPrefix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.dashFormEdit : l10n.dashFormNew),
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
              decoration: InputDecoration(labelText: l10n.dashFormName, hintText: l10n.dashFormNameHint),
              validator: (v) => v == null || v.trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _topicPrefix,
              decoration: InputDecoration(
                labelText: l10n.dashFormTopicPrefix,
                hintText: l10n.dashFormTopicPrefixHint,
                helperText: l10n.dashFormTopicPrefixHelper,
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.dashFormColorSeed, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _swatches.map((c) {
                final selected = c.toARGB32() == _color.toARGB32();
                return Semantics(
                  label: context.l10n.a11ySelectColor,
                  button: true,
                  selected: selected,
                  child: GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Theme.of(context).colorScheme.outline, width: 3)
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.dashFormIcon, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _icons.map((i) {
                final selected = i.codePoint == _icon.codePoint;
                return Semantics(
                  label: context.l10n.a11ySelectIcon,
                  button: true,
                  selected: selected,
                  child: GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(i),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dashFormLock),
              subtitle: Text(l10n.dashFormLockSubtitle),
              value: _locked,
              onChanged: (v) => setState(() => _locked = v),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.dashFormDelete),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.dashDeleteTitle),
                      content: Text(l10n.dashDeleteContent),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                        FilledButton.tonal(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.dashDeleteConfirm)),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await ref.read(dashboardRepoProvider).delete(widget.dashboardId!);
                  if (!context.mounted) return;
                  context.pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
