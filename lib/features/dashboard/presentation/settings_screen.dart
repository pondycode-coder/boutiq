import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/database/supabase_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../features/settings/application/settings_provider.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final supabaseAvailable = SupabaseService.isAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        children: [
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.characters.first ?? '?',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      user?.name ?? 'Unknown',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${user?.role ?? '—'} • ${user?.phone ?? 'No phone'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Profile screen
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cloud Sync',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _SyncStatusChip(status: syncStatus),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  Text(
                    supabaseAvailable ? 'Connected to Supabase' : 'Supabase not configured',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: supabaseAvailable ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingLg),
                  FilledButton.icon(
                    onPressed: syncStatus.syncing ? null : () async {
                      await SyncService.syncAll();
                    },
                    icon: syncStatus.syncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync),
                    label: Text(syncStatus.syncing ? 'Syncing...' : 'Sync Now'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await SyncService.pushAll();
                    },
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Push Local to Cloud'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await SyncService.pullCatalog();
                      await SyncService.pullOrders();
                    },
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Pull from Cloud'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.inventory_2,
                    title: 'Products',
                    subtitle: '${HiveService.productsBox.length} items',
                    onTap: () => context.push('/dashboard/products'),
                  ),
                  _SettingsTile(
                    icon: Icons.group,
                    title: 'Staff',
                    subtitle: '${HiveService.usersBox.length} members',
                    onTap: () => context.push('/dashboard/staff'),
                  ),
                  _SettingsTile(
                    icon: Icons.people,
                    title: 'Clients',
                    subtitle: '${HiveService.clientsBox.length} clients',
                    onTap: () => context.push('/dashboard/clients'),
                  ),
                  _SettingsTile(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    subtitle: '${HiveService.ordersBox.length} orders',
                    onTap: () => context.push('/orders'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax & Currency',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _VatRateEditor(),
                  const SizedBox(height: DesignTokens.spacingLg),
                  _LanguageSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'pondycode@gmail.com',
                    subtitle: 'Email support',
                    onTap: () => _launchUrl('mailto:pondycode@gmail.com'),
                    leadingIconColor: Colors.blue,
                  ),
                  _SettingsTile(
                    icon: Icons.phone_outlined,
                    title: '+237 674 667 234',
                    subtitle: 'Call support',
                    onTap: () => _launchUrl('tel:+237674667234'),
                    leadingIconColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacingLg),
          Card(
            elevation: DesignTokens.elevationLevel1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Info',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () => _launchUrl('https://example.com/privacy'),
                  ),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    onTap: () => _launchUrl('https://example.com/terms'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;
    if (status.syncing) {
      color = Colors.amber;
      icon = Icons.sync;
    } else if (status.ok) {
      color = Colors.green;
      icon = Icons.cloud_done;
    } else {
      color = Colors.grey;
      icon = Icons.cloud_off;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingSm,
        vertical: DesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.message,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.leadingIconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? leadingIconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = leadingIconColor ?? theme.colorScheme.primary;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _VatRateEditor extends ConsumerWidget {
  const _VatRateEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vatRateAsync = ref.watch(vatRateProvider);
    final notifier = ref.read(vatRateNotifierProvider);

    return vatRateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
      data: (rate) {
        final controller = TextEditingController(
          text: (rate * 100).toStringAsFixed(2),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VAT Rate (%)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'VAT Rate %',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingMd),
                FilledButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text.replaceAll(',', '.'));
                    if (value != null && value >= 0 && value <= 100) {
                      notifier.setVatRate(value / 100);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('VAT rate updated to ${value.toStringAsFixed(2)}%')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid VAT rate (0-100)')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(
              'Current: ${(rate * 100).toStringAsFixed(2)}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final currentLang = locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingSm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: currentLang == 'fr' ? null : () {
                  // TODO: Implement locale change
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language change requires app restart')),
                  );
                },
                child: Text(currentLang == 'fr' ? 'Français ✓' : 'Français'),
              ),
            ),
            const SizedBox(width: DesignTokens.spacingMd),
            Expanded(
              child: OutlinedButton(
                onPressed: currentLang == 'en' ? null : () {
                  // TODO: Implement locale change
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language change requires app restart')),
                  );
                },
                child: Text(currentLang == 'en' ? 'English ✓' : 'English'),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        Text(
          'Current: ${currentLang == 'fr' ? 'Français' : 'English'}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}