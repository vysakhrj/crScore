import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class PlayerSelectionDialog extends StatefulWidget {
  final List<Player> battingTeamPlayers;
  final List<Player> bowlingTeamPlayers;

  const PlayerSelectionDialog({
    required this.battingTeamPlayers,
    required this.bowlingTeamPlayers,
  });

  @override
  _PlayerSelectionDialogState createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  Player? selectedStriker;
  Player? selectedNonStriker;
  Player? selectedBowler;

  TextStyle get labelStyle => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.black54,
      );

  ButtonStyle getPrimaryButtonStyle(bool enabled) {
    return ElevatedButton.styleFrom(
      backgroundColor: enabled ? Colors.black87 : Colors.grey[400],
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 48),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  InputDecoration getDropdownDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = selectedStriker != null &&
        selectedNonStriker != null &&
        selectedBowler != null &&
        selectedStriker != selectedNonStriker;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SELECT PLAYERS', style: labelStyle),
            const SizedBox(height: 20),

            /// Striker
            DropdownButtonFormField<Player>(
              value: selectedStriker,
              decoration: getDropdownDecoration("Select Striker"),
              items: widget.battingTeamPlayers
                  .map((player) => DropdownMenuItem(
                        value: player,
                        child: Text(player.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedStriker = value);
              },
            ),
            const SizedBox(height: 16),

            /// Non-Striker
            DropdownButtonFormField<Player>(
              value: selectedNonStriker,
              decoration: getDropdownDecoration("Select Non-Striker"),
              items: widget.battingTeamPlayers
                  .map((player) => DropdownMenuItem(
                        value: player,
                        child: Text(player.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedNonStriker = value);
              },
            ),
            const SizedBox(height: 16),

            /// Bowler
            DropdownButtonFormField<Player>(
              value: selectedBowler,
              decoration: getDropdownDecoration("Select Bowler"),
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

            /// Start Button
            ElevatedButton(
              onPressed: isValid
                  ? () {
                      Navigator.pop(context, {
                        'striker': selectedStriker,
                        'nonStriker': selectedNonStriker,
                        'bowler': selectedBowler,
                      });
                    }
                  : null,
              style: getPrimaryButtonStyle(isValid),
              child: const Text("START INNINGS",
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
