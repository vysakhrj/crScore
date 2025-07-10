import 'package:cricket_scorer/models/ball.dart';
import 'package:cricket_scorer/models/fall_of_wicket.dart';

class Innings {
  String battingTeamId;
  String bowlingTeamId;
  List<Ball> overs;
  int wickets;
  List<FallOfWicket> fallOfWickets;

  Innings({
    required this.battingTeamId,
    required this.bowlingTeamId,
    required this.overs,
    this.wickets = 0,
    List<FallOfWicket>? fallOfWickets,
  }) : this.fallOfWickets = fallOfWickets ?? [];

  factory Innings.fromJson(Map<String, dynamic> json) {
    return Innings(
      battingTeamId: json['battingTeamId'],
      bowlingTeamId: json['bowlingTeamId'],
      overs: (json['overs'] as List).map((i) => Ball.fromJson(i)).toList(),
      wickets: json['wickets'],
      fallOfWickets: (json['fallOfWickets'] as List?)
          ?.map((i) => FallOfWicket.fromJson(i))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'battingTeamId': battingTeamId,
        'bowlingTeamId': bowlingTeamId,
        'overs': overs.map((ball) => ball.toJson()).toList(),
        'wickets': wickets,
        'fallOfWickets': fallOfWickets.map((fow) => fow.toJson()).toList(),
      };
}
