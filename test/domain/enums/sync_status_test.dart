import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pos/domain/enums/sync_status.dart';

void main() {
  group('SyncStatus', () {
    group('fromString', () {
      test('parses pending', () {
        expect(SyncStatus.fromString('pending'), SyncStatus.pending);
      });

      test('parses synced', () {
        expect(SyncStatus.fromString('synced'), SyncStatus.synced);
      });

      test('parses failed', () {
        expect(SyncStatus.fromString('failed'), SyncStatus.failed);
      });

      test('parses mixed case', () {
        expect(SyncStatus.fromString('Synced'), SyncStatus.synced);
      });

      test('defaults to pending for unknown', () {
        expect(SyncStatus.fromString('unknown'), SyncStatus.pending);
      });
    });
  });
}
