import 'tennis_team.dart';

class TennisMatch {
  String id;
  TennisTeam? team1;
  TennisTeam? team2;
  String? winnerId; // ID of winning team
  List<int> team1SetScores;
  List<int> team2SetScores;
  int team1CurrentPoints;
  int team2CurrentPoints;
  List<bool> pointHistory; // true for team1, false for team2
  int setsToWin;
  int pointsToWinSet; // Configurable points to win a set
  String round; // "Quarter Final", "Semi Final", "Final"
  int matchNumber;
  bool isCompleted;
  DateTime? scheduledTime;

  TennisMatch({
    required this.id,
    required this.round,
    required this.matchNumber,
    this.team1,
    this.team2,
    this.winnerId,
    this.team1SetScores = const [],
    this.team2SetScores = const [],
    this.team1CurrentPoints = 0,
    this.team2CurrentPoints = 0,
    this.pointHistory = const [],
    this.setsToWin = 3, // Default to best of 3 sets
    this.pointsToWinSet = 10, // Default to 21 points
    this.isCompleted = false,
    this.scheduledTime,
  });

  factory TennisMatch.fromJson(Map<String, dynamic> json) {
    return TennisMatch(
      id: json['id'],
      team1: json['team1'] != null ? TennisTeam.fromJson(json['team1']) : null,
      team2: json['team2'] != null ? TennisTeam.fromJson(json['team2']) : null,
      winnerId: json['winnerId'],
      team1SetScores: List<int>.from(json['team1SetScores'] ?? []),
      team2SetScores: List<int>.from(json['team2SetScores'] ?? []),
      team1CurrentPoints: json['team1CurrentPoints'] ?? 0,
      team2CurrentPoints: json['team2CurrentPoints'] ?? 0,
      pointHistory: List<bool>.from(json['pointHistory'] ?? []),
      setsToWin: json['setsToWin'] ?? 3,
      pointsToWinSet: json['pointsToWinSet'] ?? 10,
      round: json['round'],
      matchNumber: json['matchNumber'],
      isCompleted: json['isCompleted'] ?? false,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1': team1?.toJson(),
      'team2': team2?.toJson(),
      'winnerId': winnerId,
      'team1SetScores': team1SetScores,
      'team2SetScores': team2SetScores,
      'team1CurrentPoints': team1CurrentPoints,
      'team2CurrentPoints': team2CurrentPoints,
      'pointHistory': pointHistory,
      'setsToWin': setsToWin,
      'pointsToWinSet': pointsToWinSet,
      'round': round,
      'matchNumber': matchNumber,
      'isCompleted': isCompleted,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };
  }

  // Get the winning team
  TennisTeam? get winner {
    if (winnerId == null) return null;
    if (team1 != null && winnerId == team1!.id) return team1;
    if (team2 != null && winnerId == team2!.id) return team2;
    return null;
  }

  // Get the losing team
  TennisTeam? get loser {
    if (winnerId == null) return null;
    if (team1 != null && winnerId == team1!.id) return team2;
    if (team2 != null && winnerId == team2!.id) return team1;
    return null;
  }

  // Get match score display (sets)
  String get scoreDisplay {
    if (team1SetScores.isEmpty && team2SetScores.isEmpty) return 'vs';

    // Count winning sets for each team
    final team1Sets = team1SetScores.where((s) => s == 1).length;
    final team2Sets = team2SetScores.where((s) => s == 1).length;

    return '$team1Sets-$team2Sets';
  }

  // Get detailed score (sets and current points)
  String get detailedScore {
    if (isCompleted) {
      return '${team1SetScores.length}-${team2SetScores.length}';
    }
    return '${team1SetScores.length}-${team2SetScores.length} (Current: $team1CurrentPoints-$team2CurrentPoints)';
  }

  // Increment points for a team
  void incrementPoint(bool forTeam1) {
    if (isCompleted) return;

    // Record the point in history
    pointHistory = List<bool>.from(pointHistory)..add(forTeam1);

    if (forTeam1) {
      team1CurrentPoints++;
      if (team1CurrentPoints >= pointsToWinSet &&
          team1CurrentPoints - team2CurrentPoints >= 2) {
        // Team 1 wins set
        team1SetScores = List<int>.from(team1SetScores)..add(1);
        team2SetScores = List<int>.from(team2SetScores)..add(0);
        team1CurrentPoints = 0;
        team2CurrentPoints = 0;
        // Clear point history for the new set
        pointHistory = [];
        _checkMatchWin();
      }
    } else {
      team2CurrentPoints++;
      if (team2CurrentPoints >= pointsToWinSet &&
          team2CurrentPoints - team1CurrentPoints >= 2) {
        // Team 2 wins set
        team1SetScores = List<int>.from(team1SetScores)..add(0);
        team2SetScores = List<int>.from(team2SetScores)..add(1);
        team1CurrentPoints = 0;
        team2CurrentPoints = 0;
        // Clear point history for the new set
        pointHistory = [];
        _checkMatchWin();
      }
    }
  }

  void _checkMatchWin() {
    final team1Sets = team1SetScores.where((s) => s == 1).length;
    final team2Sets = team2SetScores.where((s) => s == 1).length;
    if (team1Sets >= setsToWin - 1) {
      winnerId = team1?.id;
      isCompleted = true;
    } else if (team2Sets >= setsToWin - 1) {
      winnerId = team2?.id;
      isCompleted = true;
    }
  }

  // For display: set history like 1-0, 1-1, 2-1, etc.
  String get setHistoryDisplay {
    int t1 = 0, t2 = 0;
    List<String> history = [];
    for (int i = 0; i < team1SetScores.length; i++) {
      t1 += team1SetScores[i];
      t2 += team2SetScores[i];
      history.add('$t1-$t2');
    }
    return history.isEmpty ? '' : history.join(', ');
  }

  // Undo last point
  bool undoLastPoint() {
    if (isCompleted || pointHistory.isEmpty) return false;

    // Remove the last point from history
    pointHistory = List<bool>.from(pointHistory)..removeLast();

    // Recalculate current points from history
    _recalculateCurrentPoints();

    // Re-check match completion
    _checkMatchWin();

    return true;
  }

  // Recalculate current points from point history
  void _recalculateCurrentPoints() {
    team1CurrentPoints = 0;
    team2CurrentPoints = 0;

    for (final point in pointHistory) {
      if (point) {
        team1CurrentPoints++;
      } else {
        team2CurrentPoints++;
      }
    }
  }

  // Reset current set
  void resetCurrentSet() {
    if (isCompleted) return;

    // Reset current points to 0 and clear point history
    team1CurrentPoints = 0;
    team2CurrentPoints = 0;
    pointHistory = [];
  }

  // Check if undo is possible
  bool get canUndo {
    if (isCompleted) return false;
    return team1CurrentPoints > 0 ||
        team2CurrentPoints > 0 ||
        team1SetScores.isNotEmpty ||
        team2SetScores.isNotEmpty;
  }

  // Check if reset is possible
  bool get canReset {
    if (isCompleted) return false;
    return team1CurrentPoints > 0 || team2CurrentPoints > 0;
  }
}
