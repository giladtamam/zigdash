import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/database/tables/connections.dart';
import '../../../data/repositories/connection_repo.dart';
import '../widgets/protocol_dropdown.dart';

class ConnectionFormScreen extends ConsumerStatefulWidget {
  const ConnectionFormScreen({super.key, this.connectionId});

  /// Null for "create", non-null for "edit".
  final String? connectionId;

  @override
  ConsumerState<ConnectionFormScreen> createState() => _ConnectionFormScreenState();
}

class _ConnectionFormScreenState extends ConsumerState<ConnectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _port = TextEditingController(text: '1883');
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _keepAlive = TextEditingController(text: '60');

  MqttProtocol _protocol = MqttProtocol.tcp;
  bool _autoConnect = false;
  bool _loaded = false;
  bool _saving = false;
  bool _passwordExists = false;

  bool get _isEdit => widget.connectionId != null;

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
    final repo = ref.read(connectionRepoProvider);
    final c = await repo.getById(widget.connectionId!);
    if (c == null || !mounted) return;
    final pw = await repo.readPassword(c.id);
    setState(() {
      _name.text = c.name;
      _host.text = c.host;
      _port.text = c.port.toString();
      _protocol = c.protocol;
      _username.text = c.username ?? '';
      _passwordExists = pw != null && pw.isNotEmpty;
      _keepAlive.text = c.keepAliveSeconds.toString();
      _autoConnect = c.autoConnect;
      _loaded = true;
    });
  }

  void _onProtocolChanged(MqttProtocol p) {
    final currentDefault = ProtocolDropdown.defaultPort(_protocol);
    if (_port.text == currentDefault.toString()) {
      _port.text = ProtocolDropdown.defaultPort(p).toString();
    }
    setState(() => _protocol = p);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(connectionRepoProvider);
    final port = int.parse(_port.text);
    final keepAlive = int.parse(_keepAlive.text);
    final passwordToWrite = _password.text.isEmpty && _isEdit ? null : _password.text;

    try {
      if (_isEdit) {
        await repo.update(
          id: widget.connectionId!,
          name: _name.text.trim(),
          host: _host.text.trim(),
          port: port,
          protocol: _protocol,
          username: _username.text.trim().isEmpty ? null : _username.text.trim(),
          password: passwordToWrite,
          keepAliveSeconds: keepAlive,
          autoConnect: _autoConnect,
        );
      } else {
        await repo.create(
          name: _name.text.trim(),
          host: _host.text.trim(),
          port: port,
          protocol: _protocol,
          username: _username.text.trim().isEmpty ? null : _username.text.trim(),
          password: _password.text.isEmpty ? null : _password.text,
          keepAliveSeconds: keepAlive,
          autoConnect: _autoConnect,
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
    _host.dispose();
    _port.dispose();
    _username.dispose();
    _password.dispose();
    _keepAlive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? context.l10n.connEdit : context.l10n.connNew),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? context.l10n.saving : context.l10n.save),
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
              decoration: InputDecoration(labelText: context.l10n.connName, hintText: context.l10n.connNameHint),
              validator: (v) => v == null || v.trim().isEmpty ? context.l10n.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            ProtocolDropdown(value: _protocol, onChanged: _onProtocolChanged),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _host,
                    decoration: InputDecoration(labelText: context.l10n.connHost, hintText: context.l10n.connHostHint),
                    validator: (v) => v == null || v.trim().isEmpty ? context.l10n.fieldRequired : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: context.l10n.connPort),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1 || n > 65535) return context.l10n.connPortRange;
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(labelText: context.l10n.connUsernameOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.connPasswordOptional,
                hintText: _isEdit && _passwordExists ? context.l10n.connPasswordKeepHint : null,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.connAutoConnect),
              value: _autoConnect,
              onChanged: (v) => setState(() => _autoConnect = v),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(context.l10n.advanced),
              children: [
                TextFormField(
                  controller: _keepAlive,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: context.l10n.connKeepAlive),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 5 || n > 3600) return context.l10n.connKeepAliveRange;
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
