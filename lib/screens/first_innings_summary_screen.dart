import 'package:cricket_scorer/models/match.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:cricket_scorer/screens/scoring_screen.dart';
import 'package:cricket_scorer/screens/match_summary_screen.dart';
import 'package:cricket_scorer/widgets/player_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class FirstInningsSummaryScreen extends StatelessWidget {
  final Match match;

  const FirstInningsSummaryScreen({Key? key, required this.match})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final innings1Runs =
        match.innings1.overs.fold(0, (sum, ball) => sum + ball.runs);
    final targetRuns = innings1Runs + 1;
    final totalBalls = match.totalOversPerInnings * 6;

    // Get batting team for first innings
    final battingTeam = match.innings1.battingTeamId == match.team1.id
        ? match.team1
        : match.team2;
    final bowlingTeam = match.innings1.bowlingTeamId == match.team1.id
        ? match.team1
        : match.team2;

    return Scaffold(
      appBar: AppBar(
        title: Text('${match.team1.name} vs ${match.team2.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                DateFormat('MMM dd, yyyy - HH:mm')
                    .format(DateTime.parse(match.id)),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First innings summary header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'First Innings Complete',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${battingTeam.name}: $innings1Runs/${match.innings1.wickets}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Target: $targetRuns runs in $totalBalls balls',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Scorecard section
            Text(
              'Scorecard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batting summary
                      Text(
                        '${battingTeam.name} - Batting',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Create batting stats
                      ...battingTeam.players.map((player) {
                        final playerBalls = match.innings1.overs
                            .where((ball) => ball.strikerId == player.id)
                            .toList();
                        final runs =
                            playerBalls.fold(0, (sum, ball) => sum + ball.runs);
                        final ballsFaced = playerBalls.length;
                        final isOut = match.innings1.overs.any((ball) =>
                            ball.wicketType != null &&
                            (ball.strikerId == player.id ||
                                ball.runOutPlayerId == player.id));

                        if (ballsFaced > 0 || isOut) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${player.name}${isOut ? ' (out)' : ''}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('$runs',
                                      textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('$ballsFaced',
                                      textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    ballsFaced > 0
                                        ? ((runs / ballsFaced) * 100)
                                            .toStringAsFixed(1)
                                        : '0.0',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }).toList(),

                      SizedBox(height: 16),

                      // Bowling summary
                      Text(
                        '${bowlingTeam.name} - Bowling',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      ...bowlingTeam.players.map((player) {
                        final playerBalls = match.innings1.overs
                            .where((ball) => ball.bowlerId == player.id)
                            .toList();
                        final runs =
                            playerBalls.fold(0, (sum, ball) => sum + ball.runs);
                        final ballsBowled = playerBalls.length;
                        final wickets = playerBalls
                            .where((ball) => ball.wicketType != null)
                            .length;

                        if (ballsBowled > 0) {
                          final overs =
                              '${(ballsBowled ~/ 6)}.${ballsBowled % 6}';
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(player.name,
                                      style: TextStyle(fontSize: 14)),
                                ),
                                Expanded(
                                  flex: 1,
                                  child:
                                      Text(overs, textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('$runs',
                                      textAlign: TextAlign.center),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text('$wickets',
                                      textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Start second innings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startSecondInnings(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Start Second Innings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSecondInnings(BuildContext context) async {
    // Get second innings teams
    final secondInningsBattingTeam =
        match.innings2.battingTeamId == match.team1.id
            ? match.team1
            : match.team2;
    final secondInningsBowlingTeam =
        match.innings2.bowlingTeamId == match.team1.id
            ? match.team1
            : match.team2;

    // Show player selection dialog
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlayerSelectionDialog(
        battingTeamPlayers: secondInningsBattingTeam.players,
        bowlingTeamPlayers: secondInningsBowlingTeam.players,
      ),
    );

    if (result != null) {
      // Navigate to scoring screen with provider
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => MatchProvider(
              loadedMatch: match,
              totalOversPerInnings: match.totalOversPerInnings,
              onMatchEnd: (match) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchSummaryScreen(match: match),
                  ),
                );
              },
            ),
            child: SecondInningsInitializer(
              strikerPlayerId: result['striker'].id,
              nonStrikerPlayerId: result['nonStriker'].id,
              bowlerPlayerId: result['bowler'].id,
            ),
          ),
        ),
      );
    }
  }
}

class SecondInningsInitializer extends StatefulWidget {
  final String strikerPlayerId;
  final String nonStrikerPlayerId;
  final String bowlerPlayerId;

  const SecondInningsInitializer({
    Key? key,
    required this.strikerPlayerId,
    required this.nonStrikerPlayerId,
    required this.bowlerPlayerId,
  }) : super(key: key);

  @override
  _SecondInningsInitializerState createState() =>
      _SecondInningsInitializerState();
}

class _SecondInningsInitializerState extends State<SecondInningsInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize players after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      matchProvider.initializeSecondInnings();
      matchProvider.setStriker(widget.strikerPlayerId);
      matchProvider.setNonStriker(widget.nonStrikerPlayerId);
      matchProvider.setBowler(widget.bowlerPlayerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScoringScreen();
  }
}
