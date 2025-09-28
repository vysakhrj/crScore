import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/new_match_screen.dart';
import 'package:cricket_scorer/screens/scoring_screen.dart';
import 'package:cricket_scorer/screens/team_list_screen.dart';
import 'package:cricket_scorer/screens/match_summary_screen.dart';
import 'package:cricket_scorer/screens/tennis_tournament_screen.dart';

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'CRICKET SCORER',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            // Action buttons section
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'NEW MATCH',
                    Icons.add_circle_outline,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewMatchScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    'VIEW TEAMS',
                    Icons.group_outlined,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TeamListScreen(teams: _teams)),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'BADMINTON TOURNAMENT',
                    Icons.sports_tennis,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TennisTournamentScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Saved matches section
            Text(
              'SAVED MATCHES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadSavedMatches();
                },
                child: _savedMatchIds.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _savedMatchIds.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          // Get match ID from reversed list to show latest first
                          final matchId =
                              _savedMatchIds[_savedMatchIds.length - 1 - index];
                          return _buildMatchCard(matchId);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[800],
          elevation: 2,
          shadowColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_cricket_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No saved matches',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new match to see it here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(String matchId) {
    return FutureBuilder(
      future: _matchStorage.loadMatch(matchId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard(matchId);
        }

        final match = snapshot.data!;
        final matchDate =
            DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.parse(match.id));

        final innings1Runs =
            match.innings1.overs.fold(0, (sum, ball) => sum + ball.runs);
        final innings2Runs =
            match.innings2.overs.fold(0, (sum, ball) => sum + ball.runs);
        final isMatchComplete =
            (match.innings2.overs.length >= match.totalOversPerInnings * 6 ||
                match.innings2.wickets == 10 ||
                innings2Runs > innings1Runs);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleMatchTap(match, isMatchComplete),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${match.team1.name} vs ${match.team2.name}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMatchComplete
                                ? Colors.green[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMatchComplete
                                  ? Colors.green[200]!
                                  : Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMatchComplete
                                    ? Icons.check_circle
                                    : Icons.play_circle_outline,
                                color: isMatchComplete
                                    ? Colors.green[600]
                                    : Colors.blue[600],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isMatchComplete ? 'COMPLETE' : 'IN PROGRESS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isMatchComplete
                                      ? Colors.green[600]
                                      : Colors.blue[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Match details
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          matchDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Scores section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildTeamScore(match.team1.name, innings1Runs,
                              match.innings1.wickets, true),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                          const SizedBox(height: 12),
                          _buildTeamScore(match.team2.name, innings2Runs,
                              match.innings2.wickets, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamScore(String teamName, int runs, int wickets, bool isTeam1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teamName.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              runs == 0 && !isTeam1 ? '-------' : '$runs/$wickets',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String matchId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Error loading match',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Match ID: $matchId',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMatchTap(dynamic match, bool isMatchComplete) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading match...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    Navigator.pop(context);

    if (isMatchComplete) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchSummaryScreen(match: match),
        ),
      );
    } else {
      Navigator.push(
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
                      builder: (context) => MatchSummaryScreen(match: match)),
                );
              },
              onInningsEnd: (innings, battingTeam, bowlingTeam, isMatchOver) {},
            ),
            child: ScoringScreen(),
          ),
        ),
      );
    }
  }
}
