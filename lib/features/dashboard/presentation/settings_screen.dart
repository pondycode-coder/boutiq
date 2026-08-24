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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
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
                    AppLocalizations.of(context)!.account,
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
                        AppLocalizations.of(context)!.cloudSync,
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
                    supabaseAvailable ? AppLocalizations.of(context)!.connectedToSupabase : AppLocalizations.of(context)!.supabaseNotConfigured,
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
                    label: Text(syncStatus.syncing ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.syncNowLabel),
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
                    label: Text(AppLocalizations.of(context)!.pushLocalToCloud),
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
                    label: Text(AppLocalizations.of(context)!.pullFromCloudLabel),
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
                    AppLocalizations.of(context)!.data,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.inventory_2,
                    title: AppLocalizations.of(context)!.products,
                    subtitle: '${HiveService.productsBox.length} items',
                    onTap: () => context.push('/dashboard/products'),
                  ),
                  _SettingsTile(
                    icon: Icons.group,
                    title: AppLocalizations.of(context)!.staff,
                    subtitle: '${HiveService.usersBox.length} members',
                    onTap: () => context.push('/dashboard/staff'),
                  ),
                  _SettingsTile(
                    icon: Icons.people,
                    title: AppLocalizations.of(context)!.clients,
                    subtitle: '${HiveService.clientsBox.length} clients',
                    onTap: () => context.push('/dashboard/clients'),
                  ),
                  _SettingsTile(
                    icon: Icons.receipt_long,
                    title: AppLocalizations.of(context)!.orders,
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
                    AppLocalizations.of(context)!.taxCurrency,
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
                    AppLocalizations.of(context)!.support,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'pondycode@gmail.com',
                    subtitle: AppLocalizations.of(context)!.emailSupportLabel,
                    onTap: () => _launchUrl('mailto:pondycode@gmail.com'),
                    leadingIconColor: Colors.blue,
                  ),
                  _SettingsTile(
                    icon: Icons.phone_outlined,
                    title: '+237 674 667 234',
                    subtitle: AppLocalizations.of(context)!.callSupportLabel,
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
                    AppLocalizations.of(context)!.appInfo,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: AppLocalizations.of(context)!.version,
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    subtitle: AppLocalizations.of(context)!.viewPrivacyPolicy,
                    onTap: () => _launchUrl('https://example.com/privacy'),
                  ),
                  _SettingsTile(
                    icon: Icons.article_outlined,
                    title: AppLocalizations.of(context)!.termsOfService,
                    subtitle: AppLocalizations.of(context)!.readTerms,
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
              AppLocalizations.of(context)!.vatRateLabel,
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
                        SnackBar(content: Text('${AppLocalizations.of(context)!.vatRateSaved} ${value.toStringAsFixed(2)}%')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.invalidVatRate)),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacingXs),
            Text(
              '${AppLocalizations.of(context)!.currentRate}: ${(rate * 100).toStringAsFixed(2)}%',
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
          AppLocalizations.of(context)!.language,
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.languageRestart)),
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
                    SnackBar(content: Text(AppLocalizations.of(context)!.languageRestart)),
                  );
                },
                child: Text(currentLang == 'en' ? 'English ✓' : 'English'),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingXs),
        Text(
          '${AppLocalizations.of(context)!.currentRate}: ${currentLang == 'fr' ? 'Français' : 'English'}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}