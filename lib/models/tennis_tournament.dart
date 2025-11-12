import 'tennis_player.dart';
import 'tennis_team.dart';
import 'tennis_match.dart';
import 'dart:math';

// Helper class for team standings
class TeamStanding {
  final TennisTeam team;
  final int wins;
  final int losses;
  final double winPercentage;
  final int pointsScored;
  final int pointsConceded;
  final int pointDifference; // pointsScored - pointsConceded
  final int totalSetsPlayed; // Total number of sets played (fewer is better for tie-breaking)

  TeamStanding({
    required this.team,
    required this.wins,
    required this.losses,
    required this.winPercentage,
    required this.pointsScored,
    required this.pointsConceded,
    required this.pointDifference,
    required this.totalSetsPlayed,
  });
}

class TennisTournament {
  String id;
  String name;
  List<TennisPlayer> allPlayers;
  List<TennisPlayer> selectedPlayers;
  List<TennisPlayer>
      defaultTeamPlayers; // Players that should be paired together
  List<TennisTeam> teams;
  List<TennisMatch> matches;
  DateTime createdAt;
  bool isStarted;
  bool isCompleted;
  int pointsToWinSet; // Configurable points to win a set
  int setsToWin; // Configurable sets to win the match

  TennisTournament({
    required this.id,
    required this.name,
    required this.allPlayers,
    List<TennisPlayer>? selectedPlayers,
    List<TennisPlayer>? defaultTeamPlayers,
    List<TennisTeam>? teams,
    List<TennisMatch>? matches,
    required this.createdAt,
    this.isStarted = false,
    this.isCompleted = false,
    this.pointsToWinSet = 10, // Default to 21 points
    this.setsToWin = 3, // Default to best of 3 sets
  })  : selectedPlayers = selectedPlayers ?? [],
        defaultTeamPlayers = defaultTeamPlayers ?? [],
        teams = teams ?? [],
        matches = matches ?? [];

