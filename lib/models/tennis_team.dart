import 'tennis_player.dart';

class TennisTeam {
  String id;
  TennisPlayer player1;
  TennisPlayer player2;
  String name;

  // Team statistics
  int matchesWon = 0;
  int matchesPlayed = 0;

  TennisTeam({
    required this.id,
    required this.player1,
    required this.player2,
  }) : name = '${player1.name} & ${player2.name}';

  factory TennisTeam.fromJson(Map<String, dynamic> json) {
    return TennisTeam(
      id: json['id'],
      player1: TennisPlayer.fromJson(json['player1']),
      player2: TennisPlayer.fromJson(json['player2']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player1': player1.toJson(),
      'player2': player2.toJson(),
      'name': name,
      'matchesWon': matchesWon,
      'matchesPlayed': matchesPlayed,
    };
  }

  // Check if team contains a specific player
  bool containsPlayer(String playerId) {
    return player1.id == playerId || player2.id == playerId;
  }

  // Get combined team statistics
  int get totalMatchesWon => player1.matchesWon + player2.matchesWon;
  int get totalMatchesPlayed => player1.matchesPlayed + player2.matchesPlayed;
  double get teamWinPercentage {
    if (totalMatchesPlayed == 0) return 0.0;
    return (totalMatchesWon / totalMatchesPlayed.toDouble()) * 100;
  }
}
