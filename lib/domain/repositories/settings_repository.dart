import 'package:flutter_pos/domain/entities/business_settings.dart';

/// Contract for business settings data access.
///
/// Implementations live in the data layer.
/// Settings is a single-row table — there is only ever one record.
abstract class SettingsRepository {
  /// Returns the current business settings, or `null` if not yet configured.
  Future<BusinessSettings?> get();

  /// Saves (inserts or updates) the business settings.
  Future<void> save(BusinessSettings settings);
}
