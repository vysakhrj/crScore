import 'package:cricket_scorer/models/ball.dart';
import 'package:cricket_scorer/models/innings.dart';
import 'package:cricket_scorer/models/match.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/models/fall_of_wicket.dart';
import 'package:cricket_scorer/services/match_storage.dart';
import 'package:flutter/material.dart';

class MatchProvider with ChangeNotifier {
  late Match _match;
  late String _currentStrikerId;
  late String _currentNonStrikerId;
  late String _currentBowlerId;
  final MatchStorage _matchStorage = MatchStorage();
  Function? _onMatchEnd;
  Function? _onInningsEnd;

  // Setter for innings end callback
  set onInningsEnd(Function? callback) {
    _onInningsEnd = callback;
  }

  Match get match => _match;
  String get currentStrikerId => _currentStrikerId;
  String get currentNonStrikerId => _currentNonStrikerId;
  String get currentBowlerId => _currentBowlerId;
  bool _isOverEnd = false;
  bool get isOverEnd => _isOverEnd;
  bool _isInningsTransition = false;
  bool get isInningsTransition => _isInningsTransition;
  bool _isSecondInnings = false;

  Innings get currentInnings =>
      isFirstInnings ? _match.innings1 : _match.innings2;
  Team get battingTeam => currentInnings.battingTeamId == _match.team1.id
      ? _match.team1
      : _match.team2;
  Team get bowlingTeam => currentInnings.bowlingTeamId == _match.team1.id
      ? _match.team1
      : _match.team2;

  MatchProvider(
      {Match? loadedMatch,
      Team? team1,
      Team? team2,
      String? tossWinnerId,
      String? decision,
      int? totalOversPerInnings,
      Function? onMatchEnd,
      Function? onInningsEnd}) {
    _onMatchEnd = onMatchEnd;
    _onInningsEnd = onInningsEnd;
    if (loadedMatch != null) {
      _match = loadedMatch;
      final innings1BattingTeam =
          _match.innings1.battingTeamId == _match.team1.id
              ? _match.team1
              : _match.team2;
      final innings1TotalValidBalls = _match.innings1.overs
          .where((ball) => !ball.isExtra || ball.extraType == 'nb')
          .length;
      final innings1CompletedOvers = innings1TotalValidBalls ~/ 6;

      if (innings1CompletedOvers >= _match.totalOversPerInnings ||
          _match.innings1.wickets >= innings1BattingTeam.players.length - 1) {
        _isSecondInnings = true;
      }

      if (currentInnings.overs.isNotEmpty) {
        _currentStrikerId = currentInnings.overs.last.strikerId;
        _currentNonStrikerId = currentInnings.overs.last.nonStrikerId;
        _currentBowlerId = currentInnings.overs.last.bowlerId;
      } else {
        // If no balls have been bowled yet in the loaded match, initialize with default players
        _currentStrikerId = battingTeam.players[0].id;
        _currentNonStrikerId = battingTeam.players[1].id;
        _currentBowlerId = bowlingTeam.players[0].id;
      }
    } else {
      final battingTeam = (decision == 'bat')
          ? (tossWinnerId == team1!.id ? team1 : team2!)
          : (tossWinnerId == team1!.id ? team2! : team1);
      final bowlingTeam = (decision == 'bat')
          ? (tossWinnerId == team1!.id ? team2! : team1)
          : (tossWinnerId == team1!.id ? team1 : team2!);

      _match = Match(
        id: DateTime.now().toIso8601String(),
        team1: team1!,
        team2: team2!,
        tossWinnerId: tossWinnerId!,
        decision: decision!,
        totalOversPerInnings: totalOversPerInnings!,
        innings1: Innings(
          battingTeamId: battingTeam.id,
          bowlingTeamId: bowlingTeam.id,
          overs: <Ball>[],
        ),
        innings2: Innings(
          battingTeamId: bowlingTeam.id,
          bowlingTeamId: battingTeam.id,
          overs: <Ball>[],
        ),
      );
      _currentStrikerId = battingTeam.players[0].id;
      _currentNonStrikerId = battingTeam.players[1].id;
      _currentBowlerId = bowlingTeam.players[0].id;
    }
    _saveMatch();
  }

  void _saveMatch() {
    _matchStorage.saveMatch(_match);
  }

