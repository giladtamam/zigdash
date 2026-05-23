import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../features/settings/providers/settings_controller.dart';
import '../pico_client.dart';
import '../pico_protocol.dart';

const _kAiHost = 'ai_host';
const _kAiPort = 'ai_port';
const _kAiToken = 'ai_token';
const _kAiPath = 'ai_path';
const _kDefaultPort = 18790;
const _kDefaultPath = '/pico/ws';

// ---------------------------------------------------------------------------
// Simple chat message model
// ---------------------------------------------------------------------------

enum _Role { user, assistant, error }

class _ChatMessage {
  _ChatMessage({
    required this.role,
    required this.text,
    this.id,
  });

  final _Role role;
  String text;
  final String? id; // used to dedupe streaming assistant messages
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  // Config
  String _host = '';
  int _port = _kDefaultPort;
  String _token = '';
  String _path = _kDefaultPath;
  bool _configLoaded = false;

  // Client
  PicoClient? _client;
  StreamSubscription<PicoEvent>? _eventSub;
  StreamSubscription<PicoConnectionState>? _stateSub;
  PicoConnectionState _connState = PicoConnectionState.disconnected;

  // Chat state
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // UI
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sendEnabled = false;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(() {
      final enabled = _inputCtrl.text.trim().isNotEmpty &&
          _connState == PicoConnectionState.connected;
      if (enabled != _sendEnabled) setState(() => _sendEnabled = enabled);
    });
    _loadConfig();
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  Future<void> _loadConfig() async {
    final host = _prefs.getString(_kAiHost) ?? '';
    final port = _prefs.getInt(_kAiPort) ?? _kDefaultPort;
    final token = _prefs.getString(_kAiToken) ?? '';
    final path = _prefs.getString(_kAiPath) ?? _kDefaultPath;
    setState(() {
      _host = host;
      _port = port;
      _token = token;
      _path = path;
      _configLoaded = true;
    });
    if (host.isNotEmpty && token.isNotEmpty) {
      _connectClient();
    }
  }

  Future<void> _saveConfig({
    required String host,
    required int port,
    required String token,
    required String path,
  }) async {
    await _prefs.setString(_kAiHost, host);
    await _prefs.setInt(_kAiPort, port);
    await _prefs.setString(_kAiToken, token);
    await _prefs.setString(_kAiPath, path);
    setState(() {
      _host = host;
      _port = port;
      _token = token;
      _path = path;
    });
    _reconnect();
  }

  void _connectClient() {
    _disposeClient();
    final client = PicoClient(
      host: _host,
      port: _port,
      path: _path,
      token: _token,
    );
    _client = client;

    _stateSub = client.connectionState$.listen((state) {
      if (!mounted) return;
      setState(() {
        _connState = state;
        _sendEnabled = _inputCtrl.text.trim().isNotEmpty &&
            state == PicoConnectionState.connected;
      });
    });

    _eventSub = client.events.listen((event) {
      if (!mounted) return;
      _handleEvent(event);
    });

    client.connect();
  }

  void _reconnect() {
    if (_host.isNotEmpty && _token.isNotEmpty) {
      _connectClient();
    }
  }

  void _disposeClient() {
    _eventSub?.cancel();
    _stateSub?.cancel();
    _client?.dispose();
    _client = null;
    _eventSub = null;
    _stateSub = null;
  }

