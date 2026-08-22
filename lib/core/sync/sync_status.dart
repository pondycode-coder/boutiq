import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncStatus {
  const SyncStatus({
    required this.message,
    this.ok = true,
    this.syncing = false,
  });

  final String message;
  final bool ok;
  final bool syncing;

  SyncStatus copyWith({String? message, bool? ok, bool? syncing}) => SyncStatus(
        message: message ?? this.message,
        ok: ok ?? this.ok,
        syncing: syncing ?? this.syncing,
      );
}

final appContainer = ProviderContainer();

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus(
        message: 'Cloud sync not configured',
        ok: false,
      );

  void set(SyncStatus status) => state = status;
}

void updateSyncStatus(SyncStatus status) {
  appContainer.read(syncStatusProvider.notifier).set(status);
}