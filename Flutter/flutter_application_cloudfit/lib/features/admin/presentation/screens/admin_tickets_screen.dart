import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../data/admin_api.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String? _statusFilter;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminApi.getTickets(
        status: _statusFilter,
        category: _categoryFilter,
      );
      if (!mounted) return;
      setState(() {
        _tickets = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildFilters(),
      Expanded(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen))
            : _tickets.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppColors.neonGreen,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: _tickets.length,
                      itemBuilder: (_, i) => _buildCard(_tickets[i]),
                    ),
                  ),
      ),
    ]);
  }

  Widget _buildFilters() {
    final statuses = [null, 'open', 'in_progress', 'resolved'];
    final categories = [null, 'bug', 'duda', 'sugerencia'];
    final statusLabels = {
      null: 'Todos',
      'open': 'Abiertos',
      'in_progress': 'En proceso',
      'resolved': 'Resueltos',
    };
    final catLabels = {
      null: 'Categoria',
      'bug': 'Bug',
      'duda': 'Duda',
      'sugerencia': 'Sugerencia',
    };

    return Column(children: [
      const SizedBox(height: 8),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: statuses.map((s) {
            final sel = _statusFilter == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _filterChip(statusLabels[s]!, sel, () {
                setState(() => _statusFilter = s);
                _load();
              }),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: categories.map((c) {
            final sel = _categoryFilter == c;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _filterChip(catLabels[c]!, sel, () {
                setState(() => _categoryFilter = c);
                _load();
              }, small: true),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 4),
    ]);
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap,
      {bool small = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: small ? 5 : 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonGreen.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.neonGreen : Colors.white12),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppColors.neonGreen : Colors.white54,
              fontSize: small ? 11 : 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> t) {
    final urgency = t['urgency']?.toString() ?? 'media';
    final status = t['status']?.toString() ?? 'open';
    final urgencyColor = urgency == 'alta'
        ? AppColors.coralOrange
        : urgency == 'media'
            ? const Color(0xFFFFBB00)
            : Colors.white38;
    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () => _openDetail(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: urgencyColor, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(t['subject']?.toString() ?? '—',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person_outline,
                size: 12, color: Colors.white38),
            const SizedBox(width: 4),
            Text(t['user_name']?.toString() ?? '—',
                style:
                    const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(width: 12),
            _catBadge(t['category']?.toString()),
            const SizedBox(width: 6),
            _urgencyBadge(urgency, urgencyColor),
          ]),
        ]),
      ),
    );
  }

  Widget _catBadge(String? cat) {
    final label = switch (cat) {
      'bug' => 'Bug',
      'duda' => 'Duda',
      'sugerencia' => 'Sugerencia',
      _ => '—',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 9)),
    );
  }

  Widget _urgencyBadge(String urgency, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(urgency.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'open' => const Color(0xFFFFBB00),
      'in_progress' => AppColors.electricPurple,
      'resolved' => AppColors.neonGreen,
      'closed' => Colors.white38,
      _ => Colors.white38,
    };
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: AppColors.surface, shape: BoxShape.circle),
          child: const Icon(Icons.support_agent_outlined,
              color: Colors.white24, size: 44),
        ),
        const SizedBox(height: 16),
        const Text('Sin tickets',
            style: TextStyle(color: Colors.white38, fontSize: 14)),
      ]),
    );
  }

  void _openDetail(Map<String, dynamic> ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TicketDetailPage(ticketId: ticket['ticket_id'] as int),
      ),
    ).then((_) => _load());
  }
}

class _TicketDetailPage extends StatefulWidget {
  final int ticketId;
  const _TicketDetailPage({required this.ticketId});

  @override
  State<_TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<_TicketDetailPage> {
  Map<String, dynamic>? _ticket;
  bool _loading = true;
  final _replyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await AdminApi.getTicketDetail(widget.ticketId);
      if (!mounted) return;
      setState(() {
        _ticket = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendReply() async {
    final content = _replyCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() => _sending = true);
    try {
      await AdminApi.replyToTicket(widget.ticketId, content);
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

  Future<void> _changeStatus(String status) async {
    await AdminApi.updateTicketStatus(widget.ticketId, status);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_ticket?['subject']?.toString() ?? 'Ticket',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_ticket != null)
            PopupMenuButton<String>(
              color: AppColors.surface,
              onSelected: _changeStatus,
              itemBuilder: (_) => [
                'open', 'in_progress', 'resolved', 'closed',
              ]
                  .map((s) => PopupMenuItem(
                      value: s,
                      child: Text(s,
                          style: const TextStyle(color: Colors.white))))
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  const Icon(Icons.tune, color: Colors.white54, size: 18),
                  const SizedBox(width: 4),
                  Text(_ticket!['status']?.toString() ?? '',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ]),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonGreen))
          : Column(children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfo(),
                    const SizedBox(height: 12),
                    ...(_ticket?['messages'] as List? ?? [])
                        .map((m) => _buildMessage(m as Map)),
                  ],
                ),
              ),
              _buildReplyBox(),
            ]),
    );
  }

  Widget _buildInfo() {
    final t = _ticket!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('De: ${t['user_name']} (${t['user_email']})',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        Row(children: [
          _infoChip(t['category']?.toString() ?? ''),
          const SizedBox(width: 6),
          _infoChip(t['urgency']?.toString() ?? ''),
          const SizedBox(width: 6),
          _infoChip(t['status']?.toString() ?? ''),
        ]),
      ]),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 10)),
    );
  }

  Widget _buildMessage(Map msg) {
    final isAdmin = msg['sender_id'] != _ticket?['user_id'];
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isAdmin
              ? AppColors.neonGreen.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isAdmin
                  ? AppColors.neonGreen.withValues(alpha: 0.3)
                  : Colors.white12),
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg['sender_name']?.toString() ?? '—',
                style: TextStyle(
                    color: isAdmin ? AppColors.neonGreen : Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(msg['content']?.toString() ?? '',
                style:
                    const TextStyle(color: Colors.white, fontSize: 13)),
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
        border:
            Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _replyCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Responder...',
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
