import 'package:flutter/material.dart';

import '../offline/connectivity_notifier.dart';
import '../offline/offline_status.dart';
import '../offline/offline_sync_service.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = OfflineSyncService.instance;
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityNotifier.instance,
      builder: (context, isOnline, _) {
        return StreamBuilder<SyncStatus>(
          stream: syncService.syncStatusStream,
          initialData: syncService.currentSyncStatus,
          builder: (context, snapshot) {
            final status = snapshot.data ?? SyncStatus.synced;
            final isVisible =
                !isOnline ||
                status == SyncStatus.pending ||
                status == SyncStatus.syncing ||
                status == SyncStatus.failed;
            if (!isVisible) return const SizedBox.shrink();

            final text = !isOnline
                ? 'Offline – saving changes locally'
                : _messageForStatus(status);
            final color = !isOnline
                ? Colors.orange.shade600
                : _colorForStatus(status);

            return Container(
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          },
        );
      },
    );
  }

  String _messageForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'Pending sync – will retry shortly';
      case SyncStatus.syncing:
        return 'Syncing changes…';
      case SyncStatus.failed:
        return 'Some changes failed to sync. Please retry.';
      case SyncStatus.synced:
        return 'All changes synced';
    }
  }

  Color _colorForStatus(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return Colors.orange.shade600;
      case SyncStatus.syncing:
        return Colors.blue.shade600;
      case SyncStatus.failed:
        return Colors.red.shade600;
      case SyncStatus.synced:
        return Colors.green.shade600;
    }
  }
}
