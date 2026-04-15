import 'package:flutter_test/flutter_test.dart';
import 'package:debateme/core/models/match_record.dart';

void main() {
  group('MatchRecord', () {
    test('serializes and deserializes correctly', () {
      final now = DateTime(2026, 4, 15, 10, 0, 0);
      final record = MatchRecord(
        topic: 'AI in Education',
        userStance: 'PRO',
        opponentPersona: 'The Philosopher',
        result: 'Victory',
        date: now,
        eloChange: 24,
      );

      final map = record.toMap();
      final restored = MatchRecord.fromMap(map);

      expect(restored.topic, 'AI in Education');
      expect(restored.userStance, 'PRO');
      expect(restored.opponentPersona, 'The Philosopher');
      expect(restored.result, 'Victory');
      expect(restored.date.toIso8601String(), now.toIso8601String());
      expect(restored.eloChange, 24);
    });

    test('supports legacy isVictory migration', () {
      final restored = MatchRecord.fromMap({
        'topic': 'Legacy topic',
        'userStance': 'CON',
        'opponentPersona': 'The Scientist',
        'isVictory': true,
        'date': DateTime(2026, 1, 1).toIso8601String(),
        'eloChange': 12,
      });

      expect(restored.result, 'Victory');
      expect(restored.eloChange, 12);
    });
  });
}
