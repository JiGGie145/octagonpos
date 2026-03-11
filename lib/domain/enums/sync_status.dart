/// Tracks whether a record has been synced to a remote server.
///
/// Not used in MVP but included in every table for future sync readiness.
enum SyncStatus {
  pending,
  synced,
  failed;

  /// Parse from a stored string value (case-insensitive).
  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncStatus.pending,
    );
  }
}
