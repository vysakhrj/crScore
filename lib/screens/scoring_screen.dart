import 'package:cricket_scorer/models/player.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:cricket_scorer/screens/scorecard_screen.dart';
import 'package:cricket_scorer/screens/worm_graph_screen.dart';
import 'package:cricket_scorer/widgets/wagon_wheel_dialog.dart';
import 'package:cricket_scorer/widgets/player_selection_dialog.dart';
import 'package:cricket_scorer/widgets/bowler_selection_dialog.dart';
import 'package:cricket_scorer/widgets/batter_selection_dialog.dart';
import 'package:cricket_scorer/widgets/extra_runs_dialog.dart';
import 'package:cricket_scorer/widgets/wicket_dialog.dart';
import 'package:cricket_scorer/widgets/new_batter_dialog.dart';
import 'package:cricket_scorer/screens/first_innings_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket_scorer/screens/home_screen.dart';

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  @override
  void initState() {
    super.initState();

    // Set up innings end callback
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    matchProvider.onInningsEnd = (innings, team1, team2, isSecondInnings) {
      if (!isSecondInnings) {
        // First innings ended, navigate to summary screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FirstInningsSummaryScreen(match: matchProvider.match),
          ),
        );
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPlayerSelectionDialog();
    });
  }

  void _showPlayerSelectionDialog() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    // Only show player selection if it's a new match (no balls bowled yet)
    if (matchProvider.match.innings1.overs.isNotEmpty ||
        matchProvider.match.innings2.overs.isNotEmpty) {
      return; // Skip dialog for loaded matches
    }

    final match = matchProvider.match;
    final battingTeam = match.innings1.battingTeamId == match.team1.id
        ? match.team1
        : match.team2;
    final bowlingTeam = match.innings1.bowlingTeamId == match.team1.id
        ? match.team1
        : match.team2;

    final result = await showDialog(
      context: context,
      barrierDismissible: false, // User must select players
      builder: (context) => PlayerSelectionDialog(
        battingTeamPlayers: battingTeam.players,
        bowlingTeamPlayers: bowlingTeam.players,
      ),
    );

    if (result != null) {
      matchProvider.setStriker(result['striker'].id);
      matchProvider.setNonStriker(result['nonStriker'].id);
      matchProvider.setBowler(result['bowler'].id);
    }
  }

  void _showBowlerSelectionDialog({bool includeCurrentBowler = false}) async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final bowlingTeam = matchProvider.bowlingTeam;

    List<Player> availableBowlers;
    if (includeCurrentBowler) {
      // Include all bowlers (for edit button when bowler hasn't bowled yet)
      availableBowlers = bowlingTeam.players;
    } else {
      // Get available bowlers (excluding current bowler for over end)
      final availableBowlerIds = matchProvider.getAvailableBowlers();
      availableBowlers = bowlingTeam.players
          .where((player) => availableBowlerIds.contains(player.id))
          .toList();
    }

    final newBowlerId = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BowlerSelectionDialog(
        bowlingTeamPlayers: availableBowlers,
        currentBowlerId: matchProvider.currentBowlerId,
      ),
    );

    if (newBowlerId != null) {
      matchProvider.setBowler(newBowlerId);
    }
  }

  String _getPlayerName(List<Player> players, String playerId) {
    try {
      return players.firstWhere((p) => p.id == playerId).name;
    } catch (e) {
      return 'Unknown Player';
    }
  }

  void _showNewBatterDialog() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final battingTeam = matchProvider.battingTeam;

    final availableBatterIds = matchProvider.getAvailableBatters();
    final availableBatters = battingTeam.players
        .where((player) => availableBatterIds.contains(player.id))
        .toList();

    final newBatterId = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NewBatterDialog(
        availableBatters: availableBatters,
      ),
    );

    if (newBatterId != null) {
      matchProvider.setStriker(newBatterId);
    }
  }

  void _showBatterSelectionDialog(String batterType) async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final battingTeam = matchProvider.battingTeam;

    final newBatterId = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BatterSelectionDialog(
        battingTeamPlayers: battingTeam.players,
        currentStrikerId: matchProvider.currentStrikerId,
        currentNonStrikerId: matchProvider.currentNonStrikerId,
        selectedBatterType: batterType,
      ),
    );

    if (newBatterId != null) {
      if (batterType == 'striker') {
        matchProvider.setStriker(newBatterId);
      } else if (batterType == 'nonStriker') {
        matchProvider.setNonStriker(newBatterId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final battingTeam = matchProvider.battingTeam;
    final bowlingTeam = matchProvider.bowlingTeam;

    // Listen for over end to show bowler selection dialog (only if match is not complete and not transitioning innings)
    if (matchProvider.isOverEnd &&
        !matchProvider.isMatchComplete &&
        !matchProvider.isInningsTransition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBowlerSelectionDialog();
      });
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Scoring?'),
            content: const Text('Are you sure you want to leave scoring?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        if (shouldLeave == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
          return false;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              '${matchProvider.match.team1.name} vs ${matchProvider.match.team2.name}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 1.2)),
          actions: [
            IconButton(
              icon: const Icon(Icons.score),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ScorecardScreen(matchProvider: matchProvider)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.show_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WormGraphScreen(match: matchProvider.match)),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // --- NEW HEADER SECTION ---
            Builder(
              builder: (context) {
                if (matchProvider.isFirstInnings) {
                  // FIRST INNINGS HEADER
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${battingTeam.name.toUpperCase()} *',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.more_horiz, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${matchProvider.totalRuns}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              '/${matchProvider.totalWickets}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '(${matchProvider.overs}/${matchProvider.match.totalOversPerInnings})',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Run rate',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      matchProvider.currentRunRate
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Extras',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'NB ${_countExtras(matchProvider, 'nb')}  WD ${_countExtras(matchProvider, 'wd')}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Projected score',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      matchProvider.projectedScore
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  // SECOND INNINGS HEADER
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              matchProvider.match.team1.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${_getTeamScore(matchProvider.match.innings1)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${matchProvider.battingTeam.name.toUpperCase()} *',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${matchProvider.totalRuns}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  '/${matchProvider.totalWickets}',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '(${matchProvider.overs}/${matchProvider.match.totalOversPerInnings})',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Row(
                            //   children: [
                            //     const Text('Req RR',
                            //         style: TextStyle(
                            //             fontSize: 14, color: Colors.black54)),
                            //     const SizedBox(width: 8),
                            //     Text(
                            //       matchProvider.requiredRunRate
                            //           .toStringAsFixed(1),
                            //       style: const TextStyle(
                            //           fontWeight: FontWeight.bold, fontSize: 16),
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   children: [
                            //     const Text('CRR',
                            //         style: TextStyle(
                            //             fontSize: 14, color: Colors.black54)),
                            //     const SizedBox(width: 8),
                            //     Text(
                            //       matchProvider.currentRunRate.toStringAsFixed(1),
                            //       style: const TextStyle(
                            //           fontWeight: FontWeight.bold, fontSize: 16),
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   children: [
                            //     const Text('Projected score',
                            //         style: TextStyle(
                            //             fontSize: 14, color: Colors.black54)),
                            //     const SizedBox(width: 8),
                            //     Text(
                            //       matchProvider.projectedScore.toStringAsFixed(0),
                            //       style: const TextStyle(
                            //           fontWeight: FontWeight.bold, fontSize: 16),
                            //     ),
                            //   ],
                            // ),
                            Row(
                              children: [
                                const Text('Extras',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black54)),
                                const SizedBox(width: 8),
                                Text(
                                  'NB ${_countExtras(matchProvider, 'nb')}  WD ${_countExtras(matchProvider, 'wd')}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('RRR',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      matchProvider.requiredRunRate
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('CRR',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text(
                                      matchProvider.currentRunRate
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TO WIN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${matchProvider.runsNeeded} in ${matchProvider.ballsRemaining} balls',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            // THIS OVER widget
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'THIS OVER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${matchProvider.currentOverRuns} runs (${matchProvider.currentOverBallsLeft} ball${matchProvider.currentOverBallsLeft == 1 ? '' : 's'} left)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  matchProvider.currentOverBalls.isEmpty
                      ? const SizedBox(height: 36)
                      : Row(
                          children: matchProvider.currentOverBalls.reversed
                              .map<Widget>((ball) {
                            final display =
                                matchProvider.getBallDisplayString(ball);
                            Color bgColor;
                            if (display.startsWith('6')) {
                              bgColor = Colors.red.withOpacity(0.15);
                            } else if (display.startsWith('4')) {
                              bgColor = Colors.yellow.withOpacity(0.15);
                            } else if (display.startsWith('W')) {
                              bgColor = Colors.grey.withOpacity(0.3);
                            } else if (display.startsWith('Wd') ||
                                display.startsWith('Nb')) {
                              bgColor = Colors.blue.withOpacity(0.15);
                            } else {
                              bgColor = Colors.grey.withOpacity(0.1);
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bgColor,
                                ),
                                child: Center(
                                  child: Text(
                                    display,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            // Undo/Redo buttons (centered, icon only)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo, size: 28),
                    onPressed: () {
                      Provider.of<MatchProvider>(context, listen: false).undo();
                    },
                    tooltip: 'Undo',
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.redo, size: 28),
                    onPressed: () {
                      Provider.of<MatchProvider>(context, listen: false).redo();
                    },
                    tooltip: 'Redo',
                  ),
                ],
              ),
            ),
            // Scoring buttons area
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Left: Circular run buttons
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircleScoreButton(context, '0', 0),
                              _buildCircleScoreButton(context, '1', 1),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircleScoreButton(context, '2', 2),
                              _buildCircleScoreButton(context, '3', 3),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircleScoreButton(context, '4', 4),
                              _buildCircleScoreButton(context, '6', 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right: Rectangular action buttons
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRectScoreButton(context, 'WIDE BALL', -1),
                          const SizedBox(height: 16),
                          _buildRectScoreButton(context, 'NO BALL', -2),
                          const SizedBox(height: 16),
                          _buildRectScoreButton(context, 'WICKET', -3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringButton(BuildContext context, String label, int value) {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            if (value >= 0) {
              final position = await showDialog(
                context: context,
                builder: (context) => WagonWheelDialog(),
              );
              if (position != null) {
                matchProvider.addBall(value, wagonWheelPosition: position);
              }
            } else if (value == -1) {
              // Wide
              final additionalRuns = await showDialog(
                context: context,
                builder: (context) => ExtraRunsDialog(extraType: 'wd'),
              );
              if (additionalRuns != null) {
                matchProvider.addBall((1 + additionalRuns).toInt(),
                    isExtra: true, extraType: 'wd');
              }
            } else if (value == -2) {
              // No-ball
              final additionalRuns = await showDialog(
                context: context,
                builder: (context) => ExtraRunsDialog(extraType: 'nb'),
              );
              if (additionalRuns != null) {
                matchProvider.addBall((1 + additionalRuns).toInt(),
                    isExtra: true, extraType: 'nb');
              }
            } else if (value == -3) {
              // Wicket
              final battingTeam = matchProvider.battingTeam;
              final currentStriker = battingTeam.players.firstWhere(
                  (p) => p.id == matchProvider.currentStrikerId,
                  orElse: () => battingTeam.players.isNotEmpty
                      ? battingTeam.players[0]
                      : Player(id: '', name: 'Unknown'));
              final currentNonStriker = battingTeam.players
                  .firstWhere((p) => p.id == matchProvider.currentNonStrikerId,
                      orElse: () => battingTeam.players.length > 1
                          ? battingTeam.players[1]
                          : battingTeam.players.isNotEmpty
                              ? battingTeam.players[0]
                              : Player(id: '', name: 'Unknown'));

              final wicketDetails = await showDialog(
                context: context,
                builder: (context) => WicketDialog(
                  currentStriker: currentStriker,
                  currentNonStriker: currentNonStriker,
                ),
              );

              if (wicketDetails != null) {
                matchProvider.addWicket(
                  wicketDetails['runs'].toInt(),
                  wicketDetails['wicketType'].toString().split('.').last,
                  wicketDetails['runOutPlayerId'],
                );
                // After wicket, if innings not over, show new batter dialog
                if (matchProvider.totalWickets <
                    battingTeam.players.length - 1) {
                  _showNewBatterDialog();
                }
                // Check if over ended after wicket and show bowler selection if needed
                if (matchProvider.isOverEnd) {
                  _showBowlerSelectionDialog();
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
          child: Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w200,
                  color: Colors.black54,
                  letterSpacing: 1.2)),
        ));
  }

  int _countExtras(MatchProvider matchProvider, String extraType) {
    // Count extras of a given type in the current innings
    return matchProvider.currentInnings.overs
        .where((ball) => ball.isExtra && ball.extraType == extraType)
        .length;
  }

  String _getTeamScore(dynamic innings) {
    // innings is of type Innings
    final runs = innings.overs.fold(0, (sum, ball) => sum + ball.runs);
    final wickets = innings.wickets;
    return ' $runs/$wickets';
  }

  Widget _buildCircleScoreButton(
      BuildContext context, String label, int value) {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    return SizedBox(
      width: 64,
      height: 64,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(color: Color(0xFF888888), width: 0.5),
          foregroundColor: const Color(0xFF555555),
          backgroundColor: Colors.transparent,
        ),
        onPressed: () async {
          if (value >= 0) {
            final position = await showDialog(
              context: context,
              builder: (context) => WagonWheelDialog(),
            );
            if (position != null) {
              matchProvider.addBall(value, wagonWheelPosition: position);
            }
          }
        },
        child: Text(label,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF888888),
                letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildRectScoreButton(BuildContext context, String label, int value) {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: const BorderSide(color: Color(0xFF888888), width: 0.5),
          foregroundColor: const Color(0xFF555555),
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 16,
          ),
        ),
        onPressed: () async {
          if (value == -1) {
            // Wide
            final additionalRuns = await showDialog(
              context: context,
              builder: (context) => ExtraRunsDialog(extraType: 'wd'),
            );
            if (additionalRuns != null) {
              matchProvider.addBall((1 + additionalRuns).toInt(),
                  isExtra: true, extraType: 'wd');
            }
          } else if (value == -2) {
            // No-ball
            final additionalRuns = await showDialog(
              context: context,
              builder: (context) => ExtraRunsDialog(extraType: 'nb'),
            );
            if (additionalRuns != null) {
              matchProvider.addBall((1 + additionalRuns).toInt(),
                  isExtra: true, extraType: 'nb');
            }
          } else if (value == -3) {
            // Wicket
            final battingTeam = matchProvider.battingTeam;
            final currentStriker = battingTeam.players.firstWhere(
                (p) => p.id == matchProvider.currentStrikerId,
                orElse: () => battingTeam.players.isNotEmpty
                    ? battingTeam.players[0]
                    : Player(id: '', name: 'Unknown'));
            final currentNonStriker = battingTeam.players
                .firstWhere((p) => p.id == matchProvider.currentNonStrikerId,
                    orElse: () => battingTeam.players.length > 1
                        ? battingTeam.players[1]
                        : battingTeam.players.isNotEmpty
                            ? battingTeam.players[0]
                            : Player(id: '', name: 'Unknown'));

            final wicketDetails = await showDialog(
              context: context,
              builder: (context) => WicketDialog(
                currentStriker: currentStriker,
                currentNonStriker: currentNonStriker,
              ),
            );

            if (wicketDetails != null) {
              matchProvider.addWicket(
                wicketDetails['runs'].toInt(),
                wicketDetails['wicketType'].toString().split('.').last,
                wicketDetails['runOutPlayerId'],
              );
              // After wicket, if innings not over, show new batter dialog
              if (matchProvider.totalWickets < battingTeam.players.length - 1) {
                _showNewBatterDialog();
              }
              // Check if over ended after wicket and show bowler selection if needed
              if (matchProvider.isOverEnd) {
                _showBowlerSelectionDialog();
              }
            }
          }
        },
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF888888),
                letterSpacing: 2)),
      ),
    );
  }
}
