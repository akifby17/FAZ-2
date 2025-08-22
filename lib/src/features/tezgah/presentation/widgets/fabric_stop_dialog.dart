import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../../../core/network/api_client.dart';

enum ActiveField { personnel, orderNo }

class FabricStopDialog extends StatefulWidget {
  final String initialLoomsText;
  const FabricStopDialog({super.key, this.initialLoomsText = ''});

  @override
  State<FabricStopDialog> createState() => _FabricStopDialogState();
}

class _FabricStopDialogState extends State<FabricStopDialog> {
  final TextEditingController _loomsController = TextEditingController();
  final TextEditingController _personnelIdController = TextEditingController();
  final TextEditingController _personnelNameController =
      TextEditingController();
  final TextEditingController _orderNoController = TextEditingController();
  List<MapEntry<int, String>> _personIndex = <MapEntry<int, String>>[];
  bool _isLoadingWorkOrder = false;
  bool _isSubmitting = false;
  ActiveField _activeField = ActiveField.personnel;

  @override
  void initState() {
    super.initState();
    _personnelIdController.addListener(_onIdChanged);
    _personnelIdController.addListener(_onFormChanged);
    _orderNoController.addListener(_onFormChanged);
    _loomsController.addListener(_onFormChanged);
    if (widget.initialLoomsText.isNotEmpty) {
      _loomsController.text = widget.initialLoomsText;
      // Tek tezgah seçiliyse current work order'ı getir
      final loomNumbers = widget.initialLoomsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (loomNumbers.length == 1) {
        _loadCurrentWorkOrder(loomNumbers.first);
      }
    }
    _loadPersonnels();
  }

  Future<void> _loadCurrentWorkOrder(String loomNo) async {
    setState(() => _isLoadingWorkOrder = true);
    try {
      final apiClient = GetIt.I<ApiClient>();

      final response = await apiClient.get(
        '/api/style-work-orders/current/$loomNo',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.data != null && response.data['workOrderNo'] != null) {
        if (mounted) {
          setState(() {
            _orderNoController.text = response.data['workOrderNo'].toString();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mevcut iş emri alınamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingWorkOrder = false);
      }
    }
  }

  Future<void> _loadPersonnels() async {
    try {
      final loader = LoadPersonnels(GetIt.I<PersonnelRepositoryImpl>());
      final list = await loader();
      if (!mounted) return;
      setState(() {
        _personIndex = list.map((e) => MapEntry(e.id, e.name)).toList();
      });
    } catch (_) {
      // ignore
    }
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {
        // Form validasyonunu güncelle
      });
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

  bool _isValidForm() {
    return _personnelIdController.text.trim().isNotEmpty &&
        _loomsController.text.trim().isNotEmpty;
  }

  // Ortak submit metodu - status parametresi ile hangi işlem olduğunu belirler
  Future<void> _submitFabricOperation({
    required int status, // 0: başlat, 1: bitir, 2: durdur
    required String successMessage,
    required String errorMessage,
    Color successColor = Colors.green,
  }) async {
    if (!_isValidForm() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final apiClient = GetIt.I<ApiClient>();

      final String orderNoText = _orderNoController.text.trim();
      final int styleWorkOrderNo =
          orderNoText.isEmpty ? 0 : int.parse(orderNoText);

      final requestData = {
        'loomNo': _loomsController.text.trim(),
        'personnelID': int.parse(_personnelIdController.text.trim()),
        'styleWorkOrderNo': styleWorkOrderNo,
        'status': status,
      };

      print("Kumaş işlemi isteği (status: $status): $requestData");

      final response = await apiClient.post(
        '/api/DataMan/styleWorkOrderStartStopPause',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print("Response: ${response.data}");

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: successColor,
          ),
        );
      }
    } catch (e) {
      print("Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _personnelIdController.removeListener(_onIdChanged);
    _personnelIdController.removeListener(_onFormChanged);
    _orderNoController.removeListener(_onFormChanged);
    _loomsController.removeListener(_onFormChanged);
    super.dispose();
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
              'fabric_stop_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loomsController,
              readOnly: true,
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
                    onTap: () {
                      setState(() {
                        _activeField = ActiveField.personnel;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'label_personnel_no'.tr(),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _activeField == ActiveField.personnel
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          width: _activeField == ActiveField.personnel ? 2 : 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
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
              controller: _orderNoController,
              readOnly: true,
              onTap: () {
                setState(() {
                  _activeField = ActiveField.orderNo;
                });
              },
              decoration: InputDecoration(
                labelText: 'label_fabric_order_no'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _activeField == ActiveField.orderNo
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    width: _activeField == ActiveField.orderNo ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: _isLoadingWorkOrder
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('action_back'.tr())),
                ElevatedButton(
                  onPressed: (_isValidForm() && !_isSubmitting)
                      ? () => _submitFabricOperation(
                            status: 2, // Durdurma
                            successMessage:
                                'Kumaş iş emri başarıyla durduruldu',
                            errorMessage: 'Kumaş iş emri durdurulamadı',
                            successColor: Colors.orange,
                          )
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('action_ok'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumericKeyboard(
              onKey: (d) {
                if (_activeField == ActiveField.personnel) {
                  _personnelIdController.text = _personnelIdController.text + d;
                } else if (_activeField == ActiveField.orderNo) {
                  _orderNoController.text = _orderNoController.text + d;
                }
              },
              onBackspace: () {
                if (_activeField == ActiveField.personnel) {
                  final t = _personnelIdController.text;
                  if (t.isNotEmpty) {
                    _personnelIdController.text = t.substring(0, t.length - 1);
                  }
                } else if (_activeField == ActiveField.orderNo) {
                  final t = _orderNoController.text;
                  if (t.isNotEmpty) {
                    _orderNoController.text = t.substring(0, t.length - 1);
                  }
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
