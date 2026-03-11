import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/presentation/providers/repository_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';

/// Settings screen for editing business configuration after initial setup.
///
/// Pre-populates all fields from the current [BusinessSettings].
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _currencyController = TextEditingController();
  final _currencySymbolController = TextEditingController();
  final _taxController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  bool _saving = false;
  bool _populated = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _currencyController.dispose();
    _currencySymbolController.dispose();
    _taxController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  /// Populate controllers once from the current settings.
  void _populateFrom(BusinessSettings settings) {
    if (_populated) return;
    _populated = true;
    _businessNameController.text = settings.businessName;
    _currencyController.text = settings.currency;
    _currencySymbolController.text = settings.currencySymbol;
    _taxController.text = settings.taxPercentage.toString();
    _receiptFooterController.text = settings.receiptFooter;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final settings = BusinessSettings(
      businessName: _businessNameController.text.trim(),
      currency: _currencyController.text.trim().toUpperCase(),
      currencySymbol: _currencySymbolController.text.trim(),
      taxPercentage: int.parse(_taxController.text.trim()),
      receiptFooter: _receiptFooterController.text.trim(),
    );

    try {
      await ref.read(settingsRepositoryProvider).save(settings);
      ref.invalidate(settingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading settings: $e'),
        ),
        data: (settings) {
          if (settings != null) _populateFrom(settings);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Section: General ──────────────────────────
                      _SectionHeader(
                        icon: Icons.business_rounded,
                        title: 'General',
                        theme: theme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: TextFormField(
                            controller: _businessNameController,
                            decoration: const InputDecoration(
                              labelText: 'Business Name *',
                              hintText: 'e.g. Demo Coffee Shop',
                              prefixIcon: Icon(Icons.storefront_rounded),
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Business name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Section: Currency ─────────────────────────
                      _SectionHeader(
                        icon: Icons.attach_money_rounded,
                        title: 'Currency',
                        theme: theme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _currencyController,
                                      decoration: const InputDecoration(
                                        labelText: 'Currency Code *',
                                        hintText: 'ZAR',
                                        prefixIcon:
                                            Icon(Icons.language_rounded),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _currencySymbolController,
                                      decoration: const InputDecoration(
                                        labelText: 'Symbol *',
                                        hintText: 'R',
                                      ),
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(5),
                                      ],
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Section: Tax ──────────────────────────────
                      _SectionHeader(
                        icon: Icons.percent_rounded,
                        title: 'Tax',
                        theme: theme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: TextFormField(
                            controller: _taxController,
                            decoration: const InputDecoration(
                              labelText: 'Tax Percentage *',
                              hintText: '15',
                              prefixIcon: Icon(Icons.percent_rounded),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tax percentage is required';
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null ||
                                  parsed < 0 ||
                                  parsed > 100) {
                                return 'Enter a value between 0 and 100';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Section: Receipts ─────────────────────────
                      _SectionHeader(
                        icon: Icons.receipt_long_rounded,
                        title: 'Receipts',
                        theme: theme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: TextFormField(
                            controller: _receiptFooterController,
                            decoration: const InputDecoration(
                              labelText: 'Receipt Footer (optional)',
                              hintText:
                                  'e.g. Thank you for your purchase!',
                              prefixIcon: Icon(Icons.message_rounded),
                            ),
                            textInputAction: TextInputAction.done,
                            maxLines: 2,
                            onFieldSubmitted: (_) => _save(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Save Button ───────────────────────────────
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_saving ? 'Saving...' : 'Save Settings'),
                        style: FilledButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(AppSpacing.minTapTarget),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Small reusable section header with icon and title.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
