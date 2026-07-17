import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/style.dart';
import '../../core/health/health_service.dart';

class HealthConnectScreen extends ConsumerWidget {
  const HealthConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(healthConnectionProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Connect'),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(healthConnectionProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: connection.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Could not inspect Health Connect: $error')),
            data: (status) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  tinted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _availabilityTitle(status),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(_availabilityDetail(status)),
                      if (status.lastSync != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last successful sync: ${DateFormat.yMMMd().add_jm().format(status.lastSync!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    title: const Text('Sync with Health Connect'),
                    subtitle: const Text(
                      'When paused, LifeOS stops requesting steps and heart-rate data.',
                    ),
                    value: status.syncEnabled,
                    onChanged:
                        status.availability ==
                            HealthConnectionAvailability.available
                        ? (value) => ref
                              .read(healthConnectionProvider.notifier)
                              .setSyncEnabled(value)
                        : null,
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.health_and_safety_outlined),
                        title: const Text('Request read access'),
                        subtitle: const Text('Steps and heart rate only'),
                        trailing: const Icon(Icons.chevron_right),
                        enabled:
                            status.availability ==
                            HealthConnectionAvailability.available,
                        onTap: () => _requestAccess(context, ref),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Manage access'),
                        subtitle: const Text(
                          'Open Android’s Health Connect permission settings',
                        ),
                        trailing: const Icon(Icons.open_in_new),
                        enabled:
                            status.availability ==
                            HealthConnectionAvailability.available,
                        onTap: () => _openSettings(context, ref),
                      ),
                      ListTile(
                        leading: const Icon(Icons.link_off_outlined),
                        title: const Text('Disconnect'),
                        subtitle: const Text(
                          'Revoke LifeOS permissions and pause synchronization',
                        ),
                        enabled: status.permissionsGranted,
                        onTap: () => ref
                            .read(healthConnectionProvider.notifier)
                            .disconnect(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const AppCard(
                  child: Text(
                    'Manual steps, walking, and Zone 2 logging remain available when access is paused, denied, or unavailable.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestAccess(BuildContext context, WidgetRef ref) async {
    final granted = await ref
        .read(healthConnectionProvider.notifier)
        .requestAccess();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Health Connect access is ready.'
              : 'Access was not granted. Manual entry still works.',
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context, WidgetRef ref) async {
    final opened = await ref
        .read(healthConnectionProvider.notifier)
        .openSettings();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health Connect settings could not be opened.'),
        ),
      );
    }
  }

  String _availabilityTitle(HealthConnectionSnapshot status) {
    return switch (status.availability) {
      HealthConnectionAvailability.available =>
        status.permissionsGranted
            ? 'Connected'
            : 'Available · access not granted',
      HealthConnectionAvailability.updateRequired => 'Update required',
      HealthConnectionAvailability.unavailable => 'Unavailable',
    };
  }

  String _availabilityDetail(HealthConnectionSnapshot status) {
    if (status.detail != null) return status.detail!;
    if (status.permissionsGranted) {
      return status.syncEnabled
          ? 'LifeOS may read steps and heart rate when you ask it to sync.'
          : 'Permissions are granted, but synchronization is paused.';
    }
    return 'Grant access only if you want steps and heart rate imported.';
  }
}
