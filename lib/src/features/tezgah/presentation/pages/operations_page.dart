import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../../operation/data/repositories/operation_repository_impl.dart';
import '../../../operation/domain/entities/operation.dart';
import '../../../../core/auth/token_service.dart';

enum ActiveInput { personnel, operation }

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key, this.initialLoomsText = ''});
  final String initialLoomsText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('btn_op_start'.tr())),
      body: _OperationStartForm(initialLoomsText: initialLoomsText),
    );
  }
}

class _OperationStartForm extends StatefulWidget {
  final String initialLoomsText;
  const _OperationStartForm({required this.initialLoomsText});

  @override
  State<_OperationStartForm> createState() => _OperationStartFormState();
}

class _OperationStartFormState extends State<_OperationStartForm> {
  final TextEditingController _loomsController = TextEditingController();
  final TextEditingController _personnelIdController = TextEditingController();
  final TextEditingController _personnelNameController =
      TextEditingController();
  final TextEditingController _operationCodeController =
      TextEditingController();

  List<MapEntry<int, String>> _personIndex = <MapEntry<int, String>>[];
  List<Operation> _operations = <Operation>[];
  Operation? _selectedOperation;
  ActiveInput _activeInput = ActiveInput.personnel;

  @override
  void initState() {
    super.initState();
    _loomsController.text = widget.initialLoomsText;
    _personnelIdController.addListener(_onIdChanged);
    _operationCodeController.addListener(_onOpCodeChanged);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final token = await GetIt.I<TokenService>().getToken();
      // Personeller
      final persons = await LoadPersonnels(GetIt.I<PersonnelRepositoryImpl>())(
          token: token);
      _personIndex = persons.map((e) => MapEntry(e.id, e.name)).toList();
      // Operasyonlar
      _operations = await GetIt.I<OperationRepositoryImpl>().fetchAll(token);
      if (mounted) setState(() {});
    } catch (_) {}
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

  void _onOpCodeChanged() {
    final String code = _operationCodeController.text.trim();
    Operation? match;
    for (final op in _operations) {
      if (op.code == code) {
        match = op;
        break;
      }
    }
    if (match != _selectedOperation) {
      setState(() {
        _selectedOperation = match;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tezgahlar (readOnly ve çok satır)
          TextField(
            controller: _loomsController,
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
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'label_personnel_no'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () =>
                      setState(() => _activeInput = ActiveInput.personnel),
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
          // Operasyon seçimi: serbest kod girişi + dropdown
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _operationCodeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'label_operation_code'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () =>
                      setState(() => _activeInput = ActiveInput.operation),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<Operation>(
                  value: _selectedOperation,
                  isExpanded: true,
                  items: _operations
                      .map((op) => DropdownMenuItem<Operation>(
                            value: op,
                            child: Text('${op.code} - ${op.name}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedOperation = val;
                      if (val != null) {
                        _operationCodeController.text = val.code;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'label_operation_select'.tr(),
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
            onKey: (d) {
              if (_activeInput == ActiveInput.personnel) {
                _appendDigit(_personnelIdController, d);
              } else {
                _appendDigit(_operationCodeController, d);
              }
            },
            onBackspace: () {
              if (_activeInput == ActiveInput.personnel) {
                _backspace(_personnelIdController);
              } else {
                _backspace(_operationCodeController);
              }
            },
          ),
        ],
      ),
    );
  }

  void _appendDigit(TextEditingController c, String d) {
    c.text = c.text + d;
  }

  void _backspace(TextEditingController c) {
    final text = c.text;
    if (text.isNotEmpty) {
      c.text = text.substring(0, text.length - 1);
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
