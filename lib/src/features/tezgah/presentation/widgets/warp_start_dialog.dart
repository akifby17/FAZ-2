import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../../../core/auth/token_service.dart';
import '../../../../core/network/api_client.dart';

enum ActiveField { personnel, orderNo }

class WarpStartDialog extends StatefulWidget {
  final String initialLoomsText;
  const WarpStartDialog({super.key, this.initialLoomsText = ''});

  @override
  State<WarpStartDialog> createState() => _WarpStartDialogState();
}

class _WarpStartDialogState extends State<WarpStartDialog> {
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
    print("WarpStartDialog initState başladı");
    _personnelIdController.addListener(_onIdChanged);
    _personnelIdController.addListener(_onFormChanged);
    _orderNoController.addListener(_onFormChanged);
    _loomsController.addListener(_onFormChanged);
    if (widget.initialLoomsText.isNotEmpty) {
      print("initialLoomsText: ${widget.initialLoomsText}");
      _loomsController.text = widget.initialLoomsText;
      // Tek tezgah seçiliyse warp order'ı getir
      final loomNumbers = widget.initialLoomsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print("Loom numbers: $loomNumbers");
      if (loomNumbers.length == 1) {
        print("Tek tezgah var, API çağrısı yapılacak: ${loomNumbers.first}");
        _loadWarpOrder(loomNumbers.first);
      } else {
        print(
            "Tek tezgah yok, API çağrısı yapılmayacak. Sayı: ${loomNumbers.length}");
      }
    } else {
      print("initialLoomsText boş");
    }
    _loadPersonnels();
  }

  Future<void> _loadWarpOrder(String loomNo) async {
    print("_loadWarpOrder called with loomNo: $loomNo");
    setState(() => _isLoadingWorkOrder = true);
    try {
      final String token = await GetIt.I<TokenService>().getToken();
      print("Token alındı: ${token.substring(0, 20)}...");

      // API çağrısı - Warp next endpoint
      final apiClient = GetIt.I<ApiClient>();

      print("API çağrısı yapılıyor: /api/warps/next/$loomNo");
      final response = await apiClient.get(
        '/api/warps/next/$loomNo',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print("Response alındı!");
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.data != null && response.data['workOrderNo'] != null) {
        print("WorkOrderNo: ${response.data['workOrderNo']}");
        if (mounted) {
          setState(() {
            _orderNoController.text = response.data['workOrderNo'].toString();
            // Form validasyonunu tetikle - TAMAM butonunu güncelle
          });
        }
      } else {
        print("Response data boş veya workOrderNo yok");
      }
    } catch (e) {
      print("API Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çözgü iş emri alınamadı: $e')),
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
      final String token = await GetIt.I<TokenService>().getToken();
      final loader = LoadPersonnels(GetIt.I<PersonnelRepositoryImpl>());
      final list = await loader(token: token);
      if (!mounted) return;
      setState(() {
        _personIndex = list.map((e) => MapEntry(e.id, e.name)).toList();
      });
    } catch (_) {
      // ignore
    }
  }

  bool _isValidForm() {
    return _personnelIdController.text.trim().isNotEmpty &&
        _loomsController.text.trim().isNotEmpty;
  }

  Future<void> _submitWarpStart() async {
    if (!_isValidForm() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final String token = await GetIt.I<TokenService>().getToken();
      final apiClient = GetIt.I<ApiClient>();

      final String orderNoText = _orderNoController.text.trim();
      final int warpWorkOrderNo =
          orderNoText.isEmpty ? 0 : int.parse(orderNoText);

      final requestData = {
        'loomNo': _loomsController.text.trim(),
        'personnelID': int.parse(_personnelIdController.text.trim()),
        'warpWorkOrderNo': warpWorkOrderNo,
        'status': 0, // Başlatma
      };

      print("Çözgü başlatma isteği: $requestData");

      final response = await apiClient.post(
        '/api/DataMan/warpWorkOrderStartStopPause',
        data: requestData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print("Response: ${response.data}");

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çözgü iş emri başarıyla başlatıldı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çözgü iş emri başlatılamadı: $e'),
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

  void _onFormChanged() {
    // Form değiştiğinde UI'ı güncelle - TAMAM butonunu aktifleştir
    if (mounted) {
      setState(() {
        // Sadece setState çağır, form validasyonu _isValidForm() ile yapılıyor
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
              'warp_start_title'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                labelText: 'label_warp_order_no'.tr(),
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
                    ? Padding(
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
                      ? _submitWarpStart
                      : null,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('action_ok'.tr()),
                            // Debug için
                            Text(
                              'P:${_personnelIdController.text.trim()} L:${_loomsController.text.trim()} O:${_orderNoController.text.trim()}',
                              style: TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _NumericKeyboard(
              onKey: (d) {
                // Hangi alan aktifse ona yaz
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
