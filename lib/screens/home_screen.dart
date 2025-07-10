import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/new_match_screen.dart';
import 'package:cricket_scorer/screens/scoring_screen.dart';
import 'package:cricket_scorer/screens/team_list_screen.dart';
import 'package:cricket_scorer/screens/match_summary_screen.dart';

import 'package:cricket_scorer/services/match_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cricket_scorer/providers/match_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MatchStorage _matchStorage = MatchStorage();
  List<String> _savedMatchIds = [];
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadSavedMatches();
    _loadTeams();
  }

  Future<void> _loadSavedMatches() async {
    final ids = await _matchStorage.listSavedMatches();
    setState(() {
      _savedMatchIds = ids;
    });
  }

  Future<void> _loadTeams() async {
    final loadedTeams = await _matchStorage.loadTeams();
    setState(() {
      _teams = loadedTeams;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cricket Scorer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewMatchScreen()),
                );
              },
              child: Text('New Match'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamListScreen(teams: _teams)),
                );
              },
              child: Text('View Teams'),
            ),
            SizedBox(height: 20),
            Text('Saved Matches:'),
            Expanded(
              child: ListView.builder(
                itemCount: _savedMatchIds.length,
                itemBuilder: (context, index) {
                  final matchId = _savedMatchIds[index];
                  return FutureBuilder(
                    future: _matchStorage.loadMatch(matchId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                          leading: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return ListTile(
                          title: Text('Error loading match'),
                          subtitle: Text(matchId),
                        );
                      }

                      final match = snapshot.data!;
                      final matchDate = DateFormat('MMM dd, yyyy - HH:mm')
                          .format(DateTime.parse(match.id));

                      // Check if match is complete
                      final innings1Runs = match.innings1.overs
                          .fold(0, (sum, ball) => sum + ball.runs);
                      final innings2Runs = match.innings2.overs
                          .fold(0, (sum, ball) => sum + ball.runs);
                      final isMatchComplete = (match.innings2.overs.length >=
                              match.totalOversPerInnings * 6 ||
                          match.innings2.wickets == 10 ||
                          innings2Runs > innings1Runs);

                      return ListTile(
                        title:
                            Text('${match.team1.name} vs ${match.team2.name}'),
                        subtitle: Text(matchDate),
                        trailing: isMatchComplete
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.play_circle_outline,
                                color: Colors.blue),
                        onTap: () async {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Small delay to show loading
                          await Future.delayed(Duration(milliseconds: 300));

                          Navigator.pop(context); // Close loading dialog

                          if (isMatchComplete) {
                            // Navigate to match summary for completed matches
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MatchSummaryScreen(match: match),
                              ),
                            );
                          } else {
                            // Navigate to scoring screen for ongoing matches
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (context) => MatchProvider(
                                    loadedMatch: match,
                                    totalOversPerInnings:
                                        match.totalOversPerInnings,
                                    onMatchEnd: (match) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MatchSummaryScreen(
                                                    match: match)),
                                      );
                                    },
                                    onInningsEnd: (innings, battingTeam,
                                        bowlingTeam, isMatchOver) {},
                                  ),
                                  child: ScoringScreen(),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
