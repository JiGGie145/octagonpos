import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/core/theme/app_colors.dart';
import 'package:flutter_pos/core/theme/app_spacing.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart';
import 'package:flutter_pos/presentation/providers/repository_providers.dart';
import 'package:flutter_pos/presentation/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

/// First-run setup wizard that collects essential business settings before
/// the user can access the rest of the app.
///
/// Fields:
/// - Business name (required)
/// - Currency code (required, e.g. "ZAR")
/// - Currency symbol (required, e.g. "R")
/// - Tax percentage (required, default 15%)
/// - Receipt footer (optional)
class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _currencyController = TextEditingController(text: 'ZAR');
  final _currencySymbolController = TextEditingController(text: 'R');
  final _taxController = TextEditingController(text: '15');
  final _receiptFooterController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _currencyController.dispose();
    _currencySymbolController.dispose();
    _taxController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
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
      // Invalidate the settings provider so the app re-reads the new settings.
      ref.invalidate(settingsProvider);
      ref.invalidate(isSetupCompleteProvider);

      // Navigate to home — the router redirect guard will allow it now.
      if (mounted) context.go('/');
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.formMaxWidth),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ────────────────────────────────────
                      Icon(
                        Icons.storefront_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Welcome to Flutter POS',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Set up your business details to get started.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Business Name ─────────────────────────────
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name *',
                          hintText: 'e.g. Demo Coffee Shop',
                          prefixIcon: Icon(Icons.business_rounded),
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
                      const SizedBox(height: AppSpacing.md),

                      // ── Currency Row ──────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _currencyController,
                              decoration: const InputDecoration(
                                labelText: 'Currency *',
                                hintText: 'ZAR',
                                prefixIcon: Icon(Icons.language_rounded),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Tax Percentage ────────────────────────────
                      TextFormField(
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
                          if (parsed == null || parsed < 0 || parsed > 100) {
                            return 'Enter a value between 0 and 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Receipt Footer ────────────────────────────
                      TextFormField(
                        controller: _receiptFooterController,
                        decoration: const InputDecoration(
                          labelText: 'Receipt Footer (optional)',
                          hintText: 'e.g. Thank you for your purchase!',
                          prefixIcon: Icon(Icons.receipt_long_rounded),
                        ),
                        textInputAction: TextInputAction.done,
                        maxLines: 2,
                        onFieldSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Submit ────────────────────────────────────
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(_saving ? 'Saving...' : 'Get Started'),
                        style: FilledButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(AppSpacing.minTapTarget),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
