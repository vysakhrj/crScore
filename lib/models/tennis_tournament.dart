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
  final int
      totalSetsPlayed; // Total number of sets played (fewer is better for tie-breaking)

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
    this.pointsToWinSet = 21, // Default to 21 points
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

    if (selectedPlayers.length % 2 != 0) {
      throw Exception('Selected players count must be even to form teams');
    }

    teams = [];

    // First, create the default team if specified
    final selectedPlayerIds =
        selectedPlayers.map((player) => player.id).toSet();
    final selectedDefaultPlayers = defaultTeamPlayers
        .where((player) => selectedPlayerIds.contains(player.id))
        .toList();

    if (selectedDefaultPlayers.length == 2) {
      final defaultTeam = TennisTeam(
        id: 'team_1',
        player1: selectedDefaultPlayers[0],
        player2: selectedDefaultPlayers[1],
      );
      teams.add(defaultTeam);
      print(
          'DEBUG: Created default team: ${selectedDefaultPlayers[0].name} & ${selectedDefaultPlayers[1].name}');
    } else if (selectedDefaultPlayers.isNotEmpty) {
      print(
          'DEBUG: Default team players must both be selected to form the default pair. Ignoring partial selection.');
    }

    // Get remaining players (excluding default team players)
    final remainingPlayers = selectedPlayers
        .where((player) =>
            !selectedDefaultPlayers.any((dtp) => dtp.id == player.id))
        .toList();

    if (remainingPlayers.length % 2 != 0) {
      throw Exception('Remaining players must form complete teams');
    }

    if (remainingPlayers.isNotEmpty) {
      final shuffledRemainingPlayers =
          List<TennisPlayer>.from(remainingPlayers);
      await Future.delayed(const Duration(milliseconds: 100));
      shuffledRemainingPlayers.shuffle(Random());

      for (int i = 0; i < shuffledRemainingPlayers.length; i += 2) {
        final team = TennisTeam(
          id: 'team_${teams.length + 1}',
          player1: shuffledRemainingPlayers[i],
          player2: shuffledRemainingPlayers[i + 1],
        );
        teams.add(team);
      }
    }

    print(
        'DEBUG: Generated ${teams.length} teams from ${selectedPlayers.length} players (${selectedDefaultPlayers.length} in default team)');
  }

  // Generate tournament bracket and matches
  Future<void> generateMatches() async {
    if (teams.isEmpty) {
      throw Exception('Teams must be generated before matches');
    }

    final teamCount = teams.length;
    if (teamCount < 2) {
      throw Exception(
          'At least two teams are required to start the tournament');
    }

    print('DEBUG: Starting generateMatches with $teamCount teams');
    matches = [];
    int matchNumber = 1;
    final DateTime baseTime =
        DateTime.now().add(const Duration(days: 1, hours: 9));
    const int spacingMinutes = 90;

    if (teamCount == 2) {
      print('DEBUG: Generating 2-team tournament (Final only)');
      matches.add(TennisMatch(
        id: 'match_$matchNumber',
        team1: teams[0],
        team2: teams[1],
        round: 'Final',
        matchNumber: matchNumber,
        scheduledTime: baseTime,
        pointsToWinSet: pointsToWinSet,
        setsToWin: setsToWin,
      ));
    } else {
      // Generate all round-robin match pairs first
      final List<TennisMatch> roundRobinMatches = [];
      int tempMatchNumber = 1;

      for (int i = 0; i < teamCount - 1; i++) {
        for (int j = i + 1; j < teamCount; j++) {
          roundRobinMatches.add(TennisMatch(
            id: 'match_$tempMatchNumber',
            team1: teams[i],
            team2: teams[j],
            round: 'Round Robin',
            matchNumber: tempMatchNumber,
            scheduledTime: baseTime, // Will be updated after sorting
            pointsToWinSet: pointsToWinSet,
            setsToWin: setsToWin,
          ));
          tempMatchNumber++;
        }
      }

      // Sort matches so no team plays in consecutive matches
      final sortedMatches = _sortMatchesToAvoidAdjacentTeams(roundRobinMatches);

      // Assign match numbers and scheduled times to sorted matches
      int roundRobinIndex = 0;
      for (final match in sortedMatches) {
        match.id = 'match_$matchNumber';
        match.matchNumber = matchNumber;
        match.scheduledTime =
            baseTime.add(Duration(minutes: roundRobinIndex * spacingMinutes));
        matches.add(match);
        matchNumber++;
        roundRobinIndex++;
      }

      final DateTime knockoutBaseTime = baseTime
          .add(Duration(minutes: (roundRobinIndex + 1) * spacingMinutes));

      if (teamCount == 3) {
        print('DEBUG: Generating 3-team tournament (Round-robin + Final)');
        matches.add(TennisMatch(
          id: 'match_$matchNumber',
          team1: null,
          team2: null,
          round: 'Final',
          matchNumber: matchNumber,
          scheduledTime: knockoutBaseTime,
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
      } else {
        print(
            'DEBUG: Generating $teamCount-team tournament (Round-robin + Semi-finals + Final)');
        matches.add(TennisMatch(
          id: 'match_$matchNumber',
          team1: null,
          team2: null,
          round: 'Semi Final',
          matchNumber: matchNumber,
          scheduledTime: knockoutBaseTime,
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
        matchNumber++;

        matches.add(TennisMatch(
          id: 'match_$matchNumber',
          team1: null,
          team2: null,
          round: 'Semi Final',
          matchNumber: matchNumber,
          scheduledTime: knockoutBaseTime.add(const Duration(hours: 2)),
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
        matchNumber++;

        matches.add(TennisMatch(
          id: 'match_$matchNumber',
          team1: null,
          team2: null,
          round: 'Final',
          matchNumber: matchNumber,
          scheduledTime: knockoutBaseTime.add(const Duration(hours: 5)),
          pointsToWinSet: pointsToWinSet,
          setsToWin: setsToWin,
        ));
      }
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
    return selectedPlayers.length >= 2 && selectedPlayers.length % 2 == 0;
  }

  // Get tournament progress percentage
  double get progressPercentage {
    if (matches.isEmpty) return 0.0;
    final completedMatches = matches.where((match) => match.isCompleted).length;
    return (completedMatches / matches.length) * 100;
  }

  // Sort matches so that no team plays in consecutive matches
  List<TennisMatch> _sortMatchesToAvoidAdjacentTeams(
      List<TennisMatch> matches) {
    if (matches.length <= 1) return matches;

    final List<TennisMatch> sorted = [];
    final List<TennisMatch> remaining = List.from(matches);
    final random = Random();

    // Shuffle initially for better distribution
    remaining.shuffle(random);

    // Track teams that played in the last match
    Set<String>? lastMatchTeams;

    while (remaining.isNotEmpty) {
      TennisMatch? selectedMatch;
      int selectedIndex = -1;

      if (lastMatchTeams == null) {
        // First match - pick any
        selectedMatch = remaining.removeAt(0);
      } else {
        // Try to find a match that doesn't contain any team from the last match
        for (int i = 0; i < remaining.length; i++) {
          final match = remaining[i];
          final matchTeams = {match.team1?.id, match.team2?.id}
              .where((id) => id != null)
              .cast<String>()
              .toSet();

          // Check if this match has no teams in common with the last match
          if (!matchTeams.any((teamId) => lastMatchTeams!.contains(teamId))) {
            selectedMatch = match;
            selectedIndex = i;
            break;
          }
        }

        // If no non-adjacent match found, pick the first available
        if (selectedMatch == null) {
          selectedMatch = remaining.removeAt(0);
        } else {
          remaining.removeAt(selectedIndex);
        }
      }

      sorted.add(selectedMatch);

      // Update last match teams
      lastMatchTeams = {selectedMatch.team1?.id, selectedMatch.team2?.id}
          .where((id) => id != null)
          .cast<String>()
          .toSet();
    }

    return sorted;
  }

  // Assign teams to first round matches only
  void _assignTeamsToFirstRound() {
    if (teams.length != 2) {
      // Round-robin matches are created with their teams already assigned.
      return;
    }

    final finalMatches =
        matches.where((match) => match.round == 'Final').toList();

    if (finalMatches.isEmpty) {
      return;
    }

    final finalMatch = finalMatches.first;
    finalMatch.team1 ??= teams[0];
    finalMatch.team2 ??= teams[1];
    print('DEBUG: Assigned ${teams[0].name} vs ${teams[1].name} to final');
  }

  // Advance winner to next round
  void advanceWinner(TennisMatch completedMatch) {
    if (!completedMatch.isCompleted || completedMatch.winner == null) return;

    final winner = completedMatch.winner!;
    final nextRound = _getNextRound(completedMatch.round);
    if (nextRound == null) return;

    // Special handling for round-robin completion
    if (completedMatch.round == 'Round Robin') {
      if (teams.length == 3) {
        _advanceTopTeamsFromRoundRobin3Teams();
        return;
      }

      if (teams.length >= 4) {
        _advanceTopTeamsFromRoundRobin();
        return;
      }
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
    final finalMatches = matches.where((m) => m.round == 'Final').toList();
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
        if (!match.isCompleted &&
            (match.team1CurrentPoints > 0 || match.team2CurrentPoints > 0)) {
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
        if (teams.length == 3) {
          return 'Final';
        }
        if (teams.length >= 4) {
          return 'Semi Final';
        }
        return null;
      case 'Semi Final':
        return 'Final';
      default:
        return null;
    }
  }
}
