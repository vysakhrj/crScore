import 'package:cricket_scorer/models/player.dart';
import 'package:flutter/material.dart';

class NewBatterDialog extends StatefulWidget {
  final List<Player> availableBatters;

  const NewBatterDialog({required this.availableBatters});

  @override
  _NewBatterDialogState createState() => _NewBatterDialogState();
}

class _NewBatterDialogState extends State<NewBatterDialog> {
  Player? _selectedBatter;

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
            const Text('SELECT NEW BATTER',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black54)),
            const SizedBox(height: 20),
            DropdownButtonFormField<Player>(
              value: _selectedBatter,
              decoration: InputDecoration(
                hintText: "Select Batter",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: widget.availableBatters
                  .map((player) => DropdownMenuItem(
                        value: player,
                        child: Text(player.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedBatter = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedBatter != null
                  ? () => Navigator.pop(context, _selectedBatter!.id)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedBatter != null ? Colors.black87 : Colors.grey[400],
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('CONFIRM',
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
