import 'package:flutter/material.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/create_team_screen.dart';
import 'package:cricket_scorer/screens/toss_screen.dart';
import 'package:cricket_scorer/services/match_storage.dart';

class NewMatchScreen extends StatefulWidget {
  @override
  _NewMatchScreenState createState() => _NewMatchScreenState();
}

class _NewMatchScreenState extends State<NewMatchScreen> {
  List<Team> teams = [];
  Team? team1;
  Team? team2;
  final TextEditingController _oversController =
      TextEditingController(text: '10'); // Matches image default
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

  Widget buildDropdown({
    required String label,
    required Team? value,
    required void Function(Team?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<Team>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),
            onChanged: onChanged,
            items: teams
                .map((team) => DropdownMenuItem<Team>(
                      value: team,
                      child: Text(team.name),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget buildOversInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("OVERS".toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: _oversController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            hintText: "e.g. 10",
          ),
        ),
      ],
    );
  }

  Widget buildFlatButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStartEnabled = team1 != null &&
        team2 != null &&
        team1 != team2 &&
        int.tryParse(_oversController.text) != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NEW MATCH',
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFlatButton('CREATE TEAM', () async {
              final newTeam = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateTeamScreen()),
              );
              if (newTeam != null) {
                setState(() => teams.add(newTeam));
                _saveTeams();
              }
            }),
            const SizedBox(height: 24),
            buildDropdown(
              label: 'Team 1',
              value: team1,
              onChanged: (val) => setState(() => team1 = val),
            ),
            const SizedBox(height: 24),
            buildDropdown(
              label: 'Team 2',
              value: team2,
              onChanged: (val) => setState(() => team2 = val),
            ),
            const SizedBox(height: 24),
            buildOversInput(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isStartEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TossScreen(
                              team1: team1!,
                              team2: team2!,
                              totalOvers: int.parse(_oversController.text),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isStartEnabled ? Colors.black : Colors.black26,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text(
                  'START MATCH',
                  style: TextStyle(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
