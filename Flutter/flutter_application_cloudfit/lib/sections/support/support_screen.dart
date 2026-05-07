import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import 'ticket_detail_screen.dart';

class SupportScreen extends StatefulWidget {
  static const String name = 'support_screen';
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _db = Supabase.instance.client;
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  bool _showForm = false;

  // New ticket form
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = 'duda';
  String _urgency = 'media';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<int?> _currentUserId() async {
    final authId = _db.auth.currentUser?.id;
    if (authId == null) return null;
    final row = await _db
        .from('users')
        .select('user_id')
        .eq('supabase_id', authId)
        .maybeSingle();
    return row?['user_id'] as int?;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = await _currentUserId();
      if (userId == null) return;

      final rows = await _db
          .from('tickets')
          .select('ticket_id,subject,status,category,urgency,created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _tickets = (rows as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty ||
        _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos.')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final userId = await _currentUserId();
      if (userId == null) throw Exception('No autenticado');

      final ticket = await _db.from('tickets').insert({
        'user_id': userId,
        'subject': _subjectCtrl.text.trim(),
        'category': _category,
        'urgency': _urgency,
        'status': 'open',
      }).select('ticket_id').single();

      await _db.from('messages').insert({
        'ticket_id': ticket['ticket_id'],
        'sender_id': userId,
        'content': _messageCtrl.text.trim(),
        'sent_at': DateTime.now().toIso8601String(),
      });

      _subjectCtrl.clear();
      _messageCtrl.clear();
      setState(() {
        _showForm = false;
        _submitting = false;
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket enviado correctamente.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Soporte',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              _showForm ? Icons.close : Icons.add,
              color: AppColors.neonGreen,
            ),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38),
            onPressed: _load,
          ),
        ],
      ),
      body: _showForm
          ? _buildForm()
          : _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.neonGreen))
              : _tickets.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.neonGreen,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: _tickets.length,
                        itemBuilder: (_, i) => _buildCard(_tickets[i]),
                      ),
                    ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Nuevo Ticket',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _label('ASUNTO *'),
        _field(_subjectCtrl, 'Describe tu problema brevemente'),
        const SizedBox(height: 12),
        _label('CATEGORIA *'),
        _dropdown<String>(
          _category,
          {'bug': 'Error / Bug', 'duda': 'Duda', 'sugerencia': 'Sugerencia'},
          (v) => setState(() => _category = v!),
        ),
        const SizedBox(height: 12),
        _label('URGENCIA *'),
        _dropdown<String>(
          _urgency,
          {'baja': 'Baja', 'media': 'Media', 'alta': 'Alta'},
          (v) => setState(() => _urgency = v!),
        ),
        const SizedBox(height: 12),
        _label('DESCRIPCION DETALLADA *'),
        _field(_messageCtrl, 'Explica con detalle tu problema...', maxLines: 5),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Text('Enviar Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildCard(Map<String, dynamic> t) {
    final status = t['status']?.toString() ?? 'open';
    final urgency = t['urgency']?.toString() ?? 'media';
    final urgencyColor = urgency == 'alta'
        ? AppColors.coralOrange
        : urgency == 'media'
            ? const Color(0xFFFFBB00)
            : Colors.white38;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(
              ticketId: t['ticket_id'] as int,
              subject: t['subject']?.toString() ?? ''),
        ),
      ).then((_) => _load()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: urgencyColor, width: 3)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['subject']?.toString() ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Row(children: [
                  _miniChip(t['category']?.toString() ?? '', Colors.white24),
                  const SizedBox(width: 6),
                  _miniChip(status, _statusColor(status)),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ]),
      ),
    );
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
        const Text('Sin tickets aún',
            style: TextStyle(color: Colors.white38, fontSize: 14)),
        const SizedBox(height: 8),
        const Text('Toca + para crear tu primer ticket de soporte.',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
      ]),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'open' => const Color(0xFFFFBB00),
      'in_progress' => AppColors.electricPurple,
      'resolved' => AppColors.neonGreen,
      _ => Colors.white38,
    };
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1)),
      );

  Widget _field(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF555555)),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonGreen),
        ),
      ),
    );
  }

  Widget _dropdown<T>(
      T value, Map<T, String> options, void Function(T?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButton<T>(
        value: value,
        dropdownColor: AppColors.surface,
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        items: options.entries
            .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
