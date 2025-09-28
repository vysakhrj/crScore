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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          '${match.team1.name} vs ${match.team2.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                DateFormat('MMM dd, yyyy').format(DateTime.parse(match.id)),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7A8B9A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First innings summary header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF45A049),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'FIRST INNINGS COMPLETE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: battingTeam.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const TextSpan(
                            text: '\n',
                            style: TextStyle(fontSize: 8),
                          ),
                          TextSpan(
                            text: innings1Runs.toString(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: '/${match.innings1.wickets}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Target: $targetRuns runs in $totalBalls balls',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Scorecard section
            const Text(
              'SCORECARD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A8B9A),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batting summary
                      _buildSectionHeader(
                          '${battingTeam.name} - Batting', '🏏'),
                      const SizedBox(height: 16),
                      _buildStatsHeader(['Player', 'Runs', 'Balls', 'S/R']),
                      const SizedBox(height: 8),

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
                          return _buildStatRow([
                            '${player.name}${isOut ? ' (out)' : ''}',
                            runs.toString(),
                            ballsFaced.toString(),
                            ballsFaced > 0
                                ? ((runs / ballsFaced) * 100).toStringAsFixed(1)
                                : '0.0',
                          ], isOut);
                        }
                        return const SizedBox.shrink();
                      }).toList(),

                      const SizedBox(height: 32),

                      // Bowling summary
                      _buildSectionHeader(
                          '${bowlingTeam.name} - Bowling', '🎯'),
                      const SizedBox(height: 16),
                      _buildStatsHeader(['Player', 'Overs', 'Runs', 'Wkts']),
                      const SizedBox(height: 8),

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
                          return _buildStatRow([
                            player.name,
                            overs,
                            runs.toString(),
                            wickets.toString(),
                          ], false);
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Start second innings button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: MaterialButton(
                onPressed: () => _startSecondInnings(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Start Second Innings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildSectionHeader(String title, String emoji) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;

          return Expanded(
            flex: index == 0 ? 3 : 1,
            child: Text(
              header,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A8B9A),
                letterSpacing: 0.5,
              ),
              textAlign: index == 0 ? TextAlign.left : TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatRow(List<String> values, bool isOut) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isOut ? const Color(0xFFFFF3E0) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isOut ? Border.all(color: const Color(0xFFFFCC80)) : null,
      ),
      child: Row(
        children: values.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;

          return Expanded(
            flex: index == 0 ? 3 : 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                color:
                    isOut ? const Color(0xFFE65100) : const Color(0xFF2C3E50),
              ),
              textAlign: index == 0 ? TextAlign.left : TextAlign.center,
            ),
          );
        }).toList(),
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