  void addBall(int runs,
      {bool isExtra = false,
      String extraType = '',
      int wagonWheelPosition = 0}) {
    currentInnings.overs.add(Ball(
      runs: runs,
      isExtra: isExtra,
      extraType: extraType,
      wagonWheelPosition: wagonWheelPosition,
      strikerId: _currentStrikerId,
      nonStrikerId: _currentNonStrikerId,
      bowlerId: _currentBowlerId,
    ));

    _isOverEnd = false; // Reset over end flag

    // Handle strike rotation for all deliveries (including extras)
    if (runs % 2 != 0) {
      _rotateStrike();
    }

    // Over end logic
    final totalValidBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    final ballsInCurrentOver = totalValidBalls % 6;
    if (ballsInCurrentOver == 0 && totalValidBalls > 0) {
      _rotateStrike(); // Rotate strike at the end of the over
      _isOverEnd = true; // Set over end flag
    }
    _checkInningsCompletion();

    // Check if match is complete after this ball
    if (isMatchComplete && _onMatchEnd != null) {
      _onMatchEnd!(_match);
    }

    _saveMatch();
    notifyListeners();
  }

  void addWicket(int runs, String wicketType, String? runOutPlayerId) {
    currentInnings.overs.add(Ball(
      runs: runs,
      isExtra: false,
      extraType: '',
      wagonWheelPosition: 0, // No wagon wheel for wickets directly
      strikerId: _currentStrikerId,
      nonStrikerId: _currentNonStrikerId,
      bowlerId: _currentBowlerId,
      wicketType: wicketType,
      runOutPlayerId: runOutPlayerId,
    ));
    currentInnings.wickets++;

    // Record Fall of Wicket
    var playerOutId =
        (wicketType == 'runOut') ? runOutPlayerId! : _currentStrikerId;
    currentInnings.fallOfWickets.add(FallOfWicket(
      wicketNumber: currentInnings.wickets,
      runs: totalRuns, // Total runs at the fall of this wicket
      playerId: playerOutId,
    ));

    // Determine who is out
    // String playerOutId;
    if (wicketType == 'runOut') {
      playerOutId = runOutPlayerId!;
    } else {
      playerOutId = _currentStrikerId; // For other wicket types, striker is out
    }

    // Update striker/non-striker based on who is out and runs scored
    if (playerOutId == _currentStrikerId) {
      // Striker is out
      // New batter will come to striker's end, so non-striker remains non-striker
    } else if (playerOutId == _currentNonStrikerId) {
      // Non-striker is out
      // New batter will come to non-striker's end, striker remains striker
      // If runs were scored, strike might need to rotate if odd runs were taken
      if (runs % 2 != 0) {
        _rotateStrike(); // Rotate strike if odd runs were taken and non-striker was out
      }
    }

    // Check if this wicket ball completes an over
    final totalValidBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    final ballsInCurrentOver = totalValidBalls % 6;
    if (ballsInCurrentOver == 0 && totalValidBalls > 0) {
      _rotateStrike(); // Rotate strike at the end of the over
      _isOverEnd = true; // Set over end flag
    }

    _checkInningsCompletion();

    // Check if match is complete after this wicket
    if (isMatchComplete && _onMatchEnd != null) {
      _onMatchEnd!(_match);
    }

    _saveMatch();
    notifyListeners();
  }

  void _checkInningsCompletion() {
    if (isFirstInnings) {
      final totalWicketsAllowed = battingTeam.players.length - 1;
      final totalValidBalls = currentInnings.overs
          .where((ball) => !ball.isExtra || ball.extraType == 'nb')
          .length;
      final completedOvers = totalValidBalls ~/ 6;

      if (currentInnings.wickets >= totalWicketsAllowed ||
          completedOvers >= _match.totalOversPerInnings) {
        _isSecondInnings = true;
        _isInningsTransition = true;
        if (_onInningsEnd != null) {
          _onInningsEnd!(_match.innings1, _match.team1, _match.team2, false);
        }
      }
    } else {
      if (isMatchComplete) {
        if (_onMatchEnd != null) {
          _onMatchEnd!(_match);
        }
      }
    }
  }

  void setStriker(String playerId) {
    _currentStrikerId = playerId;
    _saveMatch();
    notifyListeners();
  }

