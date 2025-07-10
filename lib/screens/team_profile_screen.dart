
import 'package:cricket_scorer/models/team.dart';
import 'package:cricket_scorer/screens/player_profile_screen.dart';
import 'package:flutter/material.dart';

class TeamProfileScreen extends StatelessWidget {
  final Team team;

  TeamProfileScreen({required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team Name: ${team.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Players:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: team.players.length,
                itemBuilder: (context, index) {
                  final player = team.players[index];
                  return ListTile(
                    title: Text(player.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlayerProfileScreen(player: player)),
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
