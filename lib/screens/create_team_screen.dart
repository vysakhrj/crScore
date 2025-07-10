
import 'package:cricket_scorer/models/player.dart';
import 'package:cricket_scorer/models/team.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _teamNameController = TextEditingController();
  final _playerNameController = TextEditingController();
  List<Player> players = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(labelText: 'Team Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _playerNameController,
              decoration: InputDecoration(labelText: 'Player Name'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  players.add(Player(id: Uuid().v4(), name: _playerNameController.text));
                  _playerNameController.clear();
                });
              },
              child: Text('Add Player'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index].name),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final team = Team(id: Uuid().v4(), name: _teamNameController.text, players: players);
                Navigator.pop(context, team);
              },
              child: Text('Save Team'),
            ),
          ],
        ),
      ),
    );
  }
}
