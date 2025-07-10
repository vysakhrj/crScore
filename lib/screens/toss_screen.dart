import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:cricket_scorer/screens/scoring_screen.dart';
import 'package:cricket_scorer/screens/match_summary_screen.dart';
import 'package:cricket_scorer/widgets/innings_end_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TossScreen extends StatefulWidget {
  final Team team1;
  final Team team2;
  final int totalOvers;

  TossScreen(
      {required this.team1, required this.team2, required this.totalOvers});

  @override
  _TossScreenState createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> {
  Team? tossWinner;
  String? decision;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toss'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Who won the toss?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tossWinner = widget.team1;
                    });
                  },
                  child: Text(widget.team1.name),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        tossWinner == widget.team1 ? Colors.green : null),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tossWinner = widget.team2;
                    });
                  },
                  child: Text(widget.team2.name),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        tossWinner == widget.team2 ? Colors.green : null),
                  ),
                ),
              ],
            ),
            if (tossWinner != null) ...[
              SizedBox(height: 20),
              Text('${tossWinner!.name} won the toss and chose to:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        decision = 'bat';
                      });
                    },
                    child: Text('Bat'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          decision == 'bat' ? Colors.green : null),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        decision = 'bowl';
                      });
                    },
                    child: Text('Bowl'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          decision == 'bowl' ? Colors.green : null),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (tossWinner != null && decision != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (context) => MatchProvider(
                              team1: widget.team1,
                              team2: widget.team2,
                              tossWinnerId: tossWinner!.id,
                              decision: decision!,
                              totalOversPerInnings: widget.totalOvers,
                              onMatchEnd: (match) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MatchSummaryScreen(match: match)),
                                );
                              },
                              onInningsEnd: (innings, battingTeam, bowlingTeam, isMatchOver) {},
                            ),
                            child: ScoringScreen(),
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text('Start Scoring'),
            ),
          ],
        ),
      ),
    );
  }
}