  void setNonStriker(String playerId) {
    _currentNonStrikerId = playerId;
    _saveMatch();
    notifyListeners();
  }

  void setBowler(String playerId) {
    _currentBowlerId = playerId;
    _isOverEnd = false; // Reset over end flag after bowler is selected
    _saveMatch();
    notifyListeners();
  }

  // Method to initialize second innings properly
  void initializeSecondInnings() {
    // Set current players safely
    if (battingTeam.players.isNotEmpty) {
      _currentStrikerId = battingTeam.players[0].id;
      _currentNonStrikerId = battingTeam.players.length > 1
          ? battingTeam.players[1].id
          : battingTeam.players[0].id;
    }

    if (bowlingTeam.players.isNotEmpty) {
      _currentBowlerId = bowlingTeam.players[0].id;
    }

    _isInningsTransition = false; // Reset the transition flag
    _saveMatch();
    notifyListeners();
  }

  // Method to get available batters for the current innings
  List<String> getAvailableBatters() {
    return battingTeam.players
        .where((player) =>
            player.id != _currentStrikerId &&
            player.id != _currentNonStrikerId &&
            !_match.innings1.overs.any((ball) =>
                ball.wicketType != null &&
                (ball.strikerId == player.id ||
                    ball.runOutPlayerId == player.id)) &&
            !_match.innings2.overs.any((ball) =>
                ball.wicketType != null &&
                (ball.strikerId == player.id ||
                    ball.runOutPlayerId == player.id)))
        .map((player) => player.id)
        .toList();
  }

  // Method to get available bowlers for the current innings (excluding current bowler)
  List<String> getAvailableBowlers() {
    return bowlingTeam.players
        .where((player) => player.id != _currentBowlerId)
        .map((player) => player.id)
        .toList();
  }

  // Method to check if current bowler has bowled any balls in the current over
  bool get hasCurrentBowlerBowledInThisOver {
    // Get the current over number (0-based)
    final totalValidBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    final currentOver = (totalValidBalls / 6).floor();

    // Get balls in the current over
    final ballsInCurrentOver = currentInnings.overs
        .skip(currentOver * 6)
        .take(6)
        .where((ball) => ball.bowlerId == _currentBowlerId)
        .length;

    return ballsInCurrentOver > 0;
  }

  // Method to check if a batter has faced any balls in the current innings
  bool hasBatterStartedInnings(String batterId) {
    // Check if the batter has faced any balls (as striker) in the current innings
    return currentInnings.overs.any((ball) => ball.strikerId == batterId);
  }

  // Method to get available batters for changing (excluding those who have started)
  List<String> getAvailableBattersForChange() {
    return battingTeam.players
        .where((player) =>
            player.id != _currentStrikerId &&
            player.id != _currentNonStrikerId &&
            !hasBatterStartedInnings(player.id) &&
            !_match.innings1.overs.any((ball) =>
                ball.wicketType != null &&
                (ball.strikerId == player.id ||
                    ball.runOutPlayerId == player.id)) &&
            !_match.innings2.overs.any((ball) =>
                ball.wicketType != null &&
                (ball.strikerId == player.id ||
                    ball.runOutPlayerId == player.id)))
        .map((player) => player.id)
        .toList();
  }

  int get totalRuns {
    return currentInnings.overs.fold(0, (sum, ball) => sum + ball.runs);
  }

  int get totalWickets {
    return currentInnings.wickets;
  }

