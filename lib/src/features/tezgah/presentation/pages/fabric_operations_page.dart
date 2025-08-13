import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FabricOperationsPage extends StatelessWidget {
  const FabricOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('btn_fabric'.tr())),
      body: Center(child: Text('btn_fabric'.tr())),
    );
  }
}
