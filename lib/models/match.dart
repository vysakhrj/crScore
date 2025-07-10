
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/models/innings.dart';

class Match {
  String id;
  Team team1;
  Team team2;
  String tossWinnerId;
  String decision; // 'bat' or 'bowl'
  int totalOversPerInnings;
  Innings innings1;
  Innings innings2;
  DateTime createdAt;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    required this.tossWinnerId,
    required this.decision,
    required this.totalOversPerInnings,
    required this.innings1,
    required this.innings2,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      team1: Team.fromJson(json['team1']),
      team2: Team.fromJson(json['team2']),
      tossWinnerId: json['tossWinnerId'],
      decision: json['decision'],
      totalOversPerInnings: json['totalOversPerInnings'],
      innings1: Innings.fromJson(json['innings1']),
      innings2: Innings.fromJson(json['innings2']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'team1': team1.toJson(),
        'team2': team2.toJson(),
        'tossWinnerId': tossWinnerId,
        'decision': decision,
        'totalOversPerInnings': totalOversPerInnings,
        'innings1': innings1.toJson(),
        'innings2': innings2.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

