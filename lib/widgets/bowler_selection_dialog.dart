import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class BowlerSelectionDialog extends StatefulWidget {
  final List<Player> bowlingTeamPlayers;
  final String currentBowlerId;

  BowlerSelectionDialog(
      {required this.bowlingTeamPlayers, required this.currentBowlerId});

  @override
  _BowlerSelectionDialogState createState() => _BowlerSelectionDialogState();
}

class _BowlerSelectionDialogState extends State<BowlerSelectionDialog> {
  Player? selectedBowler;

  @override
  void initState() {
    super.initState();
    // Check if current bowler is in the available list (for edit functionality)
    final currentBowlerInList = widget.bowlingTeamPlayers
        .any((player) => player.id == widget.currentBowlerId);

    if (currentBowlerInList) {
      // Pre-select current bowler if they're in the list (for edit functionality)
      selectedBowler = widget.bowlingTeamPlayers
          .firstWhere((p) => p.id == widget.currentBowlerId);
    } else {
      // Don't pre-select the current bowler since they can't bowl consecutive overs
      selectedBowler = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select New Bowler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Current bowler cannot bowl consecutive overs',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 20),
            DropdownButton<Player>(
              hint: Text('Select Bowler'),
              value: selectedBowler,
              onChanged: (Player? newValue) {
                setState(() {
                  selectedBowler = newValue;
                });
              },
              items: widget.bowlingTeamPlayers
                  .map<DropdownMenuItem<Player>>((Player player) {
                return DropdownMenuItem<Player>(
                  value: player,
                  child: Text(player.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedBowler != null
                  ? () {
                      Navigator.pop(context, selectedBowler!.id);
                    }
                  : null,
              child: Text('Confirm Bowler'),
            ),
          ],
        ),
      ),
    );
  }
}
