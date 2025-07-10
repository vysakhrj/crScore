
import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class PlayerSelectionDialog extends StatefulWidget {
  final List<Player> battingTeamPlayers;
  final List<Player> bowlingTeamPlayers;

  PlayerSelectionDialog({required this.battingTeamPlayers, required this.bowlingTeamPlayers});

  @override
  _PlayerSelectionDialogState createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  Player? selectedStriker;
  Player? selectedNonStriker;
  Player? selectedBowler;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Players', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            DropdownButton<Player>(
              hint: Text('Select Striker'),
              value: selectedStriker,
              onChanged: (Player? newValue) {
                setState(() {
                  selectedStriker = newValue;
                });
              },
              items: widget.battingTeamPlayers.map<DropdownMenuItem<Player>>((Player player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButton<Player>(
              hint: Text('Select Non-Striker'),
              value: selectedNonStriker,
              onChanged: (Player? newValue) {
                setState(() {
                  selectedNonStriker = newValue;
                });
              },
              items: widget.battingTeamPlayers.map<DropdownMenuItem<Player>>((Player player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButton<Player>(
              hint: Text('Select Bowler'),
              value: selectedBowler,
              onChanged: (Player? newValue) {
                setState(() {
                  selectedBowler = newValue;
                });
              },
              items: widget.bowlingTeamPlayers.map<DropdownMenuItem<Player>>((Player player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (selectedStriker != null && selectedNonStriker != null && selectedBowler != null && selectedStriker != selectedNonStriker) ? () {
                Navigator.pop(context, {
                  'striker': selectedStriker,
                  'nonStriker': selectedNonStriker,
                  'bowler': selectedBowler,
                });
              } : null,
              child: Text('Start Innings'),
            ),
          ],
        ),
      ),
    );
  }
}
