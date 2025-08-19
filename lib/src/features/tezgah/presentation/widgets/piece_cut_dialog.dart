import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../personnel/domain/usecases/load_personnels.dart';
import '../../../personnel/data/repositories/personnel_repository_impl.dart';
import '../../../../core/auth/token_service.dart';
import '../../../../core/network/api_client.dart';

enum ActiveField { personnel, topNo, metre }

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
  const PieceCutDialog({super.key, this.selectedLoomNo = ''});

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
  bool _isLoadingPieces = false;
  bool _isSubmitting = false;
  ActiveField _activeField = ActiveField.personnel;

  @override
  void initState() {
    super.initState();
    _personnelIdController.addListener(_onIdChanged);
    _personnelIdController.addListener(_onFormChanged);
    _topNoController.addListener(_onFormChanged);
    _metreController.addListener(_onFormChanged);
    if (widget.selectedLoomNo.isNotEmpty) {
      _tezgahController.text = widget.selectedLoomNo;
      // Otomatik olarak pieces bilgilerini yükle
      _loadPieces();
    }
    _loadPersonnels();
  }

  Future<void> _loadPieces() async {
    if (widget.selectedLoomNo.isEmpty) return;

    setState(() => _isLoadingPieces = true);
    try {
      final String token = await GetIt.I<TokenService>().getToken();
      final apiClient = GetIt.I<ApiClient>();

      print("Pieces yükleniyor: ${widget.selectedLoomNo}");

      final response = await apiClient.post(
        '/api/pieces/loom-workorder-pieces',
        data: {'loomNo': widget.selectedLoomNo},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print("Response: ${response.data}");

      if (response.data != null &&
          response.data is List &&
          response.data.isNotEmpty) {
        final pieceData = response.data[0];
        if (mounted) {
          setState(() {
            _topNoController.text = pieceData['pieceNo']?.toString() ?? '';
            _metreController.text =
                pieceData['productedLength']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      print("API Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Top bilgileri alınamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPieces = false);
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
        _tezgahController.text.trim().isNotEmpty &&
        _topNoController.text.trim().isNotEmpty &&
        _metreController.text.trim().isNotEmpty;
  }

  Future<void> _submitPieceCut() async {
    if (!_isValidForm() || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // final String token = await GetIt.I<TokenService>().getToken();
      // final apiClient = GetIt.I<ApiClient>();

      final requestData = {
        'loomNo': _tezgahController.text.trim(),
        'personnelID': int.parse(_personnelIdController.text.trim()),
        'pieceNo': int.parse(_topNoController.text.trim()),
        'productedLength': double.parse(_metreController.text.trim()),
      };

      print("Top kesim isteği: $requestData");

      // TODO: Top kesim endpoint'i henüz verilmedi, geldiğinde buraya eklenecek
      // final response = await apiClient.post('/api/pieces/cut',
      //   data: requestData,
      //   options: Options(headers: {'Authorization': 'Bearer $token'}));

      // Şimdilik simülasyon
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Top kesimi başarıyla tamamlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Top kesimi başarısız: $e'),
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
    _topNoController.removeListener(_onFormChanged);
    _metreController.removeListener(_onFormChanged);
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
              controller: _topNoController,
              readOnly: true,
              onTap: () {
                setState(() {
                  _activeField = ActiveField.topNo;
                });
              },
              decoration: InputDecoration(
                labelText: 'label_top_no'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _activeField == ActiveField.topNo
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    width: _activeField == ActiveField.topNo ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: _isLoadingPieces
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
            const SizedBox(height: 12),
            TextField(
              controller: _metreController,
              readOnly: true,
              onTap: () {
                setState(() {
                  _activeField = ActiveField.metre;
                });
              },
              decoration: InputDecoration(
                labelText: 'label_metre'.tr(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _activeField == ActiveField.metre
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    width: _activeField == ActiveField.metre ? 2 : 1,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('action_back'.tr())),
                ElevatedButton(
                  onPressed: (_isValidForm() && !_isSubmitting)
                      ? _submitPieceCut
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
                } else if (_activeField == ActiveField.topNo) {
                  _topNoController.text = _topNoController.text + d;
                } else if (_activeField == ActiveField.metre) {
                  // Metre alanında ondalık sayı desteği
                  if (d == '.' && !_metreController.text.contains('.')) {
                    _metreController.text = _metreController.text + d;
                  } else if (d != '.') {
                    _metreController.text = _metreController.text + d;
                  }
                }
              },
              onBackspace: () {
                if (_activeField == ActiveField.personnel) {
                  final t = _personnelIdController.text;
                  if (t.isNotEmpty) {
                    _personnelIdController.text = t.substring(0, t.length - 1);
                  }
                } else if (_activeField == ActiveField.topNo) {
                  final t = _topNoController.text;
                  if (t.isNotEmpty) {
                    _topNoController.text = t.substring(0, t.length - 1);
                  }
                } else if (_activeField == ActiveField.metre) {
                  final t = _metreController.text;
                  if (t.isNotEmpty) {
                    _metreController.text = t.substring(0, t.length - 1);
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
      '.',
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
            } else {
              onKey(k);
            }
          },
          child: Text(k, style: const TextStyle(fontSize: 20)),
        );
      },
    );
  }
}
