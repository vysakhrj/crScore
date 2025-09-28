import 'package:cricket_scorer/models/match.dart';
import 'package:flutter/material.dart';
import 'package:cricket_scorer/screens/scorecard_screen.dart';
import 'package:cricket_scorer/screens/worm_graph_screen.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MatchSummaryScreen extends StatelessWidget {
  final Match match;

  const MatchSummaryScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final innings1Runs =
        match.innings1.overs.fold(0, (sum, ball) => sum + ball.runs);
    final innings2Runs =
        match.innings2.overs.fold(0, (sum, ball) => sum + ball.runs);

    // Determine match result
    String resultText = '';
    String winningTeam = '';
    if (innings1Runs > innings2Runs) {
      winningTeam = match.innings1.battingTeamId == match.team1.id
          ? match.team1.name
          : match.team2.name;
      resultText = '$winningTeam won by ${innings1Runs - innings2Runs} runs';
    } else if (innings2Runs > innings1Runs) {
      winningTeam = match.innings2.battingTeamId == match.team1.id
          ? match.team1.name
          : match.team2.name;
      resultText = '$winningTeam won by ${innings2Runs - innings1Runs} runs';
    } else {
      resultText = 'Match Tied';
    }

    // Calculate player statistics
    final battingStats = _calculateBattingStats();
    final bowlingStats = _calculateBowlingStats();

    // Find best performers
    final bestBatter = _findBestBatter(battingStats);
    final bestBowler = _findBestBowler(bowlingStats);
    final manOfTheMatch = _findManOfTheMatch(battingStats, bowlingStats);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Result Card
            Container(
              width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'MATCH RESULT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A8B9A),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      resultText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Team scores display
                    Row(
                      children: [
                        Expanded(
                          child: _buildTeamScore(
                            match.team1.name,
                            match.team1.id == match.innings1.battingTeamId
                                ? innings1Runs
                                : innings2Runs,
                            match.innings1.wickets,
                            true,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: const Color(0xFFE9ECEF),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        Expanded(
                          child: _buildTeamScore(
                            match.team2.name,
                            match.team2.id == match.innings2.battingTeamId
                                ? innings2Runs
                                : innings1Runs,
                            match.innings2.wickets,
                            false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Performance Cards
            if (bestBatter != null) ...[
              _buildPerformanceCard(
                title: 'BEST BATTER',
                icon: '🏏',
                playerName: bestBatter['player'].name,
                stats:
                    'Runs: ${bestBatter['runs']} • Balls: ${bestBatter['balls']} • SR: ${bestBatter['strikeRate'].toStringAsFixed(1)}',
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
            ],

            if (bestBowler != null) ...[
              _buildPerformanceCard(
                title: 'BEST BOWLER',
                icon: '🎯',
                playerName: bestBowler['player'].name,
                stats:
                    'Wickets: ${bestBowler['wickets']} • Overs: ${bestBowler['overs']} • Econ: ${bestBowler['economy'].toStringAsFixed(2)}',
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
            ],

            if (manOfTheMatch != null) ...[
              _buildPerformanceCard(
                title: 'MAN OF THE MATCH',
                icon: '🏆',
                playerName: manOfTheMatch['player'].name,
                stats: manOfTheMatch['reason'],
                backgroundColor: const Color(0xFFFFF8E1),
                isHighlighted: true,
              ),
              const SizedBox(height: 32),
            ],

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.assignment,
                    label: 'Scorecard',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) =>
                                MatchProvider(loadedMatch: match),
                            builder: (context, child) => ScorecardScreen(
                              matchProvider: Provider.of<MatchProvider>(context,
                                  listen: false),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.show_chart,
                    label: 'Worm Graph',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WormGraphScreen(match: match),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Back to Home Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A8B9A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int runs, int wickets, bool isLeft) {
    return Column(
      crossAxisAlignment:
          isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          teamName.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7A8B9A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: runs.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              TextSpan(
                text: '/$wickets',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A8B9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard({
    required String title,
    required String icon,
    required String playerName,
    required String stats,
    required Color backgroundColor,
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: const Color(0xFFFFD54F), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? const Color(0xFFFFD54F).withOpacity(0.2)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A8B9A),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A8B9A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF2C3E50),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (keeping all the existing calculation methods unchanged)
  Map<String, Map<String, dynamic>> _calculateBattingStats() {
    final stats = <String, Map<String, dynamic>>{};

    // Initialize stats for all players
    for (final player in [...match.team1.players, ...match.team2.players]) {
      stats[player.id] = {
        'player': player,
        'runs': 0,
        'balls': 0,
        'wickets': 0,
      };
    }

    // Calculate stats from both innings
    for (final ball in [...match.innings1.overs, ...match.innings2.overs]) {
      if (stats.containsKey(ball.strikerId)) {
        stats[ball.strikerId]!['runs'] += ball.runs;
        stats[ball.strikerId]!['balls'] += 1;
      }

      if (ball.wicketType != null && ball.wicketType != 'runOut') {
        if (stats.containsKey(ball.strikerId)) {
          stats[ball.strikerId]!['wickets'] += 1;
        }
      }
    }

    // Calculate strike rates
    for (final stat in stats.values) {
      if (stat['balls'] > 0) {
        stat['strikeRate'] = (stat['runs'] / stat['balls']) * 100;
      } else {
        stat['strikeRate'] = 0.0;
      }
    }

    return stats;
  }

  Map<String, Map<String, dynamic>> _calculateBowlingStats() {
    final stats = <String, Map<String, dynamic>>{};

    // Initialize stats for all players
    for (final player in [...match.team1.players, ...match.team2.players]) {
      stats[player.id] = {
        'player': player,
        'wickets': 0,
        'runs': 0,
        'balls': 0,
      };
    }

    // Calculate stats from both innings
    for (final ball in [...match.innings1.overs, ...match.innings2.overs]) {
      if (stats.containsKey(ball.bowlerId)) {
        stats[ball.bowlerId]!['runs'] += ball.runs;
        stats[ball.bowlerId]!['balls'] += 1;

        if (ball.wicketType != null && ball.wicketType != 'runOut') {
          stats[ball.bowlerId]!['wickets'] += 1;
        }
      }
    }

    // Calculate economy rates and overs
    for (final stat in stats.values) {
      final overs = stat['balls'] / 6;
      stat['overs'] = overs.toStringAsFixed(1);
      if (overs > 0) {
        stat['economy'] = (stat['runs'] / overs);
      } else {
        stat['economy'] = 0.0;
      }
    }

    return stats;
  }

  Map<String, dynamic>? _findBestBatter(
      Map<String, Map<String, dynamic>> battingStats) {
    Map<String, dynamic>? bestBatter;
    int maxRuns = 0;
    double maxStrikeRate = 0.0;

    for (final stat in battingStats.values) {
      if (stat['runs'] > maxRuns ||
          (stat['runs'] == maxRuns && stat['strikeRate'] > maxStrikeRate)) {
        maxRuns = stat['runs'];
        maxStrikeRate = stat['strikeRate'];
        bestBatter = stat;
      }
    }

    return bestBatter;
  }

  Map<String, dynamic>? _findBestBowler(
      Map<String, Map<String, dynamic>> bowlingStats) {
    Map<String, dynamic>? bestBowler;
    int maxWickets = 0;
    double minEconomy = double.infinity;

    for (final stat in bowlingStats.values) {
      if (stat['wickets'] > maxWickets ||
          (stat['wickets'] == maxWickets && stat['economy'] < minEconomy)) {
        maxWickets = stat['wickets'];
        minEconomy = stat['economy'];
        bestBowler = stat;
      }
    }

    return bestBowler;
  }

  Map<String, dynamic>? _findManOfTheMatch(
    Map<String, Map<String, dynamic>> battingStats,
    Map<String, Map<String, dynamic>> bowlingStats,
  ) {
    Map<String, dynamic>? manOfTheMatch;
    double maxScore = 0.0;

    for (final stat in battingStats.values) {
      if (stat['runs'] > 0) {
        // Calculate a composite score: runs + (strike rate * 0.1) + (runs * 0.5 if > 50)
        double score = stat['runs'].toDouble();
        score += (stat['strikeRate'] * 0.1);
        if (stat['runs'] >= 50) score += (stat['runs'] * 0.5);

        if (score > maxScore) {
          maxScore = score;
          manOfTheMatch = {
            'player': stat['player'],
            'reason':
                'Outstanding batting performance with ${stat['runs']} runs',
          };
        }
      }
    }

    for (final stat in bowlingStats.values) {
      if (stat['wickets'] > 0) {
        // Calculate a composite score: wickets * 25 + (50 - economy * 10) if economy < 5
        double score = stat['wickets'] * 25.0;
        if (stat['economy'] < 5.0) {
          score += (50 - stat['economy'] * 10);
        }

        if (score > maxScore) {
          maxScore = score;
          manOfTheMatch = {
            'player': stat['player'],
            'reason':
                'Excellent bowling with ${stat['wickets']} wickets at economy ${stat['economy'].toStringAsFixed(2)}',
          };
        }
      }
    }

    return manOfTheMatch;
  }
}
