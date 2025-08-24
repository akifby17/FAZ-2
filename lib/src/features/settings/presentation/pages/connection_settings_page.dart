import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

import '../bloc/settings_bloc.dart';
import '../widgets/admin_password_dialog.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/verify_admin_password.dart';
import '../../domain/usecases/update_api_url.dart';
import '../../domain/repositories/settings_repository.dart';

class ConnectionSettingsPage extends StatefulWidget {
  const ConnectionSettingsPage({super.key});

  @override
  State<ConnectionSettingsPage> createState() => _ConnectionSettingsPageState();
}

class _ConnectionSettingsPageState extends State<ConnectionSettingsPage> {
  final TextEditingController _apiUrlController = TextEditingController();
  bool _isAuthenticated = false;

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        getSettings: GetIt.I<GetSettings>(),
        verifyAdminPassword: GetIt.I<VerifyAdminPassword>(),
        updateApiUrl: GetIt.I<UpdateApiUrl>(),
        repository: GetIt.I<SettingsRepository>(),
      )..add(SettingsLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('settings_connection'.tr()),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state.status == SettingsStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state.status == SettingsStatus.success &&
                state.isAdminAuthenticated) {
              setState(() {
                _isAuthenticated = true;
              });
            }

            if (state.status == SettingsStatus.success && _isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('settings_updated'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state.status == SettingsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Populate controllers when settings are loaded
              if (_apiUrlController.text.isEmpty &&
                  state.settings.apiBaseUrl.isNotEmpty) {
                _apiUrlController.text = state.settings.apiBaseUrl;
              }

              if (!_isAuthenticated && !state.isAdminAuthenticated) {
                return _buildAuthenticationScreen(context, state);
              }

              return Column(
                children: [
                  _buildSettingsScreen(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationScreen(BuildContext context, SettingsState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'settings_security_check'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'settings_security_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final password = await showDialog<String>(
                        context: context,
                        builder: (context) => const AdminPasswordDialog(),
                      );

                      if (password != null && context.mounted) {
                        context
                            .read<SettingsBloc>()
                            .add(AdminPasswordVerified(password));
                      }
                    },
                    icon: const Icon(Icons.key),
                    label: Text('settings_enter_password'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsScreen(BuildContext context, SettingsState state) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings_api_base_url'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API URL',
                        hintText: 'http://95.70.139.125:5100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_apiUrlController.text.trim().isNotEmpty) {
                            context.read<SettingsBloc>().add(
                                  ApiUrlUpdated(_apiUrlController.text.trim()),
                                );
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text('settings_update_api_url'.tr()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'settings_api_warning'.tr(),
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
