
class Ball {
  int runs;
  bool isExtra;
  String extraType; // 'wd' for wide, 'nb' for no-ball
  int wagonWheelPosition; // 1-8 representing areas on the field
  String strikerId;
  String nonStrikerId;
  String bowlerId;
  String? wicketType; // New field
  String? runOutPlayerId; // New field

  Ball({required this.runs, this.isExtra = false, this.extraType = '', required this.wagonWheelPosition, required this.strikerId, required this.nonStrikerId, required this.bowlerId, this.wicketType, this.runOutPlayerId});

  factory Ball.fromJson(Map<String, dynamic> json) {
    return Ball(
      runs: json['runs'],
      isExtra: json['isExtra'],
      extraType: json['extraType'],
      wagonWheelPosition: json['wagonWheelPosition'],
      strikerId: json['strikerId'],
      nonStrikerId: json['nonStrikerId'],
      bowlerId: json['bowlerId'],
      wicketType: json['wicketType'],
      runOutPlayerId: json['runOutPlayerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runs': runs,
      'isExtra': isExtra,
      'extraType': extraType,
      'wagonWheelPosition': wagonWheelPosition,
      'strikerId': strikerId,
      'nonStrikerId': nonStrikerId,
      'bowlerId': bowlerId,
      'wicketType': wicketType,
      'runOutPlayerId': runOutPlayerId,
    };
  }
}
