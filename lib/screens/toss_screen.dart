import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:cricket_scorer/screens/match_summary_screen.dart';
import 'package:cricket_scorer/screens/scoring_screen.dart';

class TossScreen extends StatefulWidget {
  final Team team1;
  final Team team2;
  final int totalOvers;

  TossScreen({
    required this.team1,
    required this.team2,
    required this.totalOvers,
  });

  @override
  _TossScreenState createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> {
  Team? tossWinner;
  String? decision;

  ButtonStyle getOptionButtonStyle(bool selected) {
    return OutlinedButton.styleFrom(
      backgroundColor: selected ? Colors.black : Colors.white,
      foregroundColor: selected ? Colors.white : Colors.black,
      minimumSize: const Size(120, 44),
      side: BorderSide(
        color: selected ? Colors.white : Colors.black12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
    );
  }

  TextStyle getLabelStyle() => const TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      );

  @override
  Widget build(BuildContext context) {
    final bool canStart = tossWinner != null && decision != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'SELECT TOSS',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WHO WON THE TOSS?", style: getLabelStyle()),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => tossWinner = widget.team1),
                  style: getOptionButtonStyle(tossWinner == widget.team1),
                  child: Text(widget.team1.name
                      .substring(
                          0,
                          widget.team1.name.length > 10
                              ? 10
                              : widget.team1.name.length)
                      .toUpperCase()),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => tossWinner = widget.team2),
                  style: getOptionButtonStyle(tossWinner == widget.team2),
                  child: Text(widget.team2.name
                      .substring(
                          0,
                          widget.team2.name.length > 10
                              ? 10
                              : widget.team2.name.length)
                      .toUpperCase()),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (tossWinner != null) ...[
              Text("DECISION", style: getLabelStyle()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => decision = 'bat'),
                    style: getOptionButtonStyle(decision == 'bat'),
                    child: const Text('BAT'),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(() => decision = 'bowl'),
                    style: getOptionButtonStyle(decision == 'bowl'),
                    child: const Text('BOWL'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canStart
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => MatchProvider(
                                team1: widget.team1,
                                team2: widget.team2,
                                tossWinnerId: tossWinner!.id,
                                decision: decision!,
                                totalOversPerInnings: widget.totalOvers,
                                onMatchEnd: (match) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MatchSummaryScreen(match: match),
                                    ),
                                  );
                                },
                                onInningsEnd: (_, __, ___, ____) {},
                              ),
                              child: ScoringScreen(),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canStart ? Colors.black87 : Colors.grey[400],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("START SCORING"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
