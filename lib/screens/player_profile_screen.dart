
import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  PlayerProfileScreen({required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player Name: ${player.name}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Runs Scored: N/A'), // To be calculated
            Text('Wickets Taken: N/A'), // To be calculated
            // Add more player statistics here
          ],
        ),
      ),
    );
  }
}
