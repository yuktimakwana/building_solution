enum SyncStatus { pending, syncing, synced, failed }

extension SyncStatusX on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.failed:
        return 'failed';
    }
  }

  static SyncStatus fromValue(String? raw) {
    switch (raw) {
      case 'syncing':
        return SyncStatus.syncing;
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      case 'pending':
      default:
        return SyncStatus.pending;
    }
  }
}
