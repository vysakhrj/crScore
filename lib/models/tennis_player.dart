class TennisPlayer {
  String id;
  String name;

  // Tennis statistics
  int matchesWon = 0;
  int matchesPlayed = 0;
  int setsWon = 0;
  int gamesWon = 0;

  // Calculated statistics
  double get winPercentage {
    if (matchesPlayed == 0) return 0.0;
    return (matchesWon / matchesPlayed.toDouble()) * 100;
  }

  double get averageGamesPerMatch {
    if (matchesPlayed == 0) return 0.0;
    return gamesWon / matchesPlayed.toDouble();
  }

  TennisPlayer({
    required this.id,
    required this.name,
    this.matchesWon = 0,
    this.matchesPlayed = 0,
    this.setsWon = 0,
    this.gamesWon = 0,
  });

  factory TennisPlayer.fromJson(Map<String, dynamic> json) {
    return TennisPlayer(
      id: json['id'],
      name: json['name'],
      matchesWon: json['matchesWon'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      setsWon: json['setsWon'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'matchesWon': matchesWon,
      'matchesPlayed': matchesPlayed,
      'setsWon': setsWon,
      'gamesWon': gamesWon,
    };
  }

  // Method to update match statistics
  void updateMatchStats(bool won, int setsWon, int gamesWon) {
    matchesPlayed += 1;
    if (won) {
      matchesWon += 1;
    }
    this.setsWon += setsWon;
    this.gamesWon += gamesWon;
  }
}
