import 'package:cricket_scorer/models/innings.dart';
import 'package:cricket_scorer/models/player.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScorecardScreen extends StatelessWidget {
  final MatchProvider matchProvider;

  ScorecardScreen({required this.matchProvider});

  @override
  Widget build(BuildContext context) {
    final match = matchProvider.match;

    // Determine the actual batting and bowling teams for Innings 1
    final innings1BattingTeam = match.innings1.battingTeamId == match.team1.id ? match.team1 : match.team2;
    final innings1BowlingTeam = match.innings1.bowlingTeamId == match.team1.id ? match.team1 : match.team2;

    // Determine the actual batting and bowling teams for Innings 2
    final innings2BattingTeam = match.innings2.battingTeamId == match.team1.id ? match.team1 : match.team2;
    final innings2BowlingTeam = match.innings2.bowlingTeamId == match.team1.id ? match.team1 : match.team2;


    return Scaffold(
      appBar: AppBar(
        title: Text('Scorecard'),
      ),
      body: ListView(
        children: [
          _buildInningsCard(match.innings1, innings1BattingTeam, innings1BowlingTeam),
          _buildInningsCard(match.innings2, innings2BattingTeam, innings2BowlingTeam),
        ],
      ),
    );
  }

  Widget _buildInningsCard(Innings innings, Team battingTeam, Team bowlingTeam) {
    Map<String, int> playerScores = {};
    Map<String, int> playerBallsFaced = {};

    for (var ball in innings.overs) {
      if (!ball.isExtra) {
        playerScores.update(ball.strikerId, (value) => value + ball.runs, ifAbsent: () => ball.runs);
        playerBallsFaced.update(ball.strikerId, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${battingTeam.name} Innings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Score: ${innings.overs.fold(0, (sum, ball) => sum + ball.runs)}/${innings.wickets}'),
            SizedBox(height: 10),
            Text('Batting:', style: TextStyle(fontWeight: FontWeight.bold)),
            Table(
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Text('Player', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Runs', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Balls', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('SR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                ...playerScores.entries.map((entry) {
                  final player = battingTeam.players.firstWhere((p) => p.id == entry.key, orElse: () => Player(id: entry.key, name: 'Unknown Player'));
                  final runs = entry.value;
                  final balls = playerBallsFaced[entry.key] ?? 0;
                  final strikeRate = balls > 0 ? (runs / balls * 100).toStringAsFixed(2) : '0.00';
                  return TableRow(
                    children: [
                      Text(player.name),
                      Text('$runs'),
                      Text('$balls'),
                      Text(strikeRate),
                    ],
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 20),
            Text('Bowling:', style: TextStyle(fontWeight: FontWeight.bold)),
            Table(
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Text('Bowler', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Overs', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Runs', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Wickets', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Avg', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                ..._getBowlerStats(innings, bowlingTeam).entries.map((entry) {
                  final bowler = bowlingTeam.players.firstWhere((p) => p.id == entry.key, orElse: () => Player(id: entry.key, name: 'Unknown Bowler'));
                  final stats = entry.value;
                  final overs = '${stats['overs']! ~/ 6}.${stats['overs']! % 6}';
                  final runs = stats['runs'];
                  final wickets = stats['wickets'];
                  final average = wickets! > 0 ? (runs! / wickets!).toStringAsFixed(2) : '-';
                  return TableRow(
                    children: [
                      Text(bowler.name),
                      Text(overs),
                      Text('$runs'),
                      Text('$wickets'),
                      Text(average),
                    ],
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 20),
            Text('Fall of Wickets:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: innings.fallOfWickets.length,
              itemBuilder: (context, index) {
                final fow = innings.fallOfWickets[index];
                final player = battingTeam.players.firstWhere((p) => p.id == fow.playerId, orElse: () => Player(id: fow.playerId, name: 'Unknown Player'));
                return Text('${fow.wicketNumber}-${player.name} (${fow.runs})');
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, int>> _getBowlerStats(Innings innings, Team bowlingTeam) {
    Map<String, Map<String, int>> bowlerStats = {};

    for (var ball in innings.overs) {
      bowlerStats.putIfAbsent(ball.bowlerId, () => {'overs': 0, 'runs': 0, 'wickets': 0});

      if (!ball.isExtra) {
        bowlerStats[ball.bowlerId]!['overs'] = bowlerStats[ball.bowlerId]!['overs']! + 1;
        bowlerStats[ball.bowlerId]!['runs'] = bowlerStats[ball.bowlerId]!['runs']! + ball.runs;
      } else if (ball.extraType == 'wd' || ball.extraType == 'nb') {
        bowlerStats[ball.bowlerId]!['runs'] = bowlerStats[ball.bowlerId]!['runs']! + ball.runs;
      }

      if (ball.wicketType != null && ball.wicketType != 'runOut') {
        bowlerStats[ball.bowlerId]!['wickets'] = bowlerStats[ball.bowlerId]!['wickets']! + 1;
      }
    }
    return bowlerStats;
  }
}