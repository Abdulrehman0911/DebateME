class MatchRecord {
  final String topic;
  final String userStance;
  final String opponentPersona;
  final bool isVictory;
  final DateTime date;
  final int eloChange;

  MatchRecord({
    required this.topic,
    required this.userStance,
    required this.opponentPersona,
    required this.isVictory,
    required this.date,
    this.eloChange = 24,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'userStance': userStance,
      'opponentPersona': opponentPersona,
      'isVictory': isVictory,
      'date': date.toIso8601String(),
      'eloChange': eloChange,
    };
  }

  factory MatchRecord.fromMap(Map<dynamic, dynamic> map) {
    return MatchRecord(
      topic: map['topic'] ?? 'Unknown Topic',
      userStance: map['userStance'] ?? 'Unknown Stance',
      opponentPersona: map['opponentPersona'] ?? 'Unknown Opponent',
      isVictory: map['isVictory'] ?? false,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      eloChange: map['eloChange'] ?? 24,
    );
  }
}
