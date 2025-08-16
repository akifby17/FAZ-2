import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../../../core/auth/token_service.dart';

Future<void> showPieceCutDialog(BuildContext context,
    {String selectedLoomNo = ''}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return PieceCutDialog(selectedLoomNo: selectedLoomNo);
    },
  );
}

class PieceCutDialog extends StatefulWidget {
  final String selectedLoomNo;
  const PieceCutDialog({this.selectedLoomNo = ''});

  @override
  State<PieceCutDialog> createState() => _PieceCutDialogState();
}

class _PieceCutDialogState extends State<PieceCutDialog> {
  final TextEditingController _tezgahController = TextEditingController();
  final TextEditingController _personnelIdController = TextEditingController();
  final TextEditingController _personnelNameController =
      TextEditingController();
  final TextEditingController _topNoController = TextEditingController();
  final TextEditingController _metreController = TextEditingController();
  List<MapEntry<int, String>> _personIndex = <MapEntry<int, String>>[];

  @override
  void initState() {
    super.initState();
    _personnelIdController.addListener(_onIdChanged);
    if (widget.selectedLoomNo.isNotEmpty) {
      _tezgahController.text = widget.selectedLoomNo;
    }
    _loadPersonnels();
  }

  Future<void> _loadPersonnels() async {
    try {
      final String token = await GetIt.I<TokenService>().getToken();
      final loader = LoadPersonnels(GetIt.I<PersonnelRepositoryImpl>());
      final list = await loader(token: token);
      if (!mounted) return;
      setState(() {
        _personIndex = list.map((e) => MapEntry(e.id, e.name)).toList();
      });
    } catch (_) {
      // ignore errors silently for now
    }
  }

  void _onIdChanged() {
    final int? id = int.tryParse(_personnelIdController.text.trim());
    if (id == null) {
      _personnelNameController.text = '';
      return;
    }
    for (final entry in _personIndex) {
      if (entry.key == id) {
        _personnelNameController.text = entry.value;
        return;
      }
    }
    _personnelNameController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'piece_cut_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tezgahController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'label_tezgah'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _personnelIdController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'label_personnel_no'.tr(),
                      border: const OutlineInputBorder(),
                    ),
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
            const SizedBox(height: 12),
            TextField(
              controller: _topNoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'label_top_no'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _metreController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'label_metre'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('action_back'.tr())),
                ElevatedButton(onPressed: () {}, child: Text('action_ok'.tr())),
              ],
            ),
            const SizedBox(height: 12),
            _NumericKeyboard(
              onKey: (d) {
                _personnelIdController.text = _personnelIdController.text + d;
              },
              onBackspace: () {
                final t = _personnelIdController.text;
                if (t.isNotEmpty) {
                  _personnelIdController.text = t.substring(0, t.length - 1);
                }
              },
            ),
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
    return GridView.builder(
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
    );
  }
}
