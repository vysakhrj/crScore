
class FallOfWicket {
  int wicketNumber;
  int runs;
  String playerId;

  FallOfWicket({required this.wicketNumber, required this.runs, required this.playerId});

  factory FallOfWicket.fromJson(Map<String, dynamic> json) {
    return FallOfWicket(
      wicketNumber: json['wicketNumber'],
      runs: json['runs'],
      playerId: json['playerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wicketNumber': wicketNumber,
      'runs': runs,
      'playerId': playerId,
    };
  }
}
