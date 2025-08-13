import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('action_back'.tr())),
              ElevatedButton(onPressed: () {}, child: Text('action_ok'.tr())),
            ],
          ),
          const Spacer(),
          _NumericKeyboard(
            onKey: _appendDigit,
            onBackspace: _backspace,
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
