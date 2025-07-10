import 'package:cricket_scorer/models/innings.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:flutter/material.dart';

class InningsEndDialog extends StatelessWidget {
  final MatchProvider matchProvider;
  final Innings innings;
  final Team battingTeam;
  final Team bowlingTeam;
  final bool isMatchOver;

  InningsEndDialog({required this.matchProvider, required this.innings, required this.battingTeam, required this.bowlingTeam, required this.isMatchOver});

  @override
  Widget build(BuildContext context) {
    final totalRuns = innings.overs.fold(0, (sum, ball) => sum + ball.runs);

    return AlertDialog(
      title: Text(isMatchOver ? 'Match Over!' : 'Innings Over!'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${battingTeam.name} Innings Summary:'),
            Text('Score: $totalRuns/${innings.wickets}'),
            if (!isMatchOver) ...[
              Text('Target for ${bowlingTeam.name}: ${totalRuns + 1}'),
            ],
            // You can add a full scorecard here by reusing _buildInningsCard from ScorecardScreen
            // For now, just showing summary
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, isMatchOver ? 'summary' : 'next_innings');
          },
          child: Text(isMatchOver ? 'View Match Summary' : 'Start Next Innings'),
        ),
      ],
    );
  }
}