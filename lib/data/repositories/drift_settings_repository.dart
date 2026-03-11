import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_pos/data/mappers/settings_mapper.dart';
import 'package:flutter_pos/domain/entities/business_settings.dart' as domain;
import 'package:flutter_pos/domain/repositories/settings_repository.dart';

/// Drift-backed implementation of [SettingsRepository].
class DriftSettingsRepository implements SettingsRepository {
  final AppDatabase _db;

  DriftSettingsRepository(this._db);

  @override
  Future<domain.BusinessSettings?> get() async {
    final row = await _db.getSettings();
    return row != null ? SettingsMapper.toDomain(row) : null;
  }

  @override
  Future<void> save(domain.BusinessSettings settings) async {
    final companion = SettingsMapper.toCompanion(settings);
    await _db.upsertSettings(companion);
  }
}
