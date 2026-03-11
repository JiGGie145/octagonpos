import 'package:drift/drift.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart' as domain;

/// Maps between Drift [Setting] data class and domain [domain.BusinessSettings].
class SettingsMapper {
  SettingsMapper._();

  /// Converts a Drift [Setting] row to a domain entity.
  static domain.BusinessSettings toDomain(Setting row) {
    return domain.BusinessSettings(
      businessName: row.businessName,
      currency: row.currency,
      currencySymbol: row.currencySymbol,
      taxPercentage: row.taxPercentage,
      receiptFooter: row.receiptFooter,
    );
  }

  /// Converts a domain entity to a Drift [SettingsCompanion].
  static SettingsCompanion toCompanion(domain.BusinessSettings entity) {
    return SettingsCompanion(
      id: const Value(1),
      businessName: Value(entity.businessName),
      currency: Value(entity.currency),
      currencySymbol: Value(entity.currencySymbol),
      taxPercentage: Value(entity.taxPercentage),
      receiptFooter: Value(entity.receiptFooter),
    );
  }
}
