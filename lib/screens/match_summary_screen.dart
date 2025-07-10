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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Result
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Match Result',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      resultText,
                      style: const TextStyle(fontSize: 20, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${match.team1.name}: $innings1Runs/${match.innings1.wickets}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${match.team2.name}: $innings2Runs/${match.innings2.wickets}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Best Batter
            if (bestBatter != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🏏 Best Batter',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bestBatter['player'].name}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                          'Runs: ${bestBatter['runs']} | Balls: ${bestBatter['balls']} | SR: ${bestBatter['strikeRate'].toStringAsFixed(1)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Best Bowler
            if (bestBowler != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Best Bowler',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bestBowler['player'].name}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text(
                          'Wickets: ${bestBowler['wickets']} | Overs: ${bestBowler['overs']} | Econ: ${bestBowler['economy'].toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Man of the Match
            if (manOfTheMatch != null) ...[
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🏆 Man of the Match',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${manOfTheMatch['player'].name}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Text('${manOfTheMatch['reason']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: Icon(Icons.score),
                    label: Text('Scorecard'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WormGraphScreen(match: match),
                        ),
                      );
                    },
                    icon: Icon(Icons.show_chart),
                    label: Text('Worm Graph'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Back to Home Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
