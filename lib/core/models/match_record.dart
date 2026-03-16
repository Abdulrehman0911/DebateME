class MatchRecord {
  final String topic;
  final String userStance;
  final String opponentPersona;
  final String result; // 'Victory', 'Defeat', 'Draw'
  final DateTime date;
  final int eloChange;

  MatchRecord({
    required this.topic,
    required this.userStance,
    required this.opponentPersona,
    required this.result,
    required this.date,
    this.eloChange = 24,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'userStance': userStance,
      'opponentPersona': opponentPersona,
      'result': result,
      'date': date.toIso8601String(),
      'eloChange': eloChange,
    };
  }

  factory MatchRecord.fromMap(Map<dynamic, dynamic> map) {
    // Migration logic: handle old boolean 'isVictory' if it exists
    String resultValue = map['result'] ?? 'Defeat';
    if (map.containsKey('isVictory') && !map.containsKey('result')) {
      resultValue = map['isVictory'] == true ? 'Victory' : 'Defeat';
    }

    return MatchRecord(
      topic: map['topic'] ?? 'Unknown Topic',
      userStance: map['userStance'] ?? 'Unknown Stance',
      opponentPersona: map['opponentPersona'] ?? 'Unknown Opponent',
      result: resultValue,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      eloChange: map['eloChange'] ?? 24,
    );
  }
}
