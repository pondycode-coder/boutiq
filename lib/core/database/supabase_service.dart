import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../sync/sync_status.dart';

class SupabaseService {
  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[sync] Supabase not configured');
      updateSyncStatus(const SyncStatus(
        message: 'Cloud sync not configured',
        ok: false,
      ));
      return;
    }
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        publishableKey: SupabaseConfig.supabaseAnonKey,
      );
      _available = true;
      debugPrint('[sync] Supabase initialized OK');
      updateSyncStatus(const SyncStatus(message: 'Connected', ok: true));
    } catch (e) {
      _available = false;
      debugPrint('[sync] Supabase init FAILED: $e');
      updateSyncStatus(SyncStatus(message: 'Init failed: $e', ok: false));
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}