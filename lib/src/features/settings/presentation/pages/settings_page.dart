import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../bloc/settings_bloc.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/verify_admin_password.dart';
import '../../domain/usecases/update_api_url.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        getSettings: GetIt.I<GetSettings>(),
        verifyAdminPassword: GetIt.I<VerifyAdminPassword>(),
        updateApiUrl: GetIt.I<UpdateApiUrl>(),
        repository: GetIt.I<SettingsRepository>(),
      )..add(SettingsLoaded()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr()),
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
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLanguageSection(context, state),
                  const SizedBox(height: 24),
                  _buildConnectionSettingsSection(context, state),
                  const SizedBox(height: 24),
                  _buildInfoSection(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, SettingsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings_language'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('language_turkish'.tr()),
                    value: 'tr',
                    groupValue: state.settings.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<SettingsBloc>()
                            .add(LanguageChanged(value));
                        context.setLocale(Locale(value));
                        // Save to Hive for persistence
                        GetIt.I<Box<dynamic>>().put('locale_code', value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('language_english'.tr()),
                    value: 'en',
                    groupValue: state.settings.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        context
                            .read<SettingsBloc>()
                            .add(LanguageChanged(value));
                        context.setLocale(Locale(value));
                        // Save to Hive for persistence
                        GetIt.I<Box<dynamic>>().put('locale_code', value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionSettingsSection(
      BuildContext context, SettingsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'settings_connection'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'settings_connection_desc'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed('connection-settings');
                },
                icon: const Icon(Icons.settings),
                label: Text('settings_manage_connection'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, SettingsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings_system_info'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('settings_app_name'.tr(), 'FAZ-2 Tezgah Kontrol'),
            _buildInfoRow('settings_version'.tr(), '1.0.0'),
            _buildInfoRow('settings_api_url'.tr(), state.settings.apiBaseUrl),
            _buildInfoRow('settings_language_code'.tr(),
                state.settings.languageCode.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