  String get overs {
    final balls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType != 'wd')
        .length;
    final completedOvers = balls ~/ 6;
    final remainingBalls = balls % 6;
    return '$completedOvers.$remainingBalls';
  }

  bool get isFirstInnings => !_isSecondInnings;

  bool get isMatchComplete {
    if (isFirstInnings) return false;

    final innings1Runs =
        _match.innings1.overs.fold(0, (sum, ball) => sum + ball.runs);
    final innings2Runs =
        _match.innings2.overs.fold(0, (sum, ball) => sum + ball.runs);

    final totalWicketsAllowed = battingTeam.players.length - 1;
    final totalValidBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    final completedOvers = totalValidBalls ~/ 6;

    if (innings2Runs > innings1Runs ||
        currentInnings.wickets >= totalWicketsAllowed ||
        completedOvers >= _match.totalOversPerInnings) {
      return true;
    }
    return false;
  }

  double get currentRunRate {
    final totalBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType != 'wd')
        .length;
    if (totalBalls == 0) return 0.0;
    return (totalRuns / totalBalls) * 6;
  }

  int get ballsRemaining {
    final ballsBowled = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType != 'wd')
        .length;
    return (_match.totalOversPerInnings * 6) - ballsBowled;
  }

  double get projectedScore {
    if (!isFirstInnings) return 0.0; // Only for first innings
    if (currentRunRate == 0.0) return 0.0;
    return (currentRunRate * _match.totalOversPerInnings);
  }

  int get targetScore {
    final innings1Runs =
        _match.innings1.overs.fold(0, (sum, ball) => sum + ball.runs);
    return innings1Runs + 1;
  }

  int get runsNeeded {
    if (isFirstInnings) return 0; // Only for second innings
    return targetScore - totalRuns;
  }

  double get requiredRunRate {
    if (isFirstInnings) return 0.0; // Only for second innings
    if (ballsRemaining <= 0) return 0.0;
    return (runsNeeded / ballsRemaining) * 6;
  }

  void _rotateStrike() {
    String temp = _currentStrikerId;
    _currentStrikerId = _currentNonStrikerId;
    _currentNonStrikerId = temp;
  }

  // Returns the balls in the current over (valid balls only, i.e., not wide, but include no-balls)
  List<Ball> get currentOverBalls {
    final totalValidBalls = currentInnings.overs
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    final currentOverStart = (totalValidBalls ~/ 6) * 6;
    int validCount = 0;
    List<Ball> balls = [];
    for (final ball in currentInnings.overs) {
      if (!ball.isExtra || ball.extraType == 'nb') {
        validCount++;
      }
      if (validCount > currentOverStart && validCount <= currentOverStart + 6) {
        balls.add(ball);
      }
    }
    return balls;
  }

  // Returns the display string for a ball
  String getBallDisplayString(Ball ball) {
    if (ball.wicketType != null && ball.wicketType!.isNotEmpty) {
      if (ball.runs > 0) {
        return 'W+${ball.runs}';
      }
      return 'W';
    } else if (ball.isExtra) {
      if (ball.extraType == 'wd') {
        if (ball.runs > 1) return 'Wd+${ball.runs - 1}';
        return 'Wd';
      }
      if (ball.extraType == 'nb') {
        if (ball.runs > 1) return 'Nb+${ball.runs - 1}';
        return 'Nb';
      }
    }
    if (ball.runs == 0) return '.';
    return ball.runs.toString();
  }

  // Returns the total runs in the current over
  int get currentOverRuns {
    return currentOverBalls.fold(0, (sum, ball) => sum + ball.runs);
  }

  // Returns the number of balls left in the current over (valid balls only)
  int get currentOverBallsLeft {
    final validBalls = currentOverBalls
        .where((ball) => !ball.isExtra || ball.extraType == 'nb')
        .length;
    return 6 - validBalls;
  }

  // Undo/Redo stacks
  final List<Ball> _undoStack = [];
  final List<Ball> _redoStack = [];

  // Undo the last ball/wicket
  void undo() {
    if (currentInnings.overs.isNotEmpty) {
      final lastBall = currentInnings.overs.removeLast();
      _undoStack.add(lastBall);
      // If it was a wicket, decrement wickets and remove last fallOfWicket
      if (lastBall.wicketType != null && lastBall.wicketType!.isNotEmpty) {
        currentInnings.wickets =
            (currentInnings.wickets - 1).clamp(0, currentInnings.wickets);
        if (currentInnings.fallOfWickets.isNotEmpty) {
          currentInnings.fallOfWickets.removeLast();
        }
      }
      _saveMatch();
      notifyListeners();
    }
  }

  // Redo the last undone ball/wicket
  void redo() {
    if (_undoStack.isNotEmpty) {
      final ball = _undoStack.removeLast();
      currentInnings.overs.add(ball);
      // If it was a wicket, increment wickets and add a dummy fallOfWicket (optional: store in stack for full accuracy)
      if (ball.wicketType != null && ball.wicketType!.isNotEmpty) {
        currentInnings.wickets++;
        // Not restoring fallOfWicket details for simplicity
      }
      _saveMatch();
      notifyListeners();
    }
  }

  // Clear redo stack on new action
  void clearUndoRedo() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
