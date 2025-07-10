import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class BatterSelectionDialog extends StatelessWidget {
  final List<Player> battingTeamPlayers;
  final String currentStrikerId;
  final String currentNonStrikerId;
  final String? selectedBatterType; // 'striker' or 'nonStriker'

  const BatterSelectionDialog({
    Key? key,
    required this.battingTeamPlayers,
    required this.currentStrikerId,
    required this.currentNonStrikerId,
    this.selectedBatterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter out current batters and those who have already started
    final availableBatters = battingTeamPlayers
        .where((player) =>
            player.id != currentStrikerId && player.id != currentNonStrikerId)
        .toList();

    return AlertDialog(
      title: Text(selectedBatterType == 'striker'
          ? 'Select New Striker'
          : selectedBatterType == 'nonStriker'
              ? 'Select New Non-Striker'
              : 'Select Batter'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (availableBatters.isEmpty) ...[
              Text(
                'No available batters to change.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              ...availableBatters.map((player) => ListTile(
                    title: Text(player.name),
                    onTap: () {
                      Navigator.of(context).pop(player.id);
                    },
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