  void _handleEvent(PicoEvent event) {
    setState(() {
      switch (event.type) {
        case PicoEventType.assistantMessage:
          final id = event.id;
          if (id != null) {
            // Find existing bubble by id (streaming update)
            final existing = _messages.where((m) => m.id == id).firstOrNull;
            if (existing != null) {
              existing.text = event.content ?? '';
            } else {
              _messages.add(_ChatMessage(
                role: _Role.assistant,
                text: event.content ?? '',
                id: id,
              ));
            }
          }
          _isTyping = false;
        case PicoEventType.error:
          // Add error bubble
          final msg = event.errorMessage ?? 'Unknown error';
          _messages.add(_ChatMessage(role: _Role.error, text: msg));
          _isTyping = false;
        case PicoEventType.typingStart:
          _isTyping = true;
        case PicoEventType.typingStop:
          _isTyping = false;
        case PicoEventType.pong:
        case PicoEventType.unknown:
          break;
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _client == null) return;
    setState(() {
      _messages.add(_ChatMessage(role: _Role.user, text: text));
      _inputCtrl.clear();
      _sendEnabled = false;
    });
    _client!.send(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _disposeClient();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Setup form dialog
  // ---------------------------------------------------------------------------

  Future<void> _showSetupDialog() async {
    final hostCtrl = TextEditingController(text: _host);
    final portCtrl = TextEditingController(text: _port.toString());
    final tokenCtrl = TextEditingController(text: _token);
    final pathCtrl = TextEditingController(text: _path);
    final formKey = GlobalKey<FormState>();
    final l10n = context.l10n;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.aiSetupTitle),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: hostCtrl,
                  decoration: InputDecoration(labelText: l10n.aiHost),
                  keyboardType: TextInputType.url,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                TextFormField(
                  controller: portCtrl,
                  decoration: InputDecoration(labelText: l10n.aiPort),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1 || n > 65535) return l10n.connPortRange;
                    return null;
                  },
                ),
                TextFormField(
                  controller: tokenCtrl,
                  decoration: InputDecoration(labelText: l10n.aiToken),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                TextFormField(
                  controller: pathCtrl,
                  decoration: const InputDecoration(labelText: 'Path'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(l10n.aiSave),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _saveConfig(
        host: hostCtrl.text.trim(),
        port: int.parse(portCtrl.text.trim()),
        token: tokenCtrl.text.trim(),
        path: pathCtrl.text.trim().isEmpty ? _kDefaultPath : pathCtrl.text.trim(),
      );
    }

    hostCtrl.dispose();
    portCtrl.dispose();
    tokenCtrl.dispose();
    pathCtrl.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!_configLoaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.aiAssistantTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final needsSetup = _host.isEmpty || _token.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAssistantTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.aiSetupTitle,
            onPressed: _showSetupDialog,
          ),
        ],
      ),
      body: needsSetup ? _buildSetupPrompt(l10n) : _buildChat(l10n),
    );
  }

  Widget _buildSetupPrompt(dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n.aiSetupTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: Text(l10n.aiSave),
              onPressed: _showSetupDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat(dynamic l10n) {
    return Column(
      children: [
        _StatusBar(state: _connState, l10n: l10n),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (ctx, index) {
              if (_isTyping && index == _messages.length) {
                return _TypingBubble(text: l10n.aiTyping);
              }
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        _InputRow(
          controller: _inputCtrl,
          sendEnabled: _sendEnabled,
          hint: l10n.aiPrompt,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state, required this.l10n});
  final PicoConnectionState state;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      PicoConnectionState.connecting => (l10n.aiConnecting as String, Colors.orange),
      PicoConnectionState.connected => (l10n.aiConnected as String, Colors.green),
      PicoConnectionState.error => (l10n.aiDisconnected as String, Colors.red),
      PicoConnectionState.disconnected => (l10n.aiDisconnected as String, Colors.grey),
    };

    return Container(
      width: double.infinity,
      color: color.withAlpha(30),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == _Role.user;
    final isError = message.role == _Role.error;
    final scheme = Theme.of(context).colorScheme;

    final bgColor = isError
        ? scheme.errorContainer
        : isUser
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest;

    final textColor = isError
        ? scheme.onErrorContainer
        : isUser
            ? scheme.onPrimaryContainer
            : scheme.onSurface;

    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(vertical: 4),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(16),
            topEnd: const Radius.circular(16),
            bottomStart: isUser ? const Radius.circular(16) : Radius.zero,
            bottomEnd: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
          textAlign: isUser ? TextAlign.end : TextAlign.start,
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsetsDirectional.symmetric(vertical: 4),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.sendEnabled,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sendEnabled;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendEnabled ? onSend() : null,
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: sendEnabled ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}
