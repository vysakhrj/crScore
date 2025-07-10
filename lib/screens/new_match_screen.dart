import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/create_team_screen.dart';
import 'package:cricket_scorer/screens/toss_screen.dart';
import 'package:cricket_scorer/services/match_storage.dart';
import 'package:flutter/material.dart';

class NewMatchScreen extends StatefulWidget {
  @override
  _NewMatchScreenState createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  List<Team> teams = [];
  Team? team1;
  Team? team2;
  final TextEditingController _oversController = TextEditingController(text: '20'); // Default to 20 overs
  final MatchStorage _matchStorage = MatchStorage();

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final loadedTeams = await _matchStorage.loadTeams();
    setState(() {
      teams = loadedTeams;
    });
  }

  Future<void> _saveTeams() async {
    await _matchStorage.saveTeams(teams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final newTeam = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTeamScreen()),
                );
                if (newTeam != null) {
                  setState(() {
                    teams.add(newTeam);
                  });
                  _saveTeams();
                }
              },
              child: Text('Create Team'),
            ),
            SizedBox(height: 20),
            DropdownButton<Team>(
              hint: Text('Select Team 1'),
              value: team1,
              onChanged: (Team? newValue) {
                setState(() {
                  team1 = newValue;
                });
              },
              items: teams.map<DropdownMenuItem<Team>>((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<Team>(
              hint: Text('Select Team 2'),
              value: team2,
              onChanged: (Team? newValue) {
                setState(() {
                  team2 = newValue;
                });
              },
              items: teams.map<DropdownMenuItem<Team>>((Team team) {
                return DropdownMenuItem<Team>(
                  value: team,
                  child: Text(team.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _oversController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Overs per Innings',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (team1 != null && team2 != null && team1 != team2 && int.tryParse(_oversController.text) != null) ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TossScreen(team1: team1!, team2: team2!, totalOvers: int.parse(_oversController.text))),
                );
              } : null,
              child: Text('Start Match'),
            ),
          ],
        ),
      ),
    );
  }
}