  factory TennisTournament.fromJson(Map<String, dynamic> json) {
    return TennisTournament(
      id: json['id'],
      name: json['name'],
      allPlayers: (json['allPlayers'] as List)
          .map((player) => TennisPlayer.fromJson(player))
          .toList(),
      selectedPlayers: (json['selectedPlayers'] as List?)
              ?.map((player) => TennisPlayer.fromJson(player))
              .toList() ??
          [],
      teams: (json['teams'] as List?)
              ?.map((team) => TennisTeam.fromJson(team))
              .toList() ??
          [],
      matches: (json['matches'] as List?)
              ?.map((match) => TennisMatch.fromJson(match))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      isStarted: json['isStarted'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      pointsToWinSet: json['pointsToWinSet'] ?? 10,
      setsToWin: json['setsToWin'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'allPlayers': allPlayers.map((player) => player.toJson()).toList(),
      'selectedPlayers':
          selectedPlayers.map((player) => player.toJson()).toList(),
      'teams': teams.map((team) => team.toJson()).toList(),
      'matches': matches.map((match) => match.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isStarted': isStarted,
      'isCompleted': isCompleted,
      'pointsToWinSet': pointsToWinSet,
      'setsToWin': setsToWin,
    };
  }

  // Generate random teams from selected players
  Future<void> generateTeams() async {
    if (selectedPlayers.isEmpty) {
      throw Exception('No players selected');
    }

    teams = [];

    // First, create the default team if specified
    if (defaultTeamPlayers.length == 2) {
      final defaultTeam = TennisTeam(
        id: 'team_1',
        player1: defaultTeamPlayers[0],
        player2: defaultTeamPlayers[1],
      );
      teams.add(defaultTeam);
      print(
          'DEBUG: Created default team: ${defaultTeamPlayers[0].name} & ${defaultTeamPlayers[1].name}');
    }

    // Get remaining players (excluding default team players)
    final remainingPlayers = selectedPlayers
        .where(
            (player) => !defaultTeamPlayers.any((dtp) => dtp.id == player.id))
        .toList();

    if (remainingPlayers.isNotEmpty) {
      final shuffledRemainingPlayers =
          List<TennisPlayer>.from(remainingPlayers);
      await Future.delayed(const Duration(milliseconds: 100));
      shuffledRemainingPlayers.shuffle(Random());

      // Handle different team sizes based on number of remaining players
      if (remainingPlayers.length % 2 == 0) {
        // Even number: create pairs
        for (int i = 0; i < shuffledRemainingPlayers.length; i += 2) {
          final team = TennisTeam(
            id: 'team_${teams.length + 1}',
            player1: shuffledRemainingPlayers[i],
            player2: shuffledRemainingPlayers[i + 1],
          );
          teams.add(team);
        }
      } else {
        // Odd number: create individual players as teams
        for (int i = 0; i < shuffledRemainingPlayers.length; i++) {
          final team = TennisTeam(
            id: 'team_${teams.length + 1}',
            player1: shuffledRemainingPlayers[i],
            player2:
                shuffledRemainingPlayers[i], // Same player for both positions
          );
          teams.add(team);
        }
      }
    }

    print(
        'DEBUG: Generated ${teams.length} teams from ${selectedPlayers.length} players (${defaultTeamPlayers.length} in default team)');
  }

  // Generate tournament bracket and matches
  Future<void> generateMatches() async {
    if (teams.isEmpty) {
      throw Exception('Teams must be generated before matches');
    }

    print('DEBUG: Starting generateMatches with ${teams.length} teams');
    matches = [];
    int matchNumber = 1;

    // Determine tournament structure based on number of teams
    if (teams.length == 2) {
      print('DEBUG: Generating 2-team tournament (Final only)');
      _generateFinal(matchNumber);
    } else if (teams.length == 3) {
      print('DEBUG: Generating 3-team tournament (Round-robin + Final)');
      _generateRoundRobin(matchNumber);
      matchNumber += 3; // 3 round-robin matches
      _generateFinal(matchNumber);
    } else if (teams.length == 4) {
      print(
          'DEBUG: Generating 4-team tournament (Round-robin + Semi-finals + Final)');
      // Round-robin matches first, then semi-finals and final
      _generateRoundRobin4Teams(matchNumber);
      matchNumber += 6; // 6 round-robin matches (4 teams = 6 matches)
      _generateSemiFinals(matchNumber);
      matchNumber += 2;
      _generateFinal(matchNumber);
    } else if (teams.length == 5) {
      print('DEBUG: Generating 5-team tournament (Modified bracket)');
      _generateModifiedBracket5Teams(matchNumber);
    } else if (teams.length == 6) {
      print('DEBUG: Generating 6-team tournament (Modified bracket)');
      _generateModifiedBracket6Teams(matchNumber);
    } else if (teams.length == 7) {
      print('DEBUG: Generating 7-team tournament (Modified bracket)');
      _generateModifiedBracket7Teams(matchNumber);
    } else if (teams.length == 8) {
      print(
          'DEBUG: Generating 8-team tournament (Round-robin + Semi-finals + Final)');
      // Round-robin matches first, then semi-finals and final
      _generateRoundRobin8Teams(matchNumber);
      matchNumber += 28; // 28 round-robin matches (8 teams = 28 matches)
      _generateSemiFinals(matchNumber);
      matchNumber += 2;
      _generateFinal(matchNumber);
    } else if (teams.length == 16) {
      print(
          'DEBUG: Generating 16-team tournament (Round of 16 + Quarter-finals + Semi-finals + Final)');
      // Round of 16, quarter-finals, semi-finals, and final
      _generateRoundOf16(matchNumber);
      matchNumber += 8;
      _generateQuarterFinals(matchNumber);
      matchNumber += 4;
      _generateSemiFinals(matchNumber);
      matchNumber += 2;
      _generateFinal(matchNumber);
    } else {
      throw Exception(
          'Tournament requires 2-8 or 16 teams. Current teams: ${teams.length}');
    }

    print('DEBUG: Generated ${matches.length} matches');

    // Add a small delay to ensure matches are created
    await Future.delayed(const Duration(milliseconds: 50));

    // Immediately assign teams to first round matches
    _assignTeamsToFirstRound();

    print(
        'DEBUG: Assigned teams to first round. Final match count: ${matches.length}');
    isStarted = true;
  }

  void _generateRoundOf16(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    for (int i = 0; i < 8; i++) {
      // 8 matches in round of 16
      final matchTime = baseTime
          .add(Duration(minutes: i * 90)); // 1.5 hours apart (90 minutes)
      matches.add(TennisMatch(
        id: 'match_$startMatchNumber',
        team1: null, // Will be assigned in _assignTeamsToFirstRound
        team2: null, // Will be assigned in _assignTeamsToFirstRound
        round: 'Round of 16',
        matchNumber: startMatchNumber,
        scheduledTime: matchTime,
        pointsToWinSet: pointsToWinSet,
        setsToWin: setsToWin,
      ));
      startMatchNumber++;
    }
  }

  void _generateQuarterFinals(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 10)); // Start tomorrow at 10 AM

    for (int i = 0; i < 4; i++) {
      final matchTime = baseTime.add(Duration(hours: i * 2)); // 2 hours apart
      matches.add(TennisMatch(
        id: 'match_$startMatchNumber',
        team1: null, // Will be assigned in _assignTeamsToFirstRound
        team2: null, // Will be assigned in _assignTeamsToFirstRound
        round: 'Quarter Final',
        matchNumber: startMatchNumber,
        scheduledTime: matchTime,
        pointsToWinSet: pointsToWinSet,
        setsToWin: setsToWin,
      ));
      startMatchNumber++;
    }
  }

  void _generateSemiFinals(int startMatchNumber) {
    final baseTime =
        DateTime.now().add(const Duration(days: 2, hours: 14)); // Day 2 at 2 PM

    for (int i = 0; i < 2; i++) {
      final matchTime = baseTime.add(Duration(hours: i * 3)); // 3 hours apart
      matches.add(TennisMatch(
        id: 'match_$startMatchNumber',
        team1: null, // TBD - will be filled as winners advance
        team2: null, // TBD - will be filled as winners advance
        round: 'Semi Final',
        matchNumber: startMatchNumber,
        scheduledTime: matchTime,
        pointsToWinSet: pointsToWinSet,
        setsToWin: setsToWin,
      ));
      startMatchNumber++;
    }
  }

  void _generateFinal(int matchNumber) {
    final finalTime =
        DateTime.now().add(const Duration(days: 3, hours: 16)); // Day 3 at 4 PM
    matches.add(TennisMatch(
      id: 'match_$matchNumber',
      team1: null, // TBD - will be filled as winners advance
      team2: null, // TBD - will be filled as winners advance
      round: 'Final',
      matchNumber: matchNumber,
      scheduledTime: finalTime,
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
  }

  void _generateRoundRobin(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // For 3 teams: Team1 vs Team2, Team2 vs Team3, Team1 vs Team3
    for (int i = 0; i < 3; i++) {
      final matchTime =
          baseTime.add(Duration(minutes: i * 90)); // 1.5 hours apart
      matches.add(TennisMatch(
        id: 'match_$startMatchNumber',
        team1: null, // Will be assigned in _assignTeamsToFirstRound
        team2: null, // Will be assigned in _assignTeamsToFirstRound
        round: 'Round Robin',
        matchNumber: startMatchNumber,
        scheduledTime: matchTime,
        pointsToWinSet: pointsToWinSet,
        setsToWin: setsToWin,
      ));
      startMatchNumber++;
    }
  }

  void _generateRoundRobin4Teams(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // For 4 teams: generate all possible combinations (6 matches)
    // Each team plays against every other team once
    int matchIndex = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = i + 1; j < 4; j++) {
        final matchTime =
            baseTime.add(Duration(minutes: matchIndex * 90)); // 1.5 hours apart
        matches.add(TennisMatch(
          id: 'match_${startMatchNumber + matchIndex}',
          team1: null, // Will be assigned in _assignTeamsToFirstRound
          team2: null, // Will be assigned in _assignTeamsToFirstRound
          round: 'Round Robin',
          matchNumber: startMatchNumber + matchIndex,
          scheduledTime: matchTime,
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
        matchIndex++;
      }
    }
  }

  void _generateRoundRobin8Teams(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // For 8 teams: generate all possible combinations (28 matches)
    // Each team plays against every other team once
    int matchIndex = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = i + 1; j < 8; j++) {
        final matchTime =
            baseTime.add(Duration(minutes: matchIndex * 60)); // 1 hour apart
        matches.add(TennisMatch(
          id: 'match_${startMatchNumber + matchIndex}',
          team1: null, // Will be assigned in _assignTeamsToFirstRound
          team2: null, // Will be assigned in _assignTeamsToFirstRound
          round: 'Round Robin',
          matchNumber: startMatchNumber + matchIndex,
          scheduledTime: matchTime,
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
        matchIndex++;
      }
    }
  }

  void _generateModifiedBracket5Teams(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // 5-team format: 2 quarter-finals, 1 semi-final, 1 final
    // Quarter-final 1: Team1 vs Team2
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime,
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Quarter-final 2: Team3 vs Team4
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(minutes: 90)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final: Winner of QF1 vs Team5
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 3)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final: Winner of QF2 vs Winner of SF1
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 4, minutes: 30)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Final
    _generateFinal(startMatchNumber);
  }

  void _generateModifiedBracket6Teams(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // 6-team format: 2 quarter-finals, 2 semi-finals, 1 final
    // Quarter-final 1: Team1 vs Team2
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime,
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Quarter-final 2: Team3 vs Team4
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(minutes: 90)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final 1: Winner of QF1 vs Team5
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 3)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final 2: Winner of QF2 vs Team6
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 4, minutes: 30)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Final
    _generateFinal(startMatchNumber);
  }

  void _generateModifiedBracket7Teams(int startMatchNumber) {
    final baseTime = DateTime.now()
        .add(const Duration(days: 1, hours: 9)); // Start tomorrow at 9 AM

    // 7-team format: 3 quarter-finals, 2 semi-finals, 1 final
    // Quarter-final 1: Team1 vs Team2
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime,
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Quarter-final 2: Team3 vs Team4
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(minutes: 90)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Quarter-final 3: Team5 vs Team6
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Quarter Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 2)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final 1: Winner of QF1 vs Winner of QF2
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 4)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Semi-final 2: Winner of QF3 vs Team7
    matches.add(TennisMatch(
      id: 'match_$startMatchNumber',
      team1: null,
      team2: null,
      round: 'Semi Final',
      matchNumber: startMatchNumber,
      scheduledTime: baseTime.add(const Duration(hours: 5, minutes: 30)),
      pointsToWinSet: pointsToWinSet,
      setsToWin: setsToWin,
    ));
    startMatchNumber++;

    // Final
    _generateFinal(startMatchNumber);
  }

  // Get matches by round
  List<TennisMatch> getMatchesByRound(String round) {
    return matches.where((match) => match.round == round).toList();
  }

  // Get upcoming matches
  List<TennisMatch> getUpcomingMatches() {
    return matches.where((match) => !match.isCompleted).toList();
  }

  // Get completed matches
  List<TennisMatch> getCompletedMatches() {
    return matches.where((match) => match.isCompleted).toList();
  }

  // Get tournament winner
  TennisTeam? get winner {
    final finalMatch =
        matches.where((match) => match.round == 'Final').firstOrNull;
    return finalMatch?.winner;
  }

  // Check if tournament can be started
  bool get canStart {
    return selectedPlayers.length >= 4 && selectedPlayers.length % 2 == 0;
  }

  // Get tournament progress percentage
  double get progressPercentage {
    if (matches.isEmpty) return 0.0;
    final completedMatches = matches.where((match) => match.isCompleted).length;
    return (completedMatches / matches.length) * 100;
  }

  // Assign teams to first round matches only
  void _assignTeamsToFirstRound() {
    // Determine which round is the first round based on number of teams
    String firstRound;
    if (teams.length == 2) {
      firstRound = 'Final';
    } else if (teams.length == 3) {
      firstRound = 'Round Robin';
    } else if (teams.length == 4) {
      firstRound = 'Round Robin';
    } else if (teams.length == 5 || teams.length == 6 || teams.length == 7) {
      firstRound = 'Quarter Final';
    } else if (teams.length == 8) {
      firstRound = 'Quarter Final';
    } else if (teams.length == 16) {
      firstRound = 'Round of 16';
    } else {
      return; // Invalid number of teams
    }

    print('DEBUG: Assigning teams to first round: $firstRound');
    print('DEBUG: Total teams: ${teams.length}');

    final firstRoundMatches =
        matches.where((match) => match.round == firstRound).toList();

    print('DEBUG: Found ${firstRoundMatches.length} first round matches');

    // Special handling for different tournament formats
    if (teams.length == 2) {
      // 2 teams: direct final
      if (firstRoundMatches.isNotEmpty && teams.length >= 2) {
        firstRoundMatches[0].team1 = teams[0];
        firstRoundMatches[0].team2 = teams[1];
        print('DEBUG: Assigned ${teams[0].name} vs ${teams[1].name} to final');
      }
    } else if (teams.length == 3) {
      // 3 teams: round-robin (Team1 vs Team2, Team2 vs Team3, Team1 vs Team3)
      if (firstRoundMatches.length >= 3 && teams.length >= 3) {
        firstRoundMatches[0].team1 = teams[0];
        firstRoundMatches[0].team2 = teams[1];
        firstRoundMatches[1].team1 = teams[1];
        firstRoundMatches[1].team2 = teams[2];
        firstRoundMatches[2].team1 = teams[0];
        firstRoundMatches[2].team2 = teams[2];
        print('DEBUG: Assigned round-robin matches for 3 teams');
      }
    } else if (teams.length == 4) {
      // 4 teams: round-robin (6 matches: Team1 vs Team2, Team1 vs Team3, Team1 vs Team4, Team2 vs Team3, Team2 vs Team4, Team3 vs Team4)
      if (firstRoundMatches.length >= 6 && teams.length >= 4) {
        firstRoundMatches[0].team1 = teams[0];
        firstRoundMatches[0].team2 = teams[1];
        firstRoundMatches[1].team1 = teams[0];
        firstRoundMatches[1].team2 = teams[2];
        firstRoundMatches[2].team1 = teams[0];
        firstRoundMatches[2].team2 = teams[3];
        firstRoundMatches[3].team1 = teams[1];
        firstRoundMatches[3].team2 = teams[2];
        firstRoundMatches[4].team1 = teams[1];
        firstRoundMatches[4].team2 = teams[3];
        firstRoundMatches[5].team1 = teams[2];
        firstRoundMatches[5].team2 = teams[3];
        print('DEBUG: Assigned round-robin matches for 4 teams');
      }
    } else {
      // Standard bracket assignment for 4+ teams
      for (int i = 0;
          i < teams.length && i < firstRoundMatches.length * 2;
          i += 2) {
        final matchIndex = i ~/ 2;
        if (matchIndex < firstRoundMatches.length) {
          firstRoundMatches[matchIndex].team1 = teams[i];
          if (i + 1 < teams.length) {
            firstRoundMatches[matchIndex].team2 = teams[i + 1];
          }
          print(
              'DEBUG: Assigned ${teams[i].name} vs ${i + 1 < teams.length ? teams[i + 1].name : "TBD"} to match ${matchIndex + 1}');
        }
      }
    }
  }

  // Advance winner to next round
  void advanceWinner(TennisMatch completedMatch) {
    if (!completedMatch.isCompleted || completedMatch.winner == null) return;

    final winner = completedMatch.winner!;
    final nextRound = _getNextRound(completedMatch.round);
    if (nextRound == null) return;

    // Special handling for round-robin completion
    if (completedMatch.round == 'Round Robin' && teams.length == 4) {
      _advanceTopTeamsFromRoundRobin();
      return;
    }

    // Special handling for 3-team round-robin completion
    if (completedMatch.round == 'Round Robin' && teams.length == 3) {
      _advanceTopTeamsFromRoundRobin3Teams();
      return;
    }

    final nextRoundMatches =
        matches.where((match) => match.round == nextRound).toList();
    if (nextRoundMatches.isEmpty) return;

    // Find the first available slot in the next round
    for (final nextMatch in nextRoundMatches) {
      if (nextMatch.team1 == null) {
        nextMatch.team1 = winner;
        break;
      } else if (nextMatch.team2 == null) {
        nextMatch.team2 = winner;
        break;
      }
    }
  }

  // Advance top teams from 3-team round-robin to final
  void _advanceTopTeamsFromRoundRobin3Teams() {
    final roundRobinMatches =
        matches.where((m) => m.round == 'Round Robin').toList();
    final completedRoundRobinMatches =
        roundRobinMatches.where((m) => m.isCompleted).toList();

    // Check if all round-robin matches are completed
    if (completedRoundRobinMatches.length < roundRobinMatches.length) {
      return; // Not all round-robin matches are done yet
    }

    // Calculate team standings
    final teamStandings = calculateTeamStandings();
    if (teamStandings.length < 2) return;

    // Get top 2 teams for final
    final topTeams =
        teamStandings.take(2).map((standing) => standing.team).toList();

    // Assign to final
    final finalMatches =
        matches.where((m) => m.round == 'Final').toList();
    if (finalMatches.isNotEmpty) {
      finalMatches[0].team1 = topTeams[0];
      finalMatches[0].team2 = topTeams[1];
    }
  }

  // Advance top teams from round-robin to semi-finals
  void _advanceTopTeamsFromRoundRobin() {
    final roundRobinMatches =
        matches.where((m) => m.round == 'Round Robin').toList();
    final completedRoundRobinMatches =
        roundRobinMatches.where((m) => m.isCompleted).toList();

    // Check if all round-robin matches are completed
    if (completedRoundRobinMatches.length < roundRobinMatches.length) {
      return; // Not all round-robin matches are done yet
    }

    // Calculate team standings
    final teamStandings = calculateTeamStandings();
    if (teamStandings.length < 4) return;

    // Get top 4 teams
    final topTeams =
        teamStandings.take(4).map((standing) => standing.team).toList();

    // Assign to semi-finals
    final semiFinalMatches =
        matches.where((m) => m.round == 'Semi Final').toList();
    if (semiFinalMatches.length >= 2) {
      semiFinalMatches[0].team1 = topTeams[0];
      semiFinalMatches[0].team2 = topTeams[3];
      semiFinalMatches[1].team1 = topTeams[1];
      semiFinalMatches[1].team2 = topTeams[2];
    }
  }

  // Calculate team standings from round-robin matches
  List<TeamStanding> calculateTeamStandings() {
    final standings = <TeamStanding>[];

    for (final team in teams) {
      final teamMatches = matches
          .where((m) =>
              m.round == 'Round Robin' &&
              m.isCompleted &&
              (m.team1?.id == team.id || m.team2?.id == team.id))
          .toList();

      int wins = 0;
      int losses = 0;
      int pointsScored = 0;
      int pointsConceded = 0;
      int totalSetsPlayed = 0;

      for (final match in teamMatches) {
        if (match.winner?.id == team.id) {
          wins++;
        } else {
          losses++;
        }

        // Calculate points scored and conceded
        if (match.team1?.id == team.id) {
          pointsScored += match.team1TotalPoints;
          pointsConceded += match.team2TotalPoints;
        } else if (match.team2?.id == team.id) {
          pointsScored += match.team2TotalPoints;
          pointsConceded += match.team1TotalPoints;
        }

        // Count total sets played (number of completed sets in the match)
        totalSetsPlayed += match.setPointHistory.length;
        // If match is in progress, count current set if it has points
        if (!match.isCompleted && (match.team1CurrentPoints > 0 || match.team2CurrentPoints > 0)) {
          totalSetsPlayed += 1;
        }
      }

      final pointDifference = pointsScored - pointsConceded;
      final winPercentage = (wins + losses) > 0 ? wins / (wins + losses) : 0.0;

      standings.add(TeamStanding(
        team: team,
        wins: wins,
        losses: losses,
        winPercentage: winPercentage,
        pointsScored: pointsScored,
        pointsConceded: pointsConceded,
        pointDifference: pointDifference,
        totalSetsPlayed: totalSetsPlayed,
      ));
    }

    // Sort by wins (descending), then by point difference (descending), 
    // then by sets played (ascending - fewer sets is better), then by win percentage
    standings.sort((a, b) {
      if (a.wins != b.wins) {
        return b.wins.compareTo(a.wins);
      }
      // If wins are equal, use point difference
      if (a.pointDifference != b.pointDifference) {
        return b.pointDifference.compareTo(a.pointDifference);
      }
      // If point difference is also equal, use sets played (fewer is better)
      if (a.totalSetsPlayed != b.totalSetsPlayed) {
        return a.totalSetsPlayed.compareTo(b.totalSetsPlayed);
      }
      // If sets played is also equal, use win percentage
      return b.winPercentage.compareTo(a.winPercentage);
    });

    return standings;
  }

  String? _getNextRound(String currentRound) {
    switch (currentRound) {
      case 'Round Robin':
        // For 4 teams, round-robin leads to semi-finals
        // For 3 teams, round-robin leads to final
        return teams.length == 4 ? 'Semi Final' : 'Final';
      case 'Round of 16':
        return 'Quarter Final';
      case 'Quarter Final':
        return 'Semi Final';
      case 'Semi Final':
        return 'Final';
      default:
        return null;
    }
  }
}
