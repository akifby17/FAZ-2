import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WarpOperationsPage extends StatelessWidget {
  const WarpOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('btn_warp'.tr())),
      body: Center(child: Text('btn_warp'.tr())),
    );
  }
}
