import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;
  final String subject;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.subject,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _db = Supabase.instance.client;
  Map<String, dynamic>? _ticket;
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  final _replyCtrl = TextEditingController();
  bool _sending = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final authId = _db.auth.currentUser?.id;
    if (authId == null) return;
    final row = await _db
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    _userId = row?['user_id'] as int?;
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ticket = await _db
          .from('tickets')
          .select('ticket_id,subject,status,category,urgency,created_at')
          .eq('ticket_id', widget.ticketId)
          .single();

      final msgs = await _db
          .from('messages')
          .select('message_id,sender_id,content,sent_at,users!sender_id(name)')
          .eq('ticket_id', widget.ticketId)
          .order('sent_at');

      if (!mounted) return;
      setState(() {
        _ticket = ticket;
        _messages = (msgs as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendReply() async {
    final content = _replyCtrl.text.trim();
    if (content.isEmpty || _userId == null) return;
    setState(() => _sending = true);
    try {
      await _db.from('messages').insert({
        'ticket_id': widget.ticketId,
        'sender_id': _userId,
        'content': content,
        'sent_at': DateTime.now().toIso8601String(),
      });
      _replyCtrl.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _ticket?['status']?.toString() ?? '';
    final statusColor = switch (status) {
      'open' => const Color(0xFFFFBB00),
      'in_progress' => AppColors.electricPurple,
      'resolved' => AppColors.neonGreen,
      _ => Colors.white38,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen))
          : Column(children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.neonGreen,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildMessage(_messages[i]),
                  ),
                ),
              ),
              if (status != 'closed' && status != 'resolved')
                _buildReplyBox(),
            ]),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final senderId = msg['sender_id'] as int?;
    final isMe = senderId == _userId;
    final senderName = (msg['users'] as Map?)?['name']?.toString() ??
        (isMe ? 'Tú' : 'Soporte');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.neonGreen.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
          border: Border.all(
              color: isMe
                  ? AppColors.neonGreen.withValues(alpha: 0.3)
                  : Colors.white12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(senderName,
                style: TextStyle(
                    color: isMe ? AppColors.neonGreen : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(msg['content']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _replyCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppColors.cardGrey,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _sending ? null : _sendReply,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.send_rounded,
                    color: Colors.black, size: 18),
          ),
        ),
      ]),
    );
  }
}
