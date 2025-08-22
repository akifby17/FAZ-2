import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../domain/usecases/change_weaver.dart';
import 'package:faz2/src/core/auth/token_service.dart';

class WeavingPage extends StatelessWidget {
  const WeavingPage({super.key, this.initialLoomsText = ''});

  final String initialLoomsText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('btn_weaver'.tr())),
      body: _WeaverForm(initialLoomsText: initialLoomsText),
    );
  }
}

class _WeaverForm extends StatefulWidget {
  final String initialLoomsText;
  const _WeaverForm({this.initialLoomsText = ''});
  @override
  State<_WeaverForm> createState() => _WeaverFormState();
}

class _WeaverFormState extends State<_WeaverForm> {
  final TextEditingController _tezgahController = TextEditingController();
  final TextEditingController _personnelIdController = TextEditingController();
  final TextEditingController _personnelNameController =
      TextEditingController();
  final FocusNode _idFocus = FocusNode();
  List<MapEntry<int, String>> _personnelIndex = <MapEntry<int, String>>[];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _personnelIdController.addListener(_onIdChanged);
    _loadPersonnels();
    // initial looms
    if (widget.initialLoomsText.isNotEmpty) {
      _tezgahController.text = widget.initialLoomsText;
    }
  }

  Future<void> _loadPersonnels() async {
    try {
      final token = await GetIt.I<TokenService>().getToken();
      final loader = LoadPersonnels(GetIt.I<PersonnelRepositoryImpl>());
      final list = await loader(token: token);
      setState(() {
        _personnelIndex = list.map((e) => MapEntry(e.id, e.name)).toList();
      });
    } catch (_) {
      // ignore
    }
  }

  void _onIdChanged() {
    final String raw = _personnelIdController.text.trim();
    final int? id = int.tryParse(raw);
    if (id == null) {
      _personnelNameController.text = '';
      return;
    }
    for (final entry in _personnelIndex) {
      if (entry.key == id) {
        _personnelNameController.text = entry.value;
        return;
      }
    }
    _personnelNameController.text = '';
  }

  Future<void> _changeWeavers() async {
    final String personnelIdText = _personnelIdController.text.trim();
    final String tezgahText = _tezgahController.text.trim();

    if (personnelIdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validation_personnel_required'.tr())),
      );
      return;
    }

    if (tezgahText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validation_loom_required'.tr())),
      );
      return;
    }

    final int? weaverId = int.tryParse(personnelIdText);
    if (weaverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validation_personnel_invalid'.tr())),
      );
      return;
    }

    // Tezgah numaralarını ayır (virgülle ayrılmış)
    final List<String> loomNumbers = tezgahText
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (loomNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validation_no_looms'.tr())),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Progress dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProgressDialog(
        totalLooms: loomNumbers.length,
        currentLoom: 0,
      ),
    );

    try {
      final String token = await GetIt.I<TokenService>().getToken();
      final ChangeWeaver changeWeaver = GetIt.I<ChangeWeaver>();

      List<String> successLooms = [];
      List<String> failedLooms = [];

      // Her tezgah için sırayla API çağrısı yap
      for (int i = 0; i < loomNumbers.length; i++) {
        final String loomNo = loomNumbers[i];

        // Progress dialog'ı güncelle
        Navigator.of(context).pop(); // Eski dialog'ı kapat
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _ProgressDialog(
            totalLooms: loomNumbers.length,
            currentLoom: i + 1,
            currentLoomNo: loomNo,
          ),
        );

        try {
          await changeWeaver(
            token: token,
            loomNo: loomNo,
            weaverId: weaverId,
          );
          successLooms.add(loomNo);
        } catch (e) {
          failedLooms.add(loomNo);
        }

        // Kısa bir gecikme ekle (çok hızlı geçmesin)
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Progress dialog'ı kapat
      Navigator.of(context).pop();

      // Sonuç dialog'ını göster
      await _showResultDialog(successLooms, failedLooms);

      // Başarılı olduysa formu temizle ve geri dön
      if (failedLooms.isEmpty) {
        // Ana sayfaya dön ve refresh yap (result olarak true döndür)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Progress dialog'ı kapat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'error_occurred'.tr()}: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _showResultDialog(
      List<String> successLooms, List<String> failedLooms) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('weaver_change_result'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (successLooms.isNotEmpty) ...[
              Text(
                  '✅ ${'weaver_change_successful'.tr()} (${successLooms.length}):',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              Text(successLooms.join(', ')),
              const SizedBox(height: 8),
            ],
            if (failedLooms.isNotEmpty) ...[
              Text('❌ ${'weaver_change_failed'.tr()} (${failedLooms.length}):',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Text(failedLooms.join(', ')),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('action_ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tezgahController.dispose();
    _personnelIdController.dispose();
    _personnelNameController.dispose();
    _idFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _tezgahController,
            readOnly: true,
            minLines: 1,
            maxLines: 8,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              labelText: 'label_looms'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _personnelIdController,
                  focusNode: _idFocus,
                  readOnly: true, // Özel numerik klavye kullanılacak
                  decoration: InputDecoration(
                    labelText: 'label_personnel_no'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () => _idFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _personnelNameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'label_personnel_name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed:
                      _isProcessing ? null : () => Navigator.of(context).pop(),
                  child: Text('action_back'.tr())),
              ElevatedButton(
                onPressed: _isProcessing ? null : _changeWeavers,
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('action_ok'.tr()),
              ),
            ],
          ),
          const Spacer(),
          _NumericKeyboard(
            onKey: _isProcessing ? (_) {} : _appendDigit,
            onBackspace: _isProcessing ? () {} : _backspace,
          ),
        ],
      ),
    );
  }

  void _appendDigit(String d) {
    _personnelIdController.text = _personnelIdController.text + d;
  }

  void _backspace() {
    final text = _personnelIdController.text;
    if (text.isNotEmpty) {
      _personnelIdController.text = text.substring(0, text.length - 1);
    }
  }
}

class _ProgressDialog extends StatelessWidget {
  final int totalLooms;
  final int currentLoom;
  final String? currentLoomNo;

  const _ProgressDialog({
    required this.totalLooms,
    required this.currentLoom,
    this.currentLoomNo,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentLoom / totalLooms;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'weaver_change_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$currentLoom / $totalLooms',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (currentLoomNo != null) ...[
              const SizedBox(height: 8),
              Text(
                '${'label_tezgah'.tr()}: $currentLoomNo',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NumericKeyboard extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback onBackspace;

  const _NumericKeyboard({required this.onKey, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final List<String> keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '*',
      '0',
      '<'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final k = keys[index];
          return ElevatedButton(
            onPressed: () {
              if (k == '<') {
                onBackspace();
              } else if (k != '*') {
                onKey(k);
              }
            },
            child: Text(k, style: const TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }
}
