import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class BatterSelectionDialog extends StatelessWidget {
  final List<Player> battingTeamPlayers;
  final String currentStrikerId;
  final String currentNonStrikerId;
  final String? selectedBatterType;

  const BatterSelectionDialog({
    Key? key,
    required this.battingTeamPlayers,
    required this.currentStrikerId,
    required this.currentNonStrikerId,
    this.selectedBatterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final availableBatters = battingTeamPlayers
        .where((p) => p.id != currentStrikerId && p.id != currentNonStrikerId)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedBatterType == 'striker'
                  ? 'SELECT NEW STRIKER'
                  : selectedBatterType == 'nonStriker'
                      ? 'SELECT NEW NON-STRIKER'
                      : 'SELECT BATTER',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.black54),
            ),
            const SizedBox(height: 20),
            if (availableBatters.isEmpty)
              const Text(
                'No available batters to change.',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              ...availableBatters.map((player) => ListTile(
                    title: Text(player.name),
                    onTap: () => Navigator.of(context).pop(player.id),
                  )),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}
