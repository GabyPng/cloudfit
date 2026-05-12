import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class CertificateUploadWidget extends StatefulWidget {
  final List<Map<String, dynamic>> initialCertificates;
  final void Function(List<Map<String, dynamic>> certs) onUploaded;
  final String role;
  final int userId;

  const CertificateUploadWidget({
    super.key,
    required this.initialCertificates,
    required this.onUploaded,
    required this.role,
    required this.userId,
  });

  @override
  State<CertificateUploadWidget> createState() =>
      _CertificateUploadWidgetState();
}

class _CertificateUploadWidgetState extends State<CertificateUploadWidget> {
  static const _bucket = 'certificates';
  static const _maxFiles = 3;
  static const _maxBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = ['png', 'jpg', 'jpeg', 'webp', 'pdf'];

  late List<Map<String, dynamic>> _certs;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _certs = List.from(widget.initialCertificates);
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null) return;

    final remaining = _maxFiles - _certs.length;
    if (result.files.length > remaining) {
      _snack('Puedes agregar hasta $_maxFiles certificados en total.');
      return;
    }

    for (final f in result.files) {
      final ext = (f.extension ?? '').toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        _snack('Formato no permitido: ${f.name}');
        return;
      }
      if (f.size > _maxBytes) {
        _snack('Archivo demasiado grande: ${f.name} (máx 5MB)');
        return;
      }
    }

    setState(() => _uploading = true);
    try {
      final storage =
          Supabase.instance.client.storage.from(_bucket);
      final uploaded = <Map<String, dynamic>>[];

      for (final f in result.files) {
        final bytes = f.bytes;
        if (bytes == null) continue;

        final sanitized =
            f.name.replaceAll(RegExp(r'\s+'), '-').toLowerCase();
        final path =
            '${widget.role}/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}-$sanitized';

        await storage.uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: _contentType(f.extension),
          ),
        );

        uploaded.add({
          'name': f.name,
          'path': path,
          'type': _contentType(f.extension),
          'size': f.size,
        });
      }

      final merged = [..._certs, ...uploaded];
      setState(() {
        _certs = merged;
        _uploading = false;
      });
      widget.onUploaded(merged);
      _snack('${uploaded.length} archivo(s) subido(s).');
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        _snack('Error al subir: $e');
      }
    }
  }

  void _remove(int index) {
    final updated = List<Map<String, dynamic>>.from(_certs)..removeAt(index);
    setState(() => _certs = updated);
    widget.onUploaded(updated);
  }

  String _contentType(String? ext) {
    return switch ((ext ?? '').toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        OutlinedButton.icon(
          onPressed: (_uploading || _certs.length >= _maxFiles)
              ? null
              : _pick,
          icon: _uploading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.neonGreen))
              : const Icon(Icons.upload_file, color: AppColors.neonGreen, size: 18),
          label: Text(
            _uploading
                ? 'Subiendo...'
                : _certs.isEmpty
                    ? 'Seleccionar archivos'
                    : 'Agregar más',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF2A2A2A)),
            backgroundColor: AppColors.surface,
          ),
        ),
        const SizedBox(width: 10),
        Text('${_certs.length}/$_maxFiles',
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ]),
      const SizedBox(height: 6),
      const Text('PNG, JPG, WEBP, PDF — máx 5 MB c/u',
          style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
      if (_certs.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _certs.asMap().entries.map((e) {
            return _thumb(e.key, e.value);
          }).toList(),
        ),
      ],
    ]);
  }

  Widget _thumb(int index, Map<String, dynamic> cert) {
    final name = cert['name']?.toString() ?? 'Archivo';
    final type = cert['type']?.toString() ?? '';
    final isPdf = type.contains('pdf') || name.toLowerCase().endsWith('.pdf');
    final sizeKb = ((cert['size'] as int? ?? 0) / 1024).toStringAsFixed(0);

    return Container(
      width: 110,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: double.infinity,
            height: 70,
            color: AppColors.cardGrey,
            child: Center(
              child: isPdf
                  ? const Icon(Icons.picture_as_pdf,
                      color: AppColors.coralOrange, size: 36)
                  : const Icon(Icons.image_outlined,
                      color: Colors.white38, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        Text('$sizeKb KB',
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _remove(index),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.coralOrange,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Quitar', style: TextStyle(fontSize: 10)),
          ),
        ),
      ]),
    );
  }
}
