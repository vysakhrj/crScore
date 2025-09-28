import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class BowlerSelectionDialog extends StatefulWidget {
  final List<Player> bowlingTeamPlayers;
  final String currentBowlerId;

  const BowlerSelectionDialog({
    required this.bowlingTeamPlayers,
    required this.currentBowlerId,
  });

  @override
  _BowlerSelectionDialogState createState() => _BowlerSelectionDialogState();
}

class _BowlerSelectionDialogState extends State<BowlerSelectionDialog> {
  Player? selectedBowler;

  @override
  void initState() {
    super.initState();
    if (widget.bowlingTeamPlayers
        .any((player) => player.id == widget.currentBowlerId)) {
      selectedBowler = widget.bowlingTeamPlayers
          .firstWhere((p) => p.id == widget.currentBowlerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SELECT NEW BOWLER',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black54)),
            const SizedBox(height: 10),
            const Text('Current bowler cannot bowl consecutive overs',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            DropdownButtonFormField<Player>(
              value: selectedBowler,
              decoration: InputDecoration(
                hintText: "Select Bowler",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: widget.bowlingTeamPlayers
                  .map((player) => DropdownMenuItem(
                        value: player,
                        child: Text(player.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedBowler = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedBowler != null
                  ? () => Navigator.pop(context, selectedBowler!.id)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedBowler != null ? Colors.black87 : Colors.grey[400],
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('CONFIRM BOWLER',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